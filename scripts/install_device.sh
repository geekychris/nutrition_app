#!/bin/bash

# Install to Device Script for Nutrition Tracker
# This script builds and installs the app directly to a connected iOS device

set -e

SCHEME="NutritionTracker"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0}}")/.." && pwd)"

echo "======================================"
echo "Install to Connected Device"
echo "======================================"
echo ""

# Check for connected devices
echo "Checking for connected devices..."
DEVICES=$(xcrun xctrace list devices 2>&1 | grep "iPhone\|iPad" | grep -v "Simulator" || true)

if [ -z "$DEVICES" ]; then
    echo "❌ No iOS devices connected!"
    echo ""
    echo "Please connect an iPhone or iPad via USB and try again."
    echo ""
    echo "Make sure to:"
    echo "  1. Trust this computer on your device"
    echo "  2. Enable Developer Mode in Settings → Privacy & Security"
    exit 1
fi

echo "Connected devices:"
echo "$DEVICES"
echo ""

# Get the first connected device ID
DEVICE_ID=$(xcrun xctrace list devices 2>&1 | grep "iPhone\|iPad" | grep -v "Simulator" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')

echo "Installing to device: $DEVICE_ID"
echo ""

# Build and install
cd "$PROJECT_DIR"
echo "Building and installing app..."

xcodebuild \
  -project "NutritionTracker.xcodeproj" \
  -scheme "$SCHEME" \
  -destination "id=$DEVICE_ID" \
  -configuration Debug \
  clean build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ App installed successfully!"
    echo ""
    echo "The app should now be available on your device."
    echo ""
    echo "Note: Development builds expire after:"
    echo "  - 7 days (free Apple ID)"
    echo "  - 1 year (paid Apple Developer account)"
else
    echo ""
    echo "❌ Installation failed!"
    echo ""
    echo "Common issues:"
    echo "  - Device not trusted: Check Settings → General → VPN & Device Management"
    echo "  - Code signing issue: Check Xcode → Preferences → Accounts"
    echo "  - Developer Mode not enabled: Settings → Privacy & Security → Developer Mode"
    exit 1
fi
