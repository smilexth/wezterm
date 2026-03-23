#!/bin/bash
# Quick ICNS creator from any PNG/SVG
# Usage: ./make-icns.sh <image.png|image.svg>

set -e

INPUT="$1"
NAME=$(basename "$INPUT" | sed 's/\.[^.]*$//')

if [ -z "$INPUT" ]; then
  echo "Usage: $0 <image.png|image.svg>"
  echo "Creates an .icns file suitable for macOS applications"
  exit 1
fi

if [ ! -f "$INPUT" ]; then
  echo "Error: File not found: $INPUT"
  exit 1
fi

echo "Creating ICNS from: $INPUT"

# Convert SVG to PNG first if needed
if [[ "$INPUT" == *.svg ]]; then
  echo "Converting SVG to PNG..."

  # Try rsvg-convert first (better quality)
  if command -v rsvg-convert &> /dev/null; then
    rsvg-convert -w 1024 -h 1024 "$INPUT" > /tmp/temp_icon.png
  # Fall back to ImageMagick
  elif command -v convert &> /dev/null; then
    convert -background none -resize 1024x1024 "$INPUT" /tmp/temp_icon.png
  else
    echo "Error: Need rsvg-convert or ImageMagick for SVG conversion"
    echo "Install with: brew install librsvg or brew install imagemagick"
    exit 1
  fi

  INPUT="/tmp/temp_icon.png"
fi

# Create iconset directory
mkdir -p "${NAME}.iconset"

echo "Generating icon sizes..."

# Generate all required sizes for macOS
sips -z 16 16     "$INPUT" --out "${NAME}.iconset/icon_16x16.png" 2>/dev/null
sips -z 32 32     "$INPUT" --out "${NAME}.iconset/icon_16x16@2x.png" 2>/dev/null
sips -z 32 32     "$INPUT" --out "${NAME}.iconset/icon_32x32.png" 2>/dev/null
sips -z 64 64     "$INPUT" --out "${NAME}.iconset/icon_32x32@2x.png" 2>/dev/null
sips -z 128 128   "$INPUT" --out "${NAME}.iconset/icon_128x128.png" 2>/dev/null
sips -z 256 256   "$INPUT" --out "${NAME}.iconset/icon_128x128@2x.png" 2>/dev/null
sips -z 256 256   "$INPUT" --out "${NAME}.iconset/icon_256x256.png" 2>/dev/null
sips -z 512 512   "$INPUT" --out "${NAME}.iconset/icon_256x256@2x.png" 2>/dev/null
sips -z 512 512   "$INPUT" --out "${NAME}.iconset/icon_512x512.png" 2>/dev/null
sips -z 1024 1024 "$INPUT" --out "${NAME}.iconset/icon_512x512@2x.png" 2>/dev/null

# Create ICNS
echo "Converting to ICNS format..."
iconutil -c icns "${NAME}.iconset" -o "${NAME}.icns"

# Cleanup
rm -rf "${NAME}.iconset"
[ -f /tmp/temp_icon.png ] && rm /tmp/temp_icon.png

echo ""
echo "✓ Success! Created: ${NAME}.icns"
echo ""
echo "To apply to WezTerm:"
echo "  sudo cp ${NAME}.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns"
echo "  touch /Applications/WezTerm.app"
echo ""
