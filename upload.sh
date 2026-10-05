#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Colors
GREEN='\033[0;32m'
GOLD='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Ensure we run from KC-App directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BUCKET_NAME="kapada-creation-dev.firebasestorage.app"
DEST_PATH="app_releases/kapada_creation.apk"
PUBLIC_URL="https://firebasestorage.googleapis.com/v0/b/${BUCKET_NAME}/o/app_releases%2Fkapada_creation.apk?alt=media"

echo -e "\n${BOLD}${GOLD}==============================================${NC}"
echo -e "${BOLD}${GOLD}   Kapada Creation (KC-App) Release Script   ${NC}"
echo -e "${BOLD}${GOLD}==============================================${NC}\n"

# Step 1: Read App Version
APP_VERSION=$(grep 'version:' pubspec.yaml | head -n 1 | awk '{print $2}')
echo -e "${CYAN}App Version:${NC} ${BOLD}${APP_VERSION}${NC}"
echo -e "${CYAN}Target Destination:${NC} gs://${BUCKET_NAME}/${DEST_PATH}\n"

# Step 2: Build APK
echo -e "${BOLD}1. Building Release APK (flutter build apk --release)...${NC}"
flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}Error: APK file not found at $APK_PATH${NC}"
    exit 1
fi

APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
echo -e "\n${GREEN}✓ Build succeeded!${NC}"
echo -e "${CYAN}APK Path:${NC} ${APK_PATH}"
echo -e "${CYAN}APK Size:${NC} ${BOLD}${APK_SIZE}${NC}\n"

# Step 3: Ask Confirmation Before Uploading
echo -e "${BOLD}2. Confirmation${NC}"
echo -e "${GOLD}This will overwrite the existing APK in Firebase Storage.${NC}"
read -p "Do you want to upload this APK to Firebase now? [y/N]: " CONFIRM

case "$CONFIRM" in
    [yY][eE][sS]|[yY])
        echo -e "\n${BOLD}3. Authenticating with Firebase...${NC}"
        
        # Retrieve or refresh access token using node and configstore
        TOKEN=$(node -e "
            const fs = require('fs');
            const path = require('path');
            const os = require('os');
            const configPath = path.join(os.homedir(), '.config/configstore/firebase-tools.json');
            if (!fs.existsSync(configPath)) {
                console.error('Firebase CLI config not found at ' + configPath);
                process.exit(1);
            }
            let conf = JSON.parse(fs.readFileSync(configPath, 'utf8'));
            if (!conf.tokens || conf.tokens.expires_at <= Date.now() + 60000) {
                try {
                    require('child_process').execSync('npx --yes firebase-tools projects:list', { stdio: 'ignore' });
                    conf = JSON.parse(fs.readFileSync(configPath, 'utf8'));
                } catch (_) {}
            }
            if (!conf.tokens || !conf.tokens.access_token) {
                console.error('No access token available. Please run npx firebase-tools login');
                process.exit(1);
            }
            process.stdout.write(conf.tokens.access_token);
        ")

        if [ -z "$TOKEN" ]; then
            echo -e "${RED}Error: Could not retrieve Firebase authorization token.${NC}"
            echo -e "Please run: ${BOLD}npx firebase-tools login${NC}"
            exit 1
        fi

        echo -e "${GREEN}✓ Authorization confirmed.${NC}"
        echo -e "\n${BOLD}4. Uploading APK to Firebase Storage...${NC}"
        echo -e "Target: ${CYAN}gs://${BUCKET_NAME}/${DEST_PATH}${NC}"

        UPLOAD_URL="https://storage.googleapis.com/upload/storage/v1/b/${BUCKET_NAME}/o?uploadType=media&name=app_releases%2Fkapada_creation.apk"

        HTTP_RESPONSE=$(curl -# -w "\n%{http_code}" -X POST \
            -H "Authorization: Bearer ${TOKEN}" \
            -H "Content-Type: application/vnd.android.package-archive" \
            --data-binary "@${APK_PATH}" \
            "${UPLOAD_URL}")

        HTTP_CODE=$(echo "$HTTP_RESPONSE" | tail -n 1)

        if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 201 ]; then
            # Ensure downloads are named Kapadacreation.apk in all browsers
            curl -s -X PATCH \
                -H "Authorization: Bearer ${TOKEN}" \
                -H "Content-Type: application/json" \
                -d '{"contentDisposition": "attachment; filename=\"Kapadacreation.apk\""}' \
                "https://storage.googleapis.com/storage/v1/b/${BUCKET_NAME}/o/app_releases%2Fkapada_creation.apk" > /dev/null

            echo -e "\n${GREEN}${BOLD}✓ Upload Complete! Existing APK successfully replaced.${NC}\n"
            echo -e "${CYAN}File Name for Users:${NC} ${BOLD}Kapadacreation.apk${NC}"
            echo -e "${BOLD}${GOLD}==============================================${NC}"
            echo -e "${BOLD}Live Download URL:${NC}"
            echo -e "${CYAN}${PUBLIC_URL}${NC}"
            echo -e "${BOLD}${GOLD}==============================================${NC}\n"
        else
            echo -e "\n${RED}Upload failed with HTTP status: ${HTTP_CODE}${NC}"
            echo "$HTTP_RESPONSE"
            exit 1
        fi
        ;;
    *)
        echo -e "\n${GOLD}Upload cancelled. Build APK remains at:${NC} ${APK_PATH}\n"
        exit 0
        ;;
esac
