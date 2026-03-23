# WezTerm Custom Icon Designs

Beautiful 3D icons for WezTerm terminal emulator featuring a white "W" on gradient purple background styled as a terminal window.

## 🎨 Design Variants

### 1. Detailed 3D Version (`wezterm-icon.svg`)

**Features:**
- ✨ Full 3D terminal window with depth and shadows
- 🎨 Gradient purple background (Purple → Indigo)
- 🔘 macOS-style window control buttons (red, yellow, green)
- 📝 Decorative terminal content lines
- 💫 Glossy overlay effects for realistic appearance
- 🌟 Large white "W" with embossed 3D effect
- ⌨️ Command prompt decoration ($)

**Best for:**
- Large displays
- High-resolution screens
- Users who love detailed, realistic icons

**Preview:**
```
┌─────────────────────┐
│ 🔴 🟡 🟢            │
│                     │
│      ╔═══╗          │
│      ║ W ║          │
│      ╚═══╝          │
│   $ █              │
└─────────────────────┘
```

---

### 2. Minimal Version (`wezterm-icon-minimal.svg`)

**Features:**
- 🎯 Clean, modern design
- 🎨 Purple-to-indigo gradient
- ⚪ Subtle terminal window outline
- 📐 Large, bold "W" letter
- 🌟 Minimal visual elements

**Best for:**
- Small sizes (16px - 64px)
- Dock and taskbar
- Users who prefer clean, simple designs

**Preview:**
```
┌───────────────┐
│ 🔴 🟡 🟢      │
│               │
│      W        │
│               │
└───────────────┘
```

---

## 🚀 Quick Start

### Option 1: Use the Ready-Made Script

```bash
cd specs/003-custom-icon/docs

# Create detailed version
./create-icon.sh detailed

# OR create minimal version
./create-icon.sh minimal
```

This will:
1. ✅ Convert SVG to PNG (1024x1024)
2. ✅ Generate all 10 required sizes
3. ✅ Create `.icns` file
4. ✅ Preview the icon (macOS)

---

### Option 2: Manual Conversion

```bash
# Using the generic script
./make-icns.sh wezterm-icon.svg
./make-icns.sh wezterm-icon-minimal.svg
```

---

## 🎯 Design Specifications

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| **Primary Purple** | `#9333EA` | Gradient start |
| **Secondary Purple** | `#7C3AED` | Gradient middle |
| **Indigo** | `#6366F1` | Gradient end |
| **White** | `#FFFFFF` | "W" letter |
| **Dark Frame** | `#1F1F1F` | Terminal window |
| **Title Bar** | `#2D2D2D` | Window header |

### Typography

- **Font**: SF Pro Display / -apple-system
- **Weight**: Bold / Heavy
- **Size**: 280px (detailed) / 320px (minimal)

### Dimensions

- **Canvas**: 1024x1024 pixels
- **Icon**: 896x896 pixels (with margins)
- **Window**: 664x568 pixels
- **"W"**: 280-320 points

---

## 📱 Icon Sizes

The scripts generate all required macOS icon sizes:

| Size | Filename | Usage |
|------|----------|-------|
| 16x16 | `icon_16x16.png` | Menu bar, small UI |
| 16x16 @2x | `icon_16x16@2x.png` | Retina small |
| 32x32 | `icon_32x32.png` | List views |
| 32x32 @2x | `icon_32x32@2x.png` | Retina medium |
| 128x128 | `icon_128x128.png` | Finder list |
| 128x128 @2x | `icon_128x128@2x.png` | Retina large |
| 256x256 | `icon_256x256.png` | Finder icons |
| 256x256 @2x | `icon_256x256@2x.png` | Retina XL |
| 512x512 | `icon_512x512.png` | Large previews |
| 512x512 @2x | `icon_512x512@2x.png` | Retina max |

---

## 🔧 Applying to WezTerm

### Step 1: Backup Original

```bash
cp /Applications/WezTerm.app/Contents/Resources/terminal.icns \
   ~/Desktop/terminal-backup.icns
```

### Step 2: Install Custom Icon

```bash
# Use detailed version
sudo cp wezterm-icon.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns

# OR use minimal version
sudo cp wezterm-icon-minimal.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns
```

### Step 3: Clear Icon Cache (Required)

macOS caches icons aggressively. **You must clear the cache** to see the new icon:

```bash
# Quick refresh (try this first)
touch /Applications/WezTerm.app && killall Dock
```

If the icon doesn't change, run the **full cache clear**:

```bash
# Clear system icon cache
sudo rm -rfv /Library/Caches/com.apple.iconservices.store

# Clear user icon cache
sudo rm -rfv ~/Library/Caches/com.apple.iconservices.store

# Restart services
killall Dock
```

> ⚠️ **Note**: On macOS Sequoia (15.x) and later, you may need to log out and back in for the cache to fully clear.

### Step 4: Verify

Close and reopen WezTerm. The new icon should appear in:
- Dock
- Application Switcher (Cmd+Tab)
- Finder
- Launchpad

---

## 🎨 Customization

### Change Colors

Edit the SVG files and modify the gradient stops:

```xml
<linearGradient id="purpleGradient" x1="0%" y1="0%" x2="100%" y2="100%">
  <stop offset="0%" style="stop-color:#YOUR_COLOR_1" />
  <stop offset="50%" style="stop-color:#YOUR_COLOR_2" />
  <stop offset="100%" style="stop-color:#YOUR_COLOR_3" />
</linearGradient>
```

**Popular color schemes:**

<details>
<summary>🌊 Ocean Blue</summary>

```xml
<stop offset="0%" style="stop-color:#0EA5E9" />
<stop offset="100%" style="stop-color:#0284C7" />
```
</details>

<details>
<summary>🌲 Forest Green</summary>

```xml
<stop offset="0%" style="stop-color:#10B981" />
<stop offset="100%" style="stop-color:#059669" />
```
</details>

<details>
<summary>🔥 Sunset Orange</summary>

```xml
<stop offset="0%" style="stop-color:#F97316" />
<stop offset="50%" style="stop-color:#EA580C" />
<stop offset="100%" style="stop-color:#C2410C" />
```
</details>

<details>
<summary>💎 Cyberpunk</summary>

```xml
<stop offset="0%" style="stop-color:#EC4899" />
<stop offset="50%" style="stop-color:#8B5CF6" />
<stop offset="100%" style="stop-color:#06B6D4" />
```
</details>

### Change the Letter

Edit the `<text>` element in the SVG:

```xml
<text ...>W</text>  <!-- Change W to any letter/character -->
```

---

## 🛠️ Requirements

### For Conversion

- **macOS** (for `iconutil` and `sips`)
- ** librsvg** OR **ImageMagick** (for SVG conversion)

Install via Homebrew:
```bash
brew install librsvg  # Recommended
# OR
brew install imagemagick
```

### For Editing

- **Vector Editor**: Inkscape (free), Figma, Sketch, Adobe Illustrator
- **Text Editor**: Any code editor (VS Code, Sublime Text, etc.)

---

## 📂 File Structure

```
docs/
├── README.md                    # This file
├── creating-icns.md            # General ICNS creation guide
├── make-icns.sh                # Generic PNG/SVG to ICNS converter
├── create-icon.sh              # WezTerm-specific converter
├── wezterm-icon.svg            # Detailed 3D design
├── wezterm-icon-minimal.svg    # Minimal clean design
├── wezterm-icon.icns           # Generated detailed icon
└── wezterm-icon-minimal.icns   # Generated minimal icon
```

---

## 🐛 Troubleshooting

### Icon Not Changing?

macOS caches icons aggressively. Follow these steps in order:

**Step 1: Quick Refresh**
```bash
touch /Applications/WezTerm.app && killall Dock
```

**Step 2: Clear Icon Cache**
```bash
sudo rm -rfv /Library/Caches/com.apple.iconservices.store
sudo rm -rfv ~/Library/Caches/com.apple.iconservices.store
killall Dock
```

**Step 3: Restart Finder**
```bash
killall Finder
```

**Step 4: Log Out/In (Last Resort)**

On macOS Sequoia (15.x) and later, the icon service may require a full logout:
- Log out (Apple Menu → Log Out)
- Log back in

**Verification**
```bash
# Check if custom icon is installed
md5 /Applications/WezTerm.app/Contents/Resources/terminal.icns

# Compare with source files
md5 wezterm-icon.icns
md5 wezterm-icon-minimal.icns
```

The hashes should match the version you installed.

### Icon Looks Blurry?

- ✅ Make sure all size variants are included (16-1024px)
- ✅ Start with high-resolution source (1024x1024)
- ✅ Use the detailed variant for large displays
- ✅ Use the minimal variant for better clarity at small sizes

### SVG Conversion Fails?

```bash
# Install librsvg (better SVG support)
brew install librsvg

# Or use ImageMagick
brew install imagemagick

# Verify installation
which rsvg-convert
which convert
```

---

## 📝 License

These icon designs are created for WezTerm users. Feel free to:
- ✅ Use for personal projects
- ✅ Modify and customize
- ✅ Share with others
- ✅ Use in any WezTerm-related project

WezTerm itself is licensed under MIT.

---

## 🙏 Credits

- **WezTerm**: https://wezfurlong.org/wezterm/
- **Design**: Custom 3D terminal window concept
- **Inspiration**: macOS Big Sur/Monterey icon design language

---

## 📸 Screenshots

The icons will appear in:
- macOS Dock
- Application Switcher (Cmd+Tab)
- Finder
- Launchpad
- Mission Control
- Notifications

---

## 🔗 Related

- [WezTerm Documentation](https://wezfurlong.org/wezterm/)
- [macOS Icon Design Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/app-icon/)
- [SVG Specification](https://www.w3.org/TR/SVG/)

---

**Enjoy your beautiful new WezTerm icon! 🎉**
