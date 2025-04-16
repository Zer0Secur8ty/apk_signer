#!/bin/bash

echo "==============================="
echo "📦 APK Signing (Google Play OK)"
echo "==============================="


read -p "🔍 Enter path to APK file: " APK_INPUT


APK_BASE=$(basename "$APK_INPUT" .apk)
APK_ALIGNED="${APK_BASE}-aligned.apk"
APK_SIGNED="${APK_BASE}-signed.apk"
KEYSTORE_NAME="mykeystore.jks"
ALIAS_NAME="myalias"
STORE_PASS="mypassword123"
KEY_PASS="mypassword123"
DNAME="CN=MyApp, OU=Dev, O=MyCompany, L=Cairo, ST=EG, C=EG"


if [ ! -f "$KEYSTORE_NAME" ]; then
    echo "[+] Creating new keystore..."
    keytool -genkeypair -v \
        -keystore "$KEYSTORE_NAME" \
        -alias "$ALIAS_NAME" \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -storepass "$STORE_PASS" \
        -keypass "$KEY_PASS" \
        -dname "$DNAME"
else
    echo "[*] Keystore exists. Using existing one..."
fi


echo "[+] Aligning APK..."
zipalign -v -p 4 "$APK_INPUT" "$APK_ALIGNED"


echo "[+] Signing APK..."
apksigner sign \
    --ks "$KEYSTORE_NAME" \
    --ks-key-alias "$ALIAS_NAME" \
    --ks-pass pass:"$STORE_PASS" \
    --key-pass pass:"$KEY_PASS" \
    --out "$APK_SIGNED" \
    "$APK_ALIGNED"



echo "[+] Verifying signed APK..."
apksigner verify --verbose --print-certs "$APK_SIGNED"

echo ""
echo "[✅] Done! Signed APK: $APK_SIGNED"
