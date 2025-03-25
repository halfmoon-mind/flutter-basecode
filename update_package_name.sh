#!/bin/bash

# 패키지 이름 변경 스크립트
# 사용법: ./update_package_name.sh com.your.newpackagename

# 오류 발생시 스크립트 중단
set -e

# 입력 검증
if [ $# -ne 1 ]; then
  echo "사용법: ./update_package_name.sh com.your.newpackagename"
  echo "예: ./update_package_name.sh com.example.myapp"
  exit 1
fi

NEW_PACKAGE_NAME=$1
OLD_PACKAGE_NAME="com.testing.template"

echo "패키지 이름을 $OLD_PACKAGE_NAME 에서 $NEW_PACKAGE_NAME 으로 변경합니다..."

# Android 패키지 이름 변경
echo "Android 패키지 이름 변경 중..."
sed -i '' "s/namespace \"$OLD_PACKAGE_NAME\"/namespace \"$NEW_PACKAGE_NAME\"/" android/app/build.gradle
sed -i '' "s/applicationId \"$OLD_PACKAGE_NAME\"/applicationId \"$NEW_PACKAGE_NAME\"/" android/app/build.gradle

# Android 패키지 네임스페이스 변경 (kotlin 파일들이 있는 디렉토리 경로 변경)
OLD_PACKAGE_PATH=$(echo $OLD_PACKAGE_NAME | sed 's/\./\//g')
NEW_PACKAGE_PATH=$(echo $NEW_PACKAGE_NAME | sed 's/\./\//g')

if [ -d "android/app/src/main/kotlin/$OLD_PACKAGE_PATH" ]; then
  echo "Android 소스 디렉토리 구조 변경 중..."
  
  # 새 디렉토리 생성
  mkdir -p "android/app/src/main/kotlin/$NEW_PACKAGE_PATH"
  
  # 파일 복사
  cp -R "android/app/src/main/kotlin/$OLD_PACKAGE_PATH"/* "android/app/src/main/kotlin/$NEW_PACKAGE_PATH"
  
  # 파일 내용 업데이트
  find "android/app/src/main/kotlin/$NEW_PACKAGE_PATH" -type f -name "*.kt" -exec sed -i '' "s/package $OLD_PACKAGE_NAME/package $NEW_PACKAGE_NAME/g" {} \;
  
  # 기존 디렉토리 제거 (선택적)
  rm -rf "android/app/src/main/kotlin/$OLD_PACKAGE_PATH"
fi

# iOS 패키지 이름 변경
echo "iOS 패키지 이름 변경 중..."
PBXPROJ_FILE="ios/Runner.xcodeproj/project.pbxproj"

# PRODUCT_BUNDLE_IDENTIFIER 변경 - 모든 가능한 패턴 포함
# 기본 패키지 ID 변경
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME;/g" $PBXPROJ_FILE
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME.dev;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.dev;/g" $PBXPROJ_FILE
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME.stg;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.stg;/g" $PBXPROJ_FILE
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME.RunnerTests;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.RunnerTests;/g" $PBXPROJ_FILE

# 추가: com.hello.word와 같은 하드코딩된 ID 처리 (project.pbxproj 파일에서 발견됨)
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.hello\.word;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME;/g" $PBXPROJ_FILE
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.hello\.word\.dev;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.dev;/g" $PBXPROJ_FILE
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.hello\.word\.stg;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.stg;/g" $PBXPROJ_FILE
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.hello\.word\.RunnerTests;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.RunnerTests;/g" $PBXPROJ_FILE

# 더 포괄적인 접근: 따옴표 없는 PRODUCT_BUNDLE_IDENTIFIER 처리
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.hello\.word$/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME/g" $PBXPROJ_FILE
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.hello\.word;$/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME;/g" $PBXPROJ_FILE

# iOS xcconfig 파일 업데이트
echo "iOS xcconfig 파일 업데이트 중..."

# production.xcconfig 업데이트
if [ -f "ios/production.xcconfig" ]; then
  if grep -q "PRODUCT_BUNDLE_IDENTIFIER=" "ios/production.xcconfig"; then
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER=$OLD_PACKAGE_NAME/PRODUCT_BUNDLE_IDENTIFIER=$NEW_PACKAGE_NAME/" "ios/production.xcconfig"
    # 하드코딩된 ID 처리
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER=com\.hello\.word/PRODUCT_BUNDLE_IDENTIFIER=$NEW_PACKAGE_NAME/" "ios/production.xcconfig"
  else
    echo "PRODUCT_BUNDLE_IDENTIFIER=$NEW_PACKAGE_NAME" >> "ios/production.xcconfig"
  fi
fi

# development.xcconfig 업데이트
if [ -f "ios/development.xcconfig" ]; then
  if grep -q "PRODUCT_BUNDLE_IDENTIFIER=" "ios/development.xcconfig"; then
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER=$OLD_PACKAGE_NAME.dev/PRODUCT_BUNDLE_IDENTIFIER=$NEW_PACKAGE_NAME.dev/" "ios/development.xcconfig"
    # 하드코딩된 ID 처리
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER=com\.hello\.word\.dev/PRODUCT_BUNDLE_IDENTIFIER=$NEW_PACKAGE_NAME.dev/" "ios/development.xcconfig"
  else
    echo "PRODUCT_BUNDLE_IDENTIFIER=$NEW_PACKAGE_NAME.dev" >> "ios/development.xcconfig"
  fi
fi

# staging.xcconfig 업데이트
if [ -f "ios/staging.xcconfig" ]; then
  if grep -q "PRODUCT_BUNDLE_IDENTIFIER=" "ios/staging.xcconfig"; then
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER=$OLD_PACKAGE_NAME.stg/PRODUCT_BUNDLE_IDENTIFIER=$NEW_PACKAGE_NAME.stg/" "ios/staging.xcconfig"
    # 하드코딩된 ID 처리
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER=com\.hello\.word\.stg/PRODUCT_BUNDLE_IDENTIFIER=$NEW_PACKAGE_NAME.stg/" "ios/staging.xcconfig"
  else
    echo "PRODUCT_BUNDLE_IDENTIFIER=$NEW_PACKAGE_NAME.stg" >> "ios/staging.xcconfig"
  fi
fi

echo "macOS 패키지 이름 변경 중..."
MACOS_PBXPROJ_FILE="macos/Runner.xcodeproj/project.pbxproj"

if [ -f "$MACOS_PBXPROJ_FILE" ]; then
  # macOS PRODUCT_BUNDLE_IDENTIFIER 변경
  sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME;/g" $MACOS_PBXPROJ_FILE
  sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME.dev;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.dev;/g" $MACOS_PBXPROJ_FILE
  sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME.stg;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.stg;/g" $MACOS_PBXPROJ_FILE
  sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = $OLD_PACKAGE_NAME.RunnerTests;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.RunnerTests;/g" $MACOS_PBXPROJ_FILE
  
  # 추가: 하드코딩된 ID 처리
  sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.hello\.word;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME;/g" $MACOS_PBXPROJ_FILE
  sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.hello\.word\.dev;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.dev;/g" $MACOS_PBXPROJ_FILE
  sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.hello\.word\.stg;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.stg;/g" $MACOS_PBXPROJ_FILE
  sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.hello\.word\.RunnerTests;/PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.RunnerTests;/g" $MACOS_PBXPROJ_FILE
fi

echo "패키지 이름이 성공적으로 $NEW_PACKAGE_NAME 으로 변경되었습니다."
