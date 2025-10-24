#!/bin/bash

# Archive and Export Script for Nutrition Tracker
# This script archives the app for distribution via TestFlight or App Store

set -e

# Configuration
SCHEME="NutritionTracker"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/NutritionTracker.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"

echo "======================================"
echo "Nutrition Tracker Archive Script"
echo "======================================"
echo ""
echo "Project Directory: $PROJECT_DIR"
echo "Scheme: $SCHEME"
echo ""

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Archive the app
echo ""
echo "Archiving app..."
xcodebuild archive \
  -project "$PROJECT_DIR/NutritionTracker.xcodeproj" \
  -scheme "$SCHEME" \
  -archivePath "$ARCHIVE_PATH" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  DEVELOPMENT_TEAM="" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGN_STYLE="Automatic" \
  | xcpretty || xcodebuild archive \
    -project "$PROJECT_DIR/NutritionTracker.xcodeproj" \
    -scheme "$SCHEME" \
    -archivePath "$ARCHIVE_PATH" \
    -configuration Release \
    -destination "generic/platform=iOS"

# Check if archive was successful
if [ -d "$ARCHIVE_PATH" ]; then
    echo ""
    echo "✅ Archive created successfully!"
    echo "Archive location: $ARCHIVE_PATH"
    echo ""
    echo "Next steps:"
    echo "1. Open Xcode"
    echo "2. Go to Window → Organizer"
    echo "3. Select the archive"
    echo "4. Click 'Distribute App'"
    echo "5. Choose your distribution method:"
    echo "   - App Store Connect (for TestFlight/App Store)"
    echo "   - Ad Hoc (for specific devices)"
    echo "   - Development (for testing)"
    echo ""
else
    echo ""
    echo "❌ Archive failed!"
    exit 1
fi
