#!/bin/bash

# Increment Build Number Script for Nutrition Tracker
# This script automatically increments the build number in the Xcode project

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INFO_PLIST="$PROJECT_DIR/NutritionTracker/Info.plist"

echo "======================================"
echo "Increment Build Number"
echo "======================================"
echo ""

# Get current build number using PlistBuddy
if [ -f "$INFO_PLIST" ]; then
    CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST" 2>/dev/null || echo "1")
else
    # If Info.plist doesn't exist, try to get it from project.pbxproj
    echo "⚠️  Info.plist not found, will use agvtool instead"
    cd "$PROJECT_DIR"
    CURRENT_BUILD=$(agvtool what-version -terse 2>/dev/null || echo "1")
fi

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))

echo "Current build number: $CURRENT_BUILD"
echo "New build number: $NEW_BUILD"
echo ""

# Update build number using agvtool
cd "$PROJECT_DIR"
agvtool new-version -all $NEW_BUILD

echo "✅ Build number incremented successfully!"
echo ""
echo "Note: Commit this change before building for distribution"
