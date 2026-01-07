#!/bin/bash

# 카카오톡 키 해시 확인 스크립트
# 릴리스 키스토어가 없으면 생성, 있으면 키 해시 확인

KEYSTORE_PATH="./app/keystore/release.keystore"
KEY_ALIAS="cafeplatform-release"
KEYSTORE_PASSWORD="cafeplatform123"  # 실제 운영 시에는 안전한 비밀번호로 변경하세요

echo "=== 카카오톡 키 해시 확인 ==="
echo ""

# 릴리스 키스토어가 없으면 생성
if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "릴리스 키스토어가 없습니다. 생성 중..."
    keytool -genkey -v \
        -keystore "$KEYSTORE_PATH" \
        -alias "$KEY_ALIAS" \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -storepass "$KEYSTORE_PASSWORD" \
        -keypass "$KEYSTORE_PASSWORD" \
        -dname "CN=CafePlatform, OU=Mobile, O=Gifnut, L=Seoul, ST=Seoul, C=KR"
    echo "✅ 릴리스 키스토어 생성 완료!"
    echo ""
fi

echo "=== 디버그 키 해시 (SHA1) ==="
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android 2>/dev/null | openssl sha1 -binary | openssl base64
echo ""

echo "=== 디버그 키 해시 (SHA256) ==="
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android 2>/dev/null | openssl sha256 -binary | openssl base64
echo ""

if [ -f "$KEYSTORE_PATH" ]; then
    echo "=== 릴리스 키 해시 (SHA1) ==="
    keytool -exportcert -alias "$KEY_ALIAS" -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD" -keypass "$KEYSTORE_PASSWORD" 2>/dev/null | openssl sha1 -binary | openssl base64
    echo ""
    
    echo "=== 릴리스 키 해시 (SHA256) ==="
    keytool -exportcert -alias "$KEY_ALIAS" -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD" -keypass "$KEYSTORE_PASSWORD" 2>/dev/null | openssl sha256 -binary | openssl base64
    echo ""
    
    echo "⚠️  릴리스 키스토어 비밀번호: $KEYSTORE_PASSWORD"
    echo "⚠️  실제 운영 배포 시에는 안전한 비밀번호로 변경하세요!"
    echo "⚠️  키스토어 파일과 비밀번호를 안전하게 보관하세요!"
else
    echo "❌ 릴리스 키스토어를 찾을 수 없습니다."
fi

echo ""
echo "=== 카카오 개발자 콘솔에 등록할 키 해시 ==="
echo "위의 SHA1 Base64 값을 카카오 개발자 콘솔에 등록하세요."
echo "URL: https://developers.kakao.com/"

