# Feature Specification: Custom Icon Support for WezTerm

**Feature Branch**: `003-custom-icon`
**Created**: 2026-03-22
**Status**: Draft
**Input**: User description: "change icon of wezterm"

## Research Findings

### Current Icon Implementation

- **Source**: Icons generated from `assets/icon/wezterm-icon.svg` via `assets/icon/update.sh`
- **Windows**: Icon embedded in executable at build time (`.ico` compiled into `.exe` via `wezterm-gui/build.rs`)
- **macOS**: Icon stored in app bundle at `WezTerm.app/Contents/Resources/terminal.icns` (referenced in `Info.plist`)
- **Linux**: Desktop file uses `Icon=org.wezfurlong.wezterm` (freedesktop icon theme spec)
- **Runtime**: X11/Wayland windows support `window.set_icon()` method for runtime icon changes

### Technical Constraints

**Windows**:
- ❌ **Requires rebuild** - Icon is embedded in executable binary at compile time
- Alternative: Resource editing tools (complex, not recommended)

**macOS**:
- ✅ **Can be changed** - Replace `.icns` file in app bundle (requires write access to bundle)
- ✅ Runtime window icon via `set_icon()` (limited to window decoration)

**Linux**:
- ✅ **Can be changed** - Modify desktop file or install custom icon in icon theme directory
- ✅ Runtime window icon via `set_icon()` (X11/Wayland)

### Recommended Approach

Given the platform differences, this feature should focus on:
1. **Runtime window icon customization** (cross-platform, works on X11/Wayland, limited on macOS/Windows)
2. **Documentation for manual app icon changes** (replace files in bundle/desktop file)
3. **Future consideration**: Build-time configuration for custom icons (requires rebuild)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Set Custom Window Icon (Priority: P1)

As a wezterm user on Linux (X11/Wayland), I want to personalize my terminal window by setting a custom icon so that I can distinguish my wezterm windows from other terminals and express my personal style.

**Why this priority**: This provides immediate value for Linux users with a practical, implementable solution that works at runtime without requiring application rebuild.

**Independent Test**: Can be fully tested by providing a custom PNG icon file, configuring it in wezterm.lua, and verifying the window icon changes in the taskbar/window decorations.

**Acceptance Scenarios**:

1. **Given** wezterm is running on Linux with X11/Wayland, **When** user specifies a custom icon file in configuration, **Then** new windows display the custom icon in window decorations and taskbar
2. **Given** a custom icon is configured, **When** user opens multiple wezterm windows, **Then** all windows consistently display the custom icon
3. **Given** an invalid icon file is specified, **When** wezterm starts, **Then** the default icon is used and a warning is logged

---

### User Story 2 - Manual Application Icon Customization (Priority: P2)

As a wezterm user, I want documentation on how to manually change the application icon for my platform so that I can customize the icon shown in my dock/taskbar/application launcher.

**Why this priority**: Provides a complete solution for users who want full app icon customization, acknowledging platform limitations without requiring complex code changes.

**Independent Test**: Can be tested by following the documentation for each platform and verifying the application icon changes in the OS-level UI (dock, taskbar, app launcher).

**Acceptance Scenarios**:

1. **Given** a macOS user wants to change the app icon, **When** they follow the documented steps to replace `terminal.icns` in the app bundle, **Then** the new icon appears in the dock and application switcher
2. **Given** a Linux user wants to change the app icon, **When** they follow the documented steps to install a custom icon in their icon theme or modify the desktop file, **Then** the new icon appears in their application launcher
3. **Given** a Windows user wants to change the app icon, **When** they follow the documented steps to rebuild wezterm with a custom icon, **Then** the new icon appears in the taskbar and executable properties

---

### User Story 3 - Reset to Default Icon (Priority: P3)

As a user who has customized my window icon, I want to easily revert to the default wezterm icon so that I can restore the original appearance if needed.

**Why this priority**: Users need a way to undo their customization. This provides a safety net and makes the feature less risky to use.

**Independent Test**: Can be tested by setting a custom icon, then removing the configuration, and verifying the default icon is restored.

**Acceptance Scenarios**:

1. **Given** a custom window icon is configured, **When** user removes the icon configuration, **Then** new windows display the default wezterm icon
2. **Given** a custom window icon is configured, **When** user sets the icon configuration to an empty value, **Then** the default icon is used for subsequent windows

---

### Edge Cases

- What happens when the specified icon file does not exist or cannot be read?
  - System should display the default icon and log a warning message with the file path
- How does the system handle icon files with invalid format or corruption?
  - System should validate the PNG format and fall back to default icon with user notification
- What happens when icon file dimensions are too small or too large?
  - System should scale the icon automatically to appropriate window manager sizes
- What happens when a user lacks permissions to read the icon file?
  - System should fall back to default icon and log an appropriate error message
- What happens on platforms without X11/Wayland (macOS, Windows)?
  - Configuration is accepted but window icon changes have no visual effect; users should use manual app icon customization
- What happens when relative path resolution fails?
  - System should fall back to default icon and log an error with path resolution details
- What happens if icon file is modified while wezterm is running?
  - New windows will load the updated icon; existing windows retain their original icon

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to specify a custom window icon file through Lua configuration
- **FR-002**: System MUST support PNG format for custom window icons (cross-platform compatibility)
- **FR-003**: System MUST validate icon files exist and are readable before applying them
- **FR-004**: System MUST fall back to the default icon if the custom icon cannot be loaded
- **FR-005**: System MUST apply the custom window icon to new windows on creation (X11/Wayland platforms)
- **FR-006**: Users MUST be able to revert to the default icon by removing or clearing the configuration
- **FR-007**: System MUST display a warning or error message when a configured icon cannot be loaded
- **FR-008**: System MUST support both absolute and relative file paths for icon configuration
- **FR-009**: System MUST apply icon changes to new windows immediately (existing windows unchanged)
- **FR-010**: System MUST provide documentation for manual application icon customization per platform
- **FR-011**: System MUST log appropriate warnings when custom icon loading fails (file not found, invalid format, permission denied)
- **FR-012**: Configuration MUST support profile-specific window icons that override global settings

### Key Entities

- **Custom Icon Configuration**: User-defined setting specifying the path to an icon file and optional profile association
- **Icon File**: Image file in platform-appropriate format containing the visual representation to be used as application icon
- **Profile**: Named configuration preset that can optionally have its own icon, overriding the global setting

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users on Linux (X11/Wayland) can successfully change window icons by modifying configuration and opening a new window (success rate: 95% of attempts on first try)
- **SC-002**: Custom window icons display correctly on X11/Wayland platforms within 1 second of window creation
- **SC-003**: Icon configuration and application process completes without requiring technical support (measured by reduction in icon-related support requests)
- **SC-004**: Users can revert to default window icon in under 30 seconds by removing configuration
- **SC-005**: System gracefully handles 100% of invalid icon scenarios (missing files, wrong format, corruption) without crashing
- **SC-006**: Documentation for manual application icon customization is clear enough that 80% of users can successfully change their app icon without additional support
- **SC-007**: Profile-specific icon configuration works correctly with inheritance (global → profile → default fallback chain)

## Assumptions

- Users will provide their own icon files in PNG format; wezterm will not include an icon library
- Window icon changes apply only to X11/Wayland platforms (Linux, Unix-like systems)
- Application icon changes on macOS require manual file replacement in the app bundle
- Application icon changes on Windows require rebuilding the application from source
- Relative paths will be resolved from the configuration file location
- Profile-specific icons will inherit from global icon configuration when not explicitly set
- The runtime window icon feature is separate from the OS-level application icon (dock/taskbar/app launcher)
- Icons will be loaded and applied when windows are created; existing windows are not updated
- PNG format provides sufficient quality and compatibility for window icons across platforms
- Users on Windows/macOS who want full application icon customization will follow manual documentation or rebuild
