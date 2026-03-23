# 🎨 Your WezTerm Icons Are Ready!

## ✅ Icons Created Successfully

Two beautiful 3D icons have been created for you:

### 1. **Detailed 3D Version** (455 KB)
- `wezterm-icon.icns`
- Full terminal window with realistic 3D effects
- Perfect for large displays and high-resolution screens

### 2. **Minimal Version** (335 KB)
- `wezterm-icon-minimal.icns`
- Clean, modern design
- Looks better at small sizes (dock, taskbar)

---

## 🚀 Quick Apply

Choose your preferred version and run:

### Option A: Detailed 3D Icon
```bash
# 1. Backup original
cp /Applications/WezTerm.app/Contents/Resources/terminal.icns ~/Desktop/terminal-backup.icns

# 2. Apply new icon
sudo cp wezterm-icon.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns

# 3. Clear icon cache (REQUIRED)
sudo rm -rfv /Library/Caches/com.apple.iconservices.store
sudo rm -rfv ~/Library/Caches/com.apple.iconservices.store
touch /Applications/WezTerm.app && killall Dock
```

### Option B: Minimal Icon
```bash
# 1. Backup original
cp /Applications/WezTerm.app/Contents/Resources/terminal.icns ~/Desktop/terminal-backup.icns

# 2. Apply new icon
sudo cp wezterm-icon-minimal.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns

# 3. Clear icon cache (REQUIRED)
sudo rm -rfv /Library/Caches/com.apple.iconservices.store
sudo rm -rfv ~/Library/Caches/com.apple.iconservices.store
touch /Applications/WezTerm.app && killall Dock
```

---

## 📁 What You Got

```
docs/
├── ✅ wezterm-icon.svg              # Detailed 3D design (source)
├── ✅ wezterm-icon.icns             # Detailed 3D icon (ready to use)
├── ✅ wezterm-icon-minimal.svg      # Minimal design (source)
├── ✅ wezterm-icon-minimal.icns     # Minimal icon (ready to use)
├── 📖 README.md                     # Complete documentation
├── 🛠️ create-icon.sh                # Icon creation script
├── 🔧 make-icns.sh                  # Generic converter
└── 📚 creating-icns.md              # ICNS creation guide
```

---

## 🎨 Design Features

### Both Icons Include:
- ✨ **White "W"** letter prominently displayed
- 🎨 **Gradient purple** background (Purple → Indigo)
- 🖥️ **Terminal window** styling
- 🔘 **macOS window buttons** (red, yellow, green)
- 📐 **1024x1024** master size
- 🎯 **10 size variants** (16px to 1024px)

### Color Palette:
- **Purple Gradient**: `#9333EA` → `#7C3AED` → `#6366F1`
- **White Letter**: `#FFFFFF`
- **Terminal Frame**: `#1F1F1F`

---

## 🔄 Restore Original

To restore the original WezTerm icon:

```bash
sudo cp ~/Desktop/terminal-backup.icns /Applications/WezTerm.app/Contents/Resources/terminal.icns
touch /Applications/WezTerm.app
killall Dock
```

---

## 🎨 Want to Customize?

### Change Colors
Edit the SVG files and modify the gradient:

```xml
<linearGradient id="purpleGradient">
  <stop offset="0%" style="stop-color:#YOUR_COLOR" />
  <stop offset="100%" style="stop-color:#YOUR_COLOR" />
</linearGradient>
```

### Recreate Icons
After editing SVG files:

```bash
./create-icon.sh detailed   # Recreate detailed version
./create-icon.sh minimal    # Recreate minimal version
```

---

## 📱 Preview

The icons will appear in:
- ✅ macOS Dock
- ✅ Application Switcher (Cmd+Tab)
- ✅ Finder
- ✅ Launchpad
- ✅ Mission Control

---

## 🐛 Icon Not Changing?

macOS caches icons aggressively. Follow these steps:

### Quick Refresh (Try First)
```bash
touch /Applications/WezTerm.app && killall Dock
```

### Full Cache Clear (If Quick Refresh Doesn't Work)
```bash
# Clear system icon cache
sudo rm -rfv /Library/Caches/com.apple.iconservices.store

# Clear user icon cache
sudo rm -rfv ~/Library/Caches/com.apple.iconservices.store

# Refresh
touch /Applications/WezTerm.app && killall Dock
```

### Last Resort (macOS Sequoia 15.x+)
On newer macOS versions, you may need to:
1. Log out (Apple Menu → Log Out)
2. Log back in

### Verify Installation
```bash
# Check MD5 hash of installed icon
md5 /Applications/WezTerm.app/Contents/Resources/terminal.icns

# Compare with source (should match one of these)
md5 wezterm-icon.icns
md5 wezterm-icon-minimal.icns
```

---

## 📖 Full Documentation

For more details, see:
- `README.md` - Complete guide with customization options
- `creating-icns.md` - General ICNS creation tutorial

---

**Enjoy your beautiful new WezTerm icon! 🎉**

*Both icons feature a modern 3D design with white "W" on gradient purple background, styled as a terminal window.*
