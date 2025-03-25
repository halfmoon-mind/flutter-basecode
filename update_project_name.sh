#!/bin/bash

# 앱 이름 변경 스크립트
# 사용법: ./update_project_name.sh "새로운 앱 이름"
# 예: ./update_project_name.sh "My New App"

# 오류 발생시 스크립트 중단
set -e

# 입력 검증
if [ $# -ne 1 ]; then
  echo "사용법: ./update_project_name.sh \"새로운 앱 이름\""
  echo "예: ./update_project_name.sh \"My New App\""
  exit 1
fi

NEW_APP_NAME=$1
OLD_APP_NAME="Template App"
OLD_PACKAGE_NAME="com.testing.template"
OLD_PROJECT_NAME="template"

# 프로젝트 이름은 패키지 이름에서 추출하지 않고 사용자가 입력한 앱 이름에서 추출
NEW_PROJECT_NAME=$(echo "$NEW_APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

echo "앱 이름을 '$OLD_APP_NAME'에서 '$NEW_APP_NAME'으로 변경합니다..."
echo "프로젝트 이름을 '$OLD_PROJECT_NAME'에서 '$NEW_PROJECT_NAME'으로 변경합니다..."
echo "패키지 이름은 '$OLD_PACKAGE_NAME'으로 유지합니다."

# pubspec.yaml 업데이트
echo "pubspec.yaml 업데이트 중..."
sed -i '' "s/name: $OLD_PROJECT_NAME/name: $NEW_PROJECT_NAME/" pubspec.yaml
sed -i '' "s/description: $OLD_APP_NAME/description: $NEW_APP_NAME/" pubspec.yaml

# Android 앱 이름 변경
echo "Android 앱 이름 변경 중..."
# 기본 앱 이름 변경
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
  sed -i '' "s/android:label=\"$OLD_APP_NAME\"/android:label=\"$NEW_APP_NAME\"/" android/app/src/main/AndroidManifest.xml
fi

# Flavor별 앱 이름 변경
FLAVORS=("development" "staging" "profile" "debug")
for FLAVOR in "${FLAVORS[@]}"; do
  if [ -f "android/app/src/$FLAVOR/AndroidManifest.xml" ]; then
    sed -i '' "s/android:label=\"$OLD_APP_NAME $FLAVOR\"/android:label=\"$NEW_APP_NAME $FLAVOR\"/" "android/app/src/$FLAVOR/AndroidManifest.xml"
    echo "  - $FLAVOR flavor 앱 이름 업데이트 완료"
  fi
done

# iOS 앱 이름 변경
echo "iOS 앱 이름 변경 중..."
if [ -f "ios/Runner/Info.plist" ]; then
  # CFBundleName 변경 (짧은 이름)
  SHORT_NAME=$(echo "$NEW_APP_NAME" | awk '{print $1}')
  sed -i '' "s/<key>CFBundleName<\/key>\\n\t<string>$OLD_PROJECT_NAME<\/string>/<key>CFBundleName<\/key>\\n\t<string>$SHORT_NAME<\/string>/" "ios/Runner/Info.plist"
  
  # CFBundleDisplayName 변경 (전체 이름)
  sed -i '' "s/<key>CFBundleDisplayName<\/key>\\n\t<string>$OLD_APP_NAME<\/string>/<key>CFBundleDisplayName<\/key>\\n\t<string>$NEW_APP_NAME<\/string>/" "ios/Runner/Info.plist"
fi

# iOS Flavor 설정 업데이트
echo "iOS Flavor 설정 업데이트 중..."
# xcconfig 파일들이 있다면 업데이트
if [ -d "ios/Flutter" ]; then
  if [ -f "ios/Flutter/Development.xcconfig" ]; then
    sed -i '' "s/FLUTTER_TARGET_NAME=$OLD_PROJECT_NAME/FLUTTER_TARGET_NAME=$NEW_PROJECT_NAME/" "ios/Flutter/Development.xcconfig"
    sed -i '' "s/DISPLAY_NAME=$OLD_APP_NAME Dev/DISPLAY_NAME=$NEW_APP_NAME Dev/" "ios/Flutter/Development.xcconfig"
  fi
  
  if [ -f "ios/Flutter/Staging.xcconfig" ]; then
    sed -i '' "s/FLUTTER_TARGET_NAME=$OLD_PROJECT_NAME/FLUTTER_TARGET_NAME=$NEW_PROJECT_NAME/" "ios/Flutter/Staging.xcconfig"
    sed -i '' "s/DISPLAY_NAME=$OLD_APP_NAME Staging/DISPLAY_NAME=$NEW_APP_NAME Staging/" "ios/Flutter/Staging.xcconfig"
  fi
  
  if [ -f "ios/Flutter/Production.xcconfig" ]; then
    sed -i '' "s/FLUTTER_TARGET_NAME=$OLD_PROJECT_NAME/FLUTTER_TARGET_NAME=$NEW_PROJECT_NAME/" "ios/Flutter/Production.xcconfig"
    sed -i '' "s/DISPLAY_NAME=$OLD_APP_NAME/DISPLAY_NAME=$NEW_APP_NAME/" "ios/Flutter/Production.xcconfig"
  fi
fi

# macOS 앱 이름 변경 (필요한 경우)
if [ -d "macos" ]; then
  echo "macOS 앱 이름 변경 중..."
  if [ -f "macos/Runner/Info.plist" ]; then
    # CFBundleName 변경 (짧은 이름)
    SHORT_NAME=$(echo "$NEW_APP_NAME" | awk '{print $1}')
    sed -i '' "s/<key>CFBundleName<\/key>\\n\t<string>$OLD_PROJECT_NAME<\/string>/<key>CFBundleName<\/key>\\n\t<string>$SHORT_NAME<\/string>/" "macos/Runner/Info.plist"
    
    # CFBundleDisplayName 변경 (전체 이름)
    sed -i '' "s/<key>CFBundleDisplayName<\/key>\\n\t<string>$OLD_APP_NAME<\/string>/<key>CFBundleDisplayName<\/key>\\n\t<string>$NEW_APP_NAME<\/string>/" "macos/Runner/Info.plist"
  fi
fi

# 웹 앱 이름 변경 (필요한 경우)
if [ -d "web" ]; then
  echo "웹 앱 이름 변경 중..."
  if [ -f "web/index.html" ]; then
    sed -i '' "s/<title>$OLD_APP_NAME<\/title>/<title>$NEW_APP_NAME<\/title>/" "web/index.html"
    sed -i '' "s/<meta name=\"description\" content=\"$OLD_APP_NAME\">/<meta name=\"description\" content=\"$NEW_APP_NAME\">/" "web/index.html"
  fi
  
  if [ -f "web/manifest.json" ]; then
    sed -i '' "s/\"name\": \"$OLD_APP_NAME\"/\"name\": \"$NEW_APP_NAME\"/" "web/manifest.json"
    sed -i '' "s/\"short_name\": \"$OLD_APP_NAME\"/\"short_name\": \"$NEW_APP_NAME\"/" "web/manifest.json"
  fi
fi

echo "성공적으로 완료되었습니다!"
echo "앱 이름: $NEW_APP_NAME"
echo "프로젝트 이름: $NEW_PROJECT_NAME"
echo "패키지 이름: $OLD_PACKAGE_NAME (변경되지 않음)"
