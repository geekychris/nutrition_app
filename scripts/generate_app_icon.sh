#!/bin/bash

# Generate App Icon for Nutrition Tracker
# Uses ImageMagick to create a nutrition-themed icon

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ICON_DIR="$PROJECT_DIR/NutritionTracker/Assets.xcassets/AppIcon.appiconset"
OUTPUT_FILE="$ICON_DIR/icon_1024.png"

echo "======================================"
echo "Nutrition Tracker Icon Generator"
echo "======================================"
echo ""

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo "❌ ImageMagick not found!"
    echo "Install with: brew install imagemagick"
    exit 1
fi

echo "Generating app icon..."
echo "Output: $OUTPUT_FILE"
echo ""

# Create the icon using ImageMagick
magick -size 1024x1024 \
    -define gradient:angle=180 \
    gradient:'#4CAF50-#90EE90' \
    \( -size 768x768 xc:none \
        -fill white \
        -draw "circle 384,384 384,0" \
    \) \
    -gravity center -composite \
    \( -size 300x340 xc:none \
        -fill '#DC3545' \
        -draw "ellipse 100,170 80,100 0,360" \
        -draw "ellipse 200,170 80,100 0,360" \
        -draw "ellipse 150,150 40,40 0,360" \
        -fill white -draw "ellipse 150,120 20,20 0,360" \
        -fill '#654321' -draw "rectangle 142,40 158,100" \
        -fill '#4CAF50' -draw "polygon 158,55 185,45 195,75 170,85" \
        -fill 'rgba(255,255,255,0.3)' -draw "ellipse 90,130 35,35 0,360" \
    \) \
    -gravity center -composite \
    "$OUTPUT_FILE"

if [ -f "$OUTPUT_FILE" ]; then
    echo "✅ App icon created successfully!"
    echo ""
    echo "Icon details:"
    echo "  File: $(basename "$OUTPUT_FILE")"
    echo "  Size: 1024x1024 pixels"
    echo "  Location: $ICON_DIR"
    echo ""
    echo "Next steps:"
    echo "1. Open Xcode"
    echo "2. Select Assets.xcassets in the project navigator"
    echo "3. Click on AppIcon"
    echo "4. Drag icon_1024.png into the 1024x1024 slot"
    echo "   (or Xcode will auto-populate it)"
    echo "5. Build and run to see your new icon!"
    echo ""
    
    # Update Contents.json to reference the new icon
    cat > "$ICON_DIR/Contents.json" <<EOF
{
  "images" : [
    {
      "filename" : "icon_1024.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    
    echo "✅ Contents.json updated to reference icon_1024.png"
    echo ""
    echo "🎉 All done! Your app now has a custom icon."
else
    echo "❌ Failed to create icon!"
    exit 1
fi
