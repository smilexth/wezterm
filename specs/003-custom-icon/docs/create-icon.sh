#!/bin/bash
# Preview and convert wezterm icons
# Usage: ./create-icon.sh [variant]

set -e

VARIANT="${1:-detailed}"  # detailed or minimal
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$VARIANT" in
  detailed)
    SVG_FILE="$SCRIPT_DIR/wezterm-icon.svg"
    OUTPUT_NAME="wezterm-icon"
    echo "Using DETAILED variant (full terminal window with 3D effects)"
    ;;

  minimal)
    SVG_FILE="$SCRIPT_DIR/wezterm-icon-minimal.svg"
    OUTPUT_NAME="wezterm-icon-minimal"
    echo "Using MINIMAL variant (clean, works better at small sizes)"
    ;;

  *)
    echo "Unknown variant: $VARIANT"
    echo "Usage: $0 [detailed|minimal]"
    exit 1
    ;;
esac

if [ ! -f "$SVG_FILE" ]; then
  echo "Error: SVG file not found: $SVG_FILE"
  exit 1
fi

echo ""
echo "🎨 Creating WezTerm icon..."
echo "   Input: $SVG_FILE"
echo "   Output: ${OUTPUT_NAME}.icns"
echo ""

# Convert SVG to high-res PNG first
echo "Step 1/3: Converting SVG to PNG (1024x1024)..."

if command -v rsvg-convert &> /dev/null; then
  rsvg-convert -w 1024 -h 1024 "$SVG_FILE" > /tmp/temp_icon.png
  echo "   ✓ Using rsvg-convert (high quality)"
elif command -v convert &> /dev/null; then
  convert -background none -resize 1024x1024 "$SVG_FILE" /tmp/temp_icon.png
  echo "   ✓ Using ImageMagick"
else
  echo "   ✗ Error: Need rsvg-convert or ImageMagick"
  echo "   Install with: brew install librsvg"
  exit 1
fi

# Create iconset
echo ""
echo "Step 2/3: Generating all icon sizes..."
mkdir -p "${OUTPUT_NAME}.iconset"

# Generate all required sizes for macOS
sips -z 16 16     /tmp/temp_icon.png --out "${OUTPUT_NAME}.iconset/icon_16x16.png" 2>/dev/null
sips -z 32 32     /tmp/temp_icon.png --out "${OUTPUT_NAME}.iconset/icon_16x16@2x.png" 2>/dev/null
sips -z 32 32     /tmp/temp_icon.png --out "${OUTPUT_NAME}.iconset/icon_32x32.png" 2>/dev/null
sips -z 64 64     /tmp/temp_icon.png --out "${OUTPUT_NAME}.iconset/icon_32x32@2x.png" 2>/dev/null
sips -z 128 128   /tmp/temp_icon.png --out "${OUTPUT_NAME}.iconset/icon_128x128.png" 2>/dev/null
sips -z 256 256   /tmp/temp_icon.png --out "${OUTPUT_NAME}.iconset/icon_128x128@2x.png" 2>/dev/null
sips -z 256 256   /tmp/temp_icon.png --out "${OUTPUT_NAME}.iconset/icon_256x256.png" 2>/dev/null
sips -z 512 512   /tmp/temp_icon.png --out "${OUTPUT_NAME}.iconset/icon_256x256@2x.png" 2>/dev/null
sips -z 512 512   /tmp/temp_icon.png --out "${OUTPUT_NAME}.iconset/icon_512x512.png" 2>/dev/null
sips -z 1024 1024 /tmp/temp_icon.png --out "${OUTPUT_NAME}.iconset/icon_512x512@2x.png" 2>/dev/null

echo "   ✓ Generated 10 sizes (16px to 1024px)"

# Create ICNS
echo ""
echo "Step 3/3: Creating ICNS file..."
iconutil -c icns "${OUTPUT_NAME}.iconset" -o "${OUTPUT_NAME}.icns"

# Cleanup
rm -rf "${OUTPUT_NAME}.iconset"
rm /tmp/temp_icon.png

echo "   ✓ Created ${OUTPUT_NAME}.icns"

# Show preview if possible
if command -v open &> /dev/null; then
  echo ""
  echo "Preview:"
  open "${OUTPUT_NAME}.icns"
fi

echo ""
echo "✅ Success! Icon created: ${OUTPUT_NAME}.icns"
echo ""
echo "📦 To apply to WezTerm:"
echo "   sudo cp ${OUTPUT_NAME}.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns"
echo "   touch /Applications/WezTerm.app"
echo "   killall Dock"
echo ""
echo "🔄 To restore original:"
echo "   cp ~/Desktop/terminal-backup.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns"
echo ""
