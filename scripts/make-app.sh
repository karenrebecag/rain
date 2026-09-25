#!/usr/bin/env bash
# Builds build/lo-rain-oss.app from the Swift package; pass --install to copy it to /Applications.
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="lo-rain-oss"
BUNDLE_ID="com.karenrebecag.lo-rain-oss"
VERSION="${VERSION:-0.1.0}"
APP="build/${APP_NAME}.app"

swift build -c release
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/LoRainOSS "$APP/Contents/MacOS/LoRainOSS"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>LoRainOSS</string>
    <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
    <key>CFBundleName</key><string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key><string>${APP_NAME}</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>${VERSION}</string>
    <key>CFBundleVersion</key><string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key><string>12.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

# Ad-hoc signature: enough to run locally; distributing it to others needs a Developer ID.
codesign --force --sign - "$APP"
echo "Built $APP"

if [[ "${1:-}" == "--install" ]]; then
    pkill -x LoRainOSS 2>/dev/null || true
    rm -rf "/Applications/${APP_NAME}.app"
    ditto "$APP" "/Applications/${APP_NAME}.app"
    echo "Installed /Applications/${APP_NAME}.app"
fi
