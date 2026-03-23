# How to Find or Create .icns Files for WezTerm (macOS)

## Option 1: Find Existing .icns Files

### From Other Apps
Extract icons from installed macOS applications:

```bash
# List all .icns in an app bundle
ls /Applications/SomeApp.app/Contents/Resources/*.icns

# Copy an icon from another app
cp /Applications/Terminal.app/Contents/Resources/AppIcon.icns ~/my-custom.icns
```

### Online Resources
- **Icon Archives**:
  - https://macosicons.com
  - https://www.flaticon.com (filter for "icon format")
  - https://www.iconfinder.com

- **Open Source Icons**:
  - Search GitHub for `.icns` files
  - Check themes like https://github.com/dhanishgajjar/vscode-icons

### System Icons
macOS has built-in icons you can use:

```bash
# System icons location
/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/

# Example: Generic app icon
cp /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns ~/my-custom.icns
```

---

## Option 2: Create .icns from PNG/SVG

### Method A: Using `iconutil` (Built-in macOS)

**Step 1**: Create a high-resolution PNG (1024x1024 recommended)

**Step 2**: Generate all required sizes:

```bash
#!/bin/bash
# create-icns.sh - Convert PNG to ICNS

INPUT_PNG="your-icon.png"
OUTPUT_NAME="custom-icon"

# Create iconset directory
mkdir -p "${OUTPUT_NAME}.iconset"

# Generate all required sizes
sips -z 16 16     "${INPUT_PNG}" --out "${OUTPUT_NAME}.iconset/icon_16x16.png"
sips -z 32 32     "${INPUT_PNG}" --out "${OUTPUT_NAME}.iconset/icon_16x16@2x.png"
sips -z 32 32     "${INPUT_PNG}" --out "${OUTPUT_NAME}.iconset/icon_32x32.png"
sips -z 64 64     "${INPUT_PNG}" --out "${OUTPUT_NAME}.iconset/icon_32x32@2x.png"
sips -z 128 128   "${INPUT_PNG}" --out "${OUTPUT_NAME}.iconset/icon_128x128.png"
sips -z 256 256   "${INPUT_PNG}" --out "${OUTPUT_NAME}.iconset/icon_128x128@2x.png"
sips -z 256 256   "${INPUT_PNG}" --out "${OUTPUT_NAME}.iconset/icon_256x256.png"
sips -z 512 512   "${INPUT_PNG}" --out "${OUTPUT_NAME}.iconset/icon_256x256@2x.png"
sips -z 512 512   "${INPUT_PNG}" --out "${OUTPUT_NAME}.iconset/icon_512x512.png"
sips -z 1024 1024 "${INPUT_PNG}" --out "${OUTPUT_NAME}.iconset/icon_512x512@2x.png"

# Convert to icns
iconutil -c icns "${OUTPUT_NAME}.iconset" -o "${OUTPUT_NAME}.icns"

# Cleanup
rm -rf "${OUTPUT_NAME}.iconset"

echo "Created ${OUTPUT_NAME}.icns"
```

**Usage**:
```bash
chmod +x create-icns.sh
./create-icns.sh my-icon.png
```

---

### Method B: Using `sips` Quick Convert (Simple)

```bash
# One-liner for quick conversion (less optimal but works)
mkdir myicon.iconset
sips -z 512 512 your-icon.png --out myicon.iconset/icon_512x512.png
sips -z 256 256 your-icon.png --out myicon.iconset/icon_256x256.png
sips -z 128 128 your-icon.png --out myicon.iconset/icon_128x128.png
sips -z 32 32   your-icon.png --out myicon.iconset/icon_32x32.png
sips -z 16 16   your-icon.png --out myicon.iconset/icon_16x16.png
iconutil -c icns myicon.iconset -o output.icns
rm -rf myicon.iconset
```

---

### Method C: Using ImageMagick + png2icns

```bash
# Install tools (if needed)
brew install imagemagick libicns

# Convert SVG to ICNS
convert -background none -resize 1024x1024 input.svg temp.png

# Create ICNS (requires icon set)
mkdir iconset
for size in 16 32 128 256 512; do
  convert temp.png -resize ${size}x${size} iconset/icon_${size}px.png
done
png2icns output.icns iconset/*.png
rm -rf iconset temp.png
```

---

### Method D: Using Online Converters

**Free online tools**:
- https://cloudconvert.com/png-to-icns
- https://convertio.co/png-icns/
- https://www.aconvert.com/icon/png-to-icns/

**Steps**:
1. Upload your PNG (preferably 1024x1024 or at least 512x512)
2. Convert to ICNS
3. Download the result

---

## Option 3: Create from Scratch

### Using Design Tools

1. **Figma/Sketch/Adobe Illustrator**:
   - Create at 1024x1024 pixels
   - Export as PNG with transparency
   - Convert to ICNS using methods above

2. **Canva** (Free):
   - Create custom design
   - Download as PNG
   - Convert to ICNS

3. **macOS Preview** (Basic):
   - Create or edit image
   - Export as PNG
   - Convert to ICNS

### Recommended Specifications

- **Size**: 1024x1024 pixels (master)
- **Format**: PNG with transparency
- **Style**: Simple, clear, works at small sizes
- **Background**: Transparent or solid color

---

## Option 4: Use WezTerm's Existing Icon as Base

```bash
# Copy current wezterm icon to edit
cp /Applications/WezTerm.app/Contents/Resources/terminal.icns ~/Desktop/wezterm-original.icns

# Convert ICNS back to PNG for editing
sips -s format png ~/Desktop/wezterm-original.icns --out ~/Desktop/wezterm-original.png

# Edit the PNG in your favorite editor
open -a Preview ~/Desktop/wezterm-original.png

# Convert back to ICNS
# (Use Method A above)
```

---

## Quick Start: One-Command Solution

Save this as `make-icns.sh`:

```bash
#!/bin/bash
# Quick ICNS creator from any PNG/SVG

INPUT="$1"
NAME=$(basename "$INPUT" | sed 's/\.[^.]*$//')

if [ -z "$INPUT" ]; then
  echo "Usage: $0 <image.png|image.svg>"
  exit 1
fi

# Convert SVG to PNG first if needed
if [[ "$INPUT" == *.svg ]]; then
  echo "Converting SVG to PNG..."
  rsvg-convert -w 1024 -h 1024 "$INPUT" > /tmp/temp_icon.png 2>/dev/null || \
  convert -background none -resize 1024x1024 "$INPUT" /tmp/temp_icon.png
  INPUT="/tmp/temp_icon.png"
fi

# Create iconset
mkdir -p "${NAME}.iconset"

# Generate sizes
for size in 16 32 128 256 512; do
  sips -z $size $size "$INPUT" --out "${NAME}.iconset/icon_${size}x${size}.png" 2>/dev/null
  sips -z $((size*2)) $((size*2)) "$INPUT" --out "${NAME}.iconset/icon_${size}x${size}@2x.png" 2>/dev/null
done

# Create ICNS
iconutil -c icns "${NAME}.iconset" -o "${NAME}.icns"

# Cleanup
rm -rf "${NAME}.iconset"
[ -f /tmp/temp_icon.png ] && rm /tmp/temp_icon.png

echo "✓ Created ${NAME}.icns"
```

**Usage**:
```bash
chmod +x make-icns.sh
./make-icns.sh my-awesome-icon.png
./make-icns.sh icon.svg
```

---

## Apply to WezTerm

Once you have your `.icns` file:

```bash
# Backup original
cp /Applications/WezTerm.app/Contents/Resources/terminal.icns ~/Desktop/terminal-backup.icns

# Apply custom icon
sudo cp my-custom.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns

# Update icon cache
touch /Applications/WezTerm.app

# Optional: Clear icon cache if needed
sudo rm -rfv /Library/Caches/com.apple.iconservices.store
sudo rm -rfv ~/Library/Caches/com.apple.iconservices.store
killall Dock

echo "Icon updated! Restart WezTerm to see changes."
```

---

## Troubleshooting

**Icon not changing?**
```bash
# Force macOS to re-scan
sudo touch /Applications/WezTerm.app
killall Finder
killall Dock

# Or restart your Mac
sudo reboot
```

**Icon looks blurry?**
- Make sure you included all size variants (16 to 1024)
- Start with a high-resolution source (1024x1024 minimum)

**Permission denied?**
```bash
# Apps in /Applications need sudo
sudo cp my-icon.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns
```
