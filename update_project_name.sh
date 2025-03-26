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

# pubspec.yaml에서 현재 프로젝트 이름과 앱 이름 읽기
if [ -f "pubspec.yaml" ]; then
  OLD_PROJECT_NAME=$(grep "^name:" pubspec.yaml | sed 's/name: //')
  OLD_APP_NAME=$(grep "^description:" pubspec.yaml | sed 's/description: //')
  echo "현재 프로젝트 이름: $OLD_PROJECT_NAME"
  echo "현재 앱 이름: $OLD_APP_NAME"
else
  echo "pubspec.yaml 파일을 찾을 수 없습니다."
  exit 1
fi

# AndroidManifest.xml에서 패키지 이름 읽기
if [ -f "android/app/build.gradle" ]; then
  OLD_PACKAGE_NAME=$(grep -E "applicationId [\"'].*[\"']" android/app/build.gradle | grep -o -E "[\"'].*[\"']" | sed 's/["\"]//g' | head -1)
  echo "현재 패키지 이름: $OLD_PACKAGE_NAME"
elif [ -f "android/app/src/main/AndroidManifest.xml" ]; then
  OLD_PACKAGE_NAME=$(grep -E "package=" android/app/src/main/AndroidManifest.xml | grep -o -E "package=\"[^\"]*\"" | sed 's/package="//' | sed 's/"//')
  echo "현재 패키지 이름: $OLD_PACKAGE_NAME"
else
  echo "패키지 이름을 찾을 수 없습니다. 기본값 사용"
  OLD_PACKAGE_NAME="com.testing.template"
fi

# 프로젝트 이름은 패키지 이름에서 추출하지 않고 사용자가 입력한 앱 이름에서 추출
NEW_PROJECT_NAME=$(echo "$NEW_APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

echo "앱 이름을 '$OLD_APP_NAME'에서 '$NEW_APP_NAME'으로 변경합니다..."
echo "프로젝트 이름을 '$OLD_PROJECT_NAME'에서 '$NEW_PROJECT_NAME'으로 변경합니다..."
echo "패키지 이름은 '$OLD_PACKAGE_NAME'으로 유지합니다."

# pubspec.yaml 업데이트
echo "pubspec.yaml 업데이트 중..."
sed -i '' "s/name: $OLD_PROJECT_NAME/name: $NEW_PROJECT_NAME/" pubspec.yaml
sed -i '' "s/description: $OLD_APP_NAME/description: $NEW_APP_NAME/" pubspec.yaml

# Android build.gradle의 flavor 설정에서 앱 이름 변경
echo "Android build.gradle의 flavor 설정 업데이트 중..."
if [ -f "android/app/build.gradle" ]; then
  # Production flavor 앱 이름 변경
  if grep -q "manifestPlaceholders = \[appName: " "android/app/build.gradle"; then
    # production flavor
    PROD_APP_NAME_PATTERN=$(grep -A 1 "production {" "android/app/build.gradle" | grep "manifestPlaceholders" | grep -o "\[appName: \"[^\"]*\"" | sed 's/\[appName: "//' | sed 's/"//')
    if [ ! -z "$PROD_APP_NAME_PATTERN" ]; then
      echo "현재 Production flavor 앱 이름: $PROD_APP_NAME_PATTERN"
      sed -i '' "s/manifestPlaceholders = \[appName: \"$PROD_APP_NAME_PATTERN\"/manifestPlaceholders = \[appName: \"$NEW_APP_NAME\"/" "android/app/build.gradle"
      echo "Production flavor 앱 이름이 '$NEW_APP_NAME'으로 업데이트되었습니다."
    fi
    
    # staging flavor
    STG_APP_NAME_PATTERN=$(grep -A 1 "staging {" "android/app/build.gradle" | grep "manifestPlaceholders" | grep -o "\[appName: \"[^\"]*\"" | sed 's/\[appName: "//' | sed 's/"//')
    if [ ! -z "$STG_APP_NAME_PATTERN" ]; then
      echo "현재 Staging flavor 앱 이름: $STG_APP_NAME_PATTERN"
      NEW_STG_APP_NAME="[STG] $NEW_APP_NAME"
      sed -i '' "s/manifestPlaceholders = \[appName: \"$STG_APP_NAME_PATTERN\"/manifestPlaceholders = \[appName: \"$NEW_STG_APP_NAME\"/" "android/app/build.gradle"
      echo "Staging flavor 앱 이름이 '$NEW_STG_APP_NAME'으로 업데이트되었습니다."
    fi
    
    # development flavor
    DEV_APP_NAME_PATTERN=$(grep -A 1 "development {" "android/app/build.gradle" | grep "manifestPlaceholders" | grep -o "\[appName: \"[^\"]*\"" | sed 's/\[appName: "//' | sed 's/"//')
    if [ ! -z "$DEV_APP_NAME_PATTERN" ]; then
      echo "현재 Development flavor 앱 이름: $DEV_APP_NAME_PATTERN"
      NEW_DEV_APP_NAME="[DEV] $NEW_APP_NAME"
      sed -i '' "s/manifestPlaceholders = \[appName: \"$DEV_APP_NAME_PATTERN\"/manifestPlaceholders = \[appName: \"$NEW_DEV_APP_NAME\"/" "android/app/build.gradle"
      echo "Development flavor 앱 이름이 '$NEW_DEV_APP_NAME'으로 업데이트되었습니다."
    fi
  else
    echo "build.gradle에서 manifestPlaceholders 설정을 찾을 수 없습니다."
  fi
else
  echo "android/app/build.gradle 파일을 찾을 수 없습니다."
fi

# iOS Info.plist 변수 참조 설정
echo "iOS Info.plist 업데이트 중..."
if [ -f "ios/Runner/Info.plist" ]; then
  # CFBundleDisplayName을 변수 참조로 변경
  if grep -q "<key>CFBundleDisplayName</key>" "ios/Runner/Info.plist"; then
    # Info.plist에서 CFBundleDisplayName 값이 하드코딩되어 있는지 확인
    if ! grep -q "<string>\$(FLAVOR_APP_NAME)</string>" "ios/Runner/Info.plist"; then
      echo "CFBundleDisplayName을 변수 참조로 변경합니다..."
      sed -i '' "s/<key>CFBundleDisplayName<\/key>\\n.*<string>[^<]*<\/string>/<key>CFBundleDisplayName<\/key>\\n\t<string>\$(FLAVOR_APP_NAME)<\/string>/" "ios/Runner/Info.plist"
    else
      echo "CFBundleDisplayName은 이미 변수 참조를 사용 중입니다."
    fi
  fi
  
  # CFBundleName을 변수 참조로 변경
  if grep -q "<key>CFBundleName</key>" "ios/Runner/Info.plist"; then
    # Info.plist에서 CFBundleName 값이 하드코딩되어 있는지 확인
    if ! grep -q "<string>\$(FLAVOR_APP_NAME)</string>" "ios/Runner/Info.plist"; then
      echo "CFBundleName을 변수 참조로 변경합니다..."
      sed -i '' "s/<key>CFBundleName<\/key>\\n.*<string>[^<]*<\/string>/<key>CFBundleName<\/key>\\n\t<string>\$(FLAVOR_APP_NAME)<\/string>/" "ios/Runner/Info.plist"
    else
      echo "CFBundleName은 이미 변수 참조를 사용 중입니다."
    fi
  fi
fi

# iOS Flavor xcconfig 파일 업데이트
echo "iOS xcconfig 파일 업데이트 중..."
# 짧은 앱 이름 생성 (첫 번째 단어)
SHORT_NAME=$(echo "$NEW_APP_NAME" | awk '{print $1}')

# development.xcconfig 업데이트
if [ -f "ios/development.xcconfig" ]; then
  echo "ios/development.xcconfig 업데이트 중..."
  
  # 공백 라인 확인 및 추가
  if [[ $(tail -1 "ios/development.xcconfig") != "" ]]; then
    echo "" >> "ios/development.xcconfig"
  fi
  
  # FLUTTER_TARGET_NAME 설정
  if grep -q "FLUTTER_TARGET_NAME=" "ios/development.xcconfig"; then
    DEV_TARGET_NAME=$(grep "FLUTTER_TARGET_NAME=" "ios/development.xcconfig" | sed 's/FLUTTER_TARGET_NAME=//')
    sed -i '' "s/FLUTTER_TARGET_NAME=$DEV_TARGET_NAME/FLUTTER_TARGET_NAME=$NEW_PROJECT_NAME/" "ios/development.xcconfig"
  else
    echo "FLUTTER_TARGET_NAME=$NEW_PROJECT_NAME" >> "ios/development.xcconfig"
  fi
  
  # FLUTTER_FLAVOR 설정
  if grep -q "FLUTTER_FLAVOR=" "ios/development.xcconfig"; then
    sed -i '' "s/FLUTTER_FLAVOR=.*/FLUTTER_FLAVOR=development/" "ios/development.xcconfig"
  else
    echo "FLUTTER_FLAVOR=development" >> "ios/development.xcconfig"
  fi
  
  # FLAVOR_APP_NAME 설정
  if grep -q "FLAVOR_APP_NAME=" "ios/development.xcconfig"; then
    DEV_APP_NAME=$(grep "FLAVOR_APP_NAME=" "ios/development.xcconfig" | sed 's/FLAVOR_APP_NAME=//')
    NEW_DEV_APP_NAME="$NEW_APP_NAME Dev"
    sed -i '' "s/FLAVOR_APP_NAME=$DEV_APP_NAME/FLAVOR_APP_NAME=$NEW_DEV_APP_NAME/" "ios/development.xcconfig"
  else
    echo "FLAVOR_APP_NAME=$NEW_APP_NAME Dev" >> "ios/development.xcconfig"
  fi
  
  # PRODUCT_BUNDLE_IDENTIFIER 설정
  if grep -q "PRODUCT_BUNDLE_IDENTIFIER=" "ios/development.xcconfig"; then
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER=.*/PRODUCT_BUNDLE_IDENTIFIER=$OLD_PACKAGE_NAME.dev/" "ios/development.xcconfig"
  else
    echo "PRODUCT_BUNDLE_IDENTIFIER=$OLD_PACKAGE_NAME.dev" >> "ios/development.xcconfig"
  fi
fi

# staging.xcconfig 업데이트
if [ -f "ios/staging.xcconfig" ]; then
  echo "ios/staging.xcconfig 업데이트 중..."
  
  # 공백 라인 확인 및 추가
  if [[ $(tail -1 "ios/staging.xcconfig") != "" ]]; then
    echo "" >> "ios/staging.xcconfig"
  fi
  
  # FLUTTER_TARGET_NAME 설정
  if grep -q "FLUTTER_TARGET_NAME=" "ios/staging.xcconfig"; then
    STG_TARGET_NAME=$(grep "FLUTTER_TARGET_NAME=" "ios/staging.xcconfig" | sed 's/FLUTTER_TARGET_NAME=//')
    sed -i '' "s/FLUTTER_TARGET_NAME=$STG_TARGET_NAME/FLUTTER_TARGET_NAME=$NEW_PROJECT_NAME/" "ios/staging.xcconfig"
  else
    echo "FLUTTER_TARGET_NAME=$NEW_PROJECT_NAME" >> "ios/staging.xcconfig"
  fi
  
  # FLUTTER_FLAVOR 설정
  if grep -q "FLUTTER_FLAVOR=" "ios/staging.xcconfig"; then
    sed -i '' "s/FLUTTER_FLAVOR=.*/FLUTTER_FLAVOR=staging/" "ios/staging.xcconfig"
  else
    echo "FLUTTER_FLAVOR=staging" >> "ios/staging.xcconfig"
  fi
  
  # FLAVOR_APP_NAME 설정
  if grep -q "FLAVOR_APP_NAME=" "ios/staging.xcconfig"; then
    STG_APP_NAME=$(grep "FLAVOR_APP_NAME=" "ios/staging.xcconfig" | sed 's/FLAVOR_APP_NAME=//')
    NEW_STG_APP_NAME="$NEW_APP_NAME Staging"
    sed -i '' "s/FLAVOR_APP_NAME=$STG_APP_NAME/FLAVOR_APP_NAME=$NEW_STG_APP_NAME/" "ios/staging.xcconfig"
  else
    echo "FLAVOR_APP_NAME=$NEW_APP_NAME Staging" >> "ios/staging.xcconfig"
  fi
  
  # PRODUCT_BUNDLE_IDENTIFIER 설정
  if grep -q "PRODUCT_BUNDLE_IDENTIFIER=" "ios/staging.xcconfig"; then
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER=.*/PRODUCT_BUNDLE_IDENTIFIER=$OLD_PACKAGE_NAME.stg/" "ios/staging.xcconfig"
  else
    echo "PRODUCT_BUNDLE_IDENTIFIER=$OLD_PACKAGE_NAME.stg" >> "ios/staging.xcconfig"
  fi
fi

# production.xcconfig 업데이트
if [ -f "ios/production.xcconfig" ]; then
  echo "ios/production.xcconfig 업데이트 중..."
  
  # 공백 라인 확인 및 추가
  if [[ $(tail -1 "ios/production.xcconfig") != "" ]]; then
    echo "" >> "ios/production.xcconfig"
  fi
  
  # FLUTTER_TARGET_NAME 설정
  if grep -q "FLUTTER_TARGET_NAME=" "ios/production.xcconfig"; then
    PROD_TARGET_NAME=$(grep "FLUTTER_TARGET_NAME=" "ios/production.xcconfig" | sed 's/FLUTTER_TARGET_NAME=//')
    sed -i '' "s/FLUTTER_TARGET_NAME=$PROD_TARGET_NAME/FLUTTER_TARGET_NAME=$NEW_PROJECT_NAME/" "ios/production.xcconfig"
  else
    echo "FLUTTER_TARGET_NAME=$NEW_PROJECT_NAME" >> "ios/production.xcconfig"
  fi
  
  # FLUTTER_FLAVOR 설정
  if grep -q "FLUTTER_FLAVOR=" "ios/production.xcconfig"; then
    sed -i '' "s/FLUTTER_FLAVOR=.*/FLUTTER_FLAVOR=production/" "ios/production.xcconfig"
  else
    echo "FLUTTER_FLAVOR=production" >> "ios/production.xcconfig"
  fi
  
  # FLAVOR_APP_NAME 설정
  if grep -q "FLAVOR_APP_NAME=" "ios/production.xcconfig"; then
    PROD_APP_NAME=$(grep "FLAVOR_APP_NAME=" "ios/production.xcconfig" | sed 's/FLAVOR_APP_NAME=//')
    sed -i '' "s/FLAVOR_APP_NAME=$PROD_APP_NAME/FLAVOR_APP_NAME=$NEW_APP_NAME/" "ios/production.xcconfig"
  else
    echo "FLAVOR_APP_NAME=$NEW_APP_NAME" >> "ios/production.xcconfig"
  fi
  
  # PRODUCT_BUNDLE_IDENTIFIER 설정
  if grep -q "PRODUCT_BUNDLE_IDENTIFIER=" "ios/production.xcconfig"; then
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER=.*/PRODUCT_BUNDLE_IDENTIFIER=$OLD_PACKAGE_NAME/" "ios/production.xcconfig"
  else
    echo "PRODUCT_BUNDLE_IDENTIFIER=$OLD_PACKAGE_NAME" >> "ios/production.xcconfig"
  fi
fi

# import 문 업데이트
echo "Dart 파일의 import 문 업데이트 중..."
DART_FILES=$(find . -type f -name "*.dart" | grep -v ".dart_tool" | grep -v "build/")
UPDATED_FILES=0

for FILE in $DART_FILES; do
  # 해당 파일에 import package:OLD_PROJECT_NAME/ 문이 있는지 확인
  if grep -q "import 'package:$OLD_PROJECT_NAME/" "$FILE"; then
    # import 문 변경
    sed -i '' "s/import 'package:$OLD_PROJECT_NAME\//import 'package:$NEW_PROJECT_NAME\//g" "$FILE"
    UPDATED_FILES=$((UPDATED_FILES + 1))
  fi
  
  # export package:OLD_PROJECT_NAME/ 문도 변경
  if grep -q "export 'package:$OLD_PROJECT_NAME/" "$FILE"; then
    sed -i '' "s/export 'package:$OLD_PROJECT_NAME\//export 'package:$NEW_PROJECT_NAME\//g" "$FILE"
    UPDATED_FILES=$((UPDATED_FILES + 1))
  fi
done

echo "$UPDATED_FILES 개의 파일의 import/export 문이 업데이트되었습니다."

echo "성공적으로 완료되었습니다!"
echo "앱 이름: $NEW_APP_NAME"
echo "프로젝트 이름: $NEW_PROJECT_NAME"
echo "패키지 이름: $OLD_PACKAGE_NAME (변경되지 않음)"
