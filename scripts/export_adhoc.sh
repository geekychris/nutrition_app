#!/bin/bash

# Export Ad Hoc IPA Script for Nutrition Tracker
# This script exports an IPA file for ad hoc distribution to registered devices

set -e

# Configuration
SCHEME="NutritionTracker"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/NutritionTracker.xcarchive"
EXPORT_PATH="$BUILD_DIR/adhoc"

echo "======================================"
echo "Nutrition Tracker Ad Hoc Export"
echo "======================================"
echo ""

# Check if archive exists
if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ Archive not found at: $ARCHIVE_PATH"
    echo ""
    echo "Please run archive_and_export.sh first to create an archive."
    exit 1
fi

# Create export options plist for ad hoc
EXPORT_OPTIONS_PLIST="$BUILD_DIR/ExportOptionsAdHoc.plist"
cat > "$EXPORT_OPTIONS_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

echo "Export Options: $EXPORT_OPTIONS_PLIST"
echo ""
echo "⚠️  NOTE: You need to edit the script and set YOUR_TEAM_ID"
echo "    Find your Team ID in Apple Developer Portal"
echo ""

# Export IPA
echo "Exporting IPA..."
mkdir -p "$EXPORT_PATH"

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"

# Check if export was successful
if [ -f "$EXPORT_PATH/NutritionTracker.ipa" ]; then
    echo ""
    echo "✅ IPA exported successfully!"
    echo "IPA location: $EXPORT_PATH/NutritionTracker.ipa"
    echo ""
    echo "Distribution instructions:"
    echo "1. Share the IPA file with your testers"
    echo "2. Testers install via Finder (Mac) or iTunes/Apple Configurator (Windows)"
    echo "3. Devices must be registered in your developer portal"
    echo ""
    echo "To install on Mac:"
    echo "   - Connect iPhone/iPad"
    echo "   - Open Finder"
    echo "   - Drag IPA to device in sidebar"
    echo ""
else
    echo ""
    echo "❌ Export failed!"
    echo "Make sure you have:"
    echo "  - Valid provisioning profile for ad hoc distribution"
    echo "  - Devices registered in Apple Developer Portal"
    echo "  - Correct Team ID in export options"
    exit 1
fi
