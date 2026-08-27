# Feature Specification: Feature Research from WezTerm Docs

**Feature Branch**: `002-feature-research`
**Created**: 2026-03-19
**Status**: Closed (2026-08-27)
**Input**: User description: "research on feature i want to patch/create using docs guide from https://wezterm.org/index.html"

## Executive Summary

Research completed on wezterm documentation to identify potential feature/patch areas for the fork. This document catalogs wezterm's capabilities and highlights areas where custom patches or additions could provide value beyond upstream.

**Key Finding**: WezTerm is highly extensible via Lua configuration and plugins. Best patch candidates are:
1. Platform-specific optimizations (macOS, Linux)
2. Default behavior changes that upstream won't accept
3. New actions/key bindings not in upstream
4. Performance tuning for specific use cases

---

## Potential Patch Areas

### Category 1: Configuration Defaults

| Area | Description | Patch Viability |
|------|-------------|-----------------|
| Default key bindings | Override or add key bindings | High - config-based |
| Color schemes | Custom default theme | High - config-based |
| Font defaults | Fallback fonts, size, rules | High - config-based |
| Window appearance | Tabs, padding, opacity | High - config-based |

**Recommendation**: Most configuration changes don't require code patches - use `.wezterm.lua`.

### Category 2: New Actions/Key Bindings

WezTerm provides 100+ built-in actions. Potential additions:

| Action Type | Example | Implementation |
|-------------|---------|----------------|
| Pane management | Custom split ratios | Lua action |
| Tab management | Smart tab naming | Lua action |
| Search/selection | Custom quick select patterns | Lua config |
| URL handling | Custom URL opener | Lua action |
| Font control | Runtime font size adjustment | Built-in available |

**Recommendation**: Create custom Lua actions before patching Rust code.

### Category 3: Performance Patches

| Area | Current State | Potential Improvement |
|------|---------------|----------------------|
| FPS limits | Configurable max fps | Already configurable |
| Resize handling | Coalesces events | May need platform-specific tuning |
| Scrollback | Configurable limit | Memory vs performance trade-off |
| GPU rendering | Uses wgpu/metal/dx | Platform-specific fixes possible |

**Reference**: nazt's `x11resizecoalesce` patch improved X11 resize performance.

### Category 4: Platform-Specific Fixes

| Platform | Known Issues | Patch Potential |
|----------|--------------|-----------------|
| macOS | Gamma/color handling | Medium - may be fixed upstream |
| Linux X11 | Resize coalescing | Medium - performance tuning |
| Linux Wayland | Native integration | Low - active upstream work |
| Windows | ANGLE EGL issues | Medium - gamma fix exists |

**Recommendation**: Test current upstream before patching - many issues may be resolved.

### Category 5: New Features

| Feature | Complexity | Value | Notes |
|---------|------------|-------|-------|
| Custom image protocols | High | Medium | iTerm2/sixel supported |
| Plugin system extensions | Medium | High | Lua plugin API available |
| SSH enhancements | Medium | Medium | wezterm-ssh crate |
| Serial port improvements | Low | Low | Basic support exists |
| Session persistence | Medium | High | Multiplexer domain |

### Category 7: External Data Integration (User Request)

Display external data (REST API) in wezterm's UI, such as Home Assistant sensor values.

| Aspect | Details |
|--------|---------|
| **Use Case** | Show temperature, humidity, device status from Home Assistant in status bar |
| **Implementation** | Lua + `wezterm.serde` for JSON parsing + HTTP fetch |
| **Display Location** | Tab bar, status line, or right status area |
| **Refresh** | Timer-based polling (configurable interval) |

**Technical Approach**:
```lua
-- Example concept (Lua config, no code patch needed)
local function fetch_home_assistant()
  local http = require("socket.http")  -- or wezterm's built-in
  local data = wezterm.serde.json_decode(response)
  return data.attributes.temperature
end

wezterm.on("update-right-status", function(window, pane)
  window:set_right_status(fetch_home_assistant() .. "°C")
end)
```

**Complexity**: Low-Medium (Lua only, no Rust patch)
**Patch Required**: No - achievable via Lua configuration

---

### Category 8: Local-Remote Path Mapping for Claude Code (User Request)

Map local SMB/Samba share paths to remote paths so clicking file links in terminal opens local files, enabling Claude Code to read local files.

| Aspect | Details |
|--------|---------|
| **Use Case** | SSH into server, see file paths, click to open locally via SMB mount |
| **Components** | Path mapping, URL scheme handler, SMB mount integration |
| **Workflow** | Server path `/data/project/file.txt` → Local path `/Volumes/share/project/file.txt` |

**User Journey**:
1. SSH to remote server running Claude Code
2. Claude outputs file path `/home/user/project/image.png`
3. Click path in wezterm → Opens local SMB-mounted file
4. Claude Code can read local files when prompted

**Technical Approach**:

| Component | Implementation |
|-----------|----------------|
| Path mapping | Lua config with mapping table |
| Link detection | `wezterm.format` with hyperlink rules |
| File opener | Custom action using local file handler |
| SMB mount | OS-level (macOS Finder → Connect to Server) |

**Example Lua Config**:
```lua
local path_mappings = {
  ["/home/user/projects"] = "/Volumes/smbshare/projects",
  ["/data/workspace"] = "/Volumes/smbshare/workspace",
}

-- Custom hyperlink rule
config.hyperlink_rules = {
  {
    regex = [[(/home/user/[^\s]+)]],
    format = "file://$1",
    highlight = 1,
  },
}

-- Intercept and remap
wezterm.on("open-uri", function(window, pane, uri)
  if uri:find("file://") then
    local path = uri:gsub("file://", "")
    for remote, local_path in pairs(path_mappings) do
      path = path:gsub(remote, local_path)
    end
    wezterm.open_with(path)  -- Opens with local default app
    return false  -- Prevent default handling
  end
end)
```

**Complexity**: Medium (Lua config + potential Rust action for custom opener)
**Patch Required**: Likely No - achievable via Lua event handlers

---

### Integration Notes for Claude Code Workflow

| Step | Local Machine | Remote Server |
|------|---------------|---------------|
| 1 | Mount SMB share | - |
| 2 | SSH to server via wezterm | - |
| 3 | - | Claude Code outputs file path |
| 4 | Click path → Opens locally | - |
| 5 | Edit/preview locally | Changes sync via SMB |
| 6 | - | Claude reads updated file |

**SMB Setup (macOS)**:
```bash
# Mount SMB share
open "smb://server/share"

# Verify mount point
ls /Volumes/share
```

### Category 9: Local-to-Remote File Sharing (User Request)

Send files (screenshots, images) from local machine to remote server so Claude Code running remotely can read them.

| Aspect | Details |
|--------|---------|
| **Use Case** | Take screenshot locally → share to remote → Claude reads file |
| **Direction** | Local → Remote (reverse of Category 8) |
| **Mechanism** | SMB share acts as bidirectional bridge |
| **Trigger** | Key binding or action to capture and share |

**User Journey**:
1. Press key binding in wezterm (e.g., `Cmd+Shift+S`)
2. Select or paste file path (or take screenshot)
3. File copied to SMB share (synced to remote)
4. Remote path printed to terminal for Claude to read
5. Claude can now read the file from remote path

**Technical Approach**:

| Component | Implementation |
|-----------|----------------|
| Key binding | Lua action with `wezterm.action` |
| File picker | `os.execute` with macOS file dialog or screenshot |
| Copy to share | `cp` to SMB mount point |
| Path output | Print remote path to current pane |

**Example Lua Config**:
```lua
local wezterm = require "wezterm"
local path_mapper = require "lua.path-mapper"

-- Share local file to remote (via SMB)
local function share_file_to_remote(window, pane, local_path)
  -- Translate local path to remote path
  local remote_path = path_mapper.local_to_remote(local_path)

  if remote_path then
    -- File is already on SMB share, just output the path
    pane:inject_output(remote_path .. "\n")
  else
    -- Copy to SMB share first
    local share_path = "/Volumes/share/uploads/"
    os.execute(string.format('cp "%s" "%s"', local_path, share_path))
    local filename = local_path:match("([^/]+)$")
    pane:inject_output("/home/user/uploads/" .. filename .. "\n")
  end
end

-- Take screenshot and share
local function screenshot_and_share(window, pane)
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local local_path = string.format("/tmp/screenshot_%s.png", timestamp)
  local share_path = "/Volumes/share/uploads/"

  -- Take screenshot (macOS)
  os.execute(string.format('screencapture -i "%s"', local_path))

  -- Copy to share
  os.execute(string.format('cp "%s" "%s"', local_path, share_path))

  -- Output remote path for Claude
  pane:inject_output(string.format("/home/user/uploads/screenshot_%s.png\n", timestamp))
end

-- Key binding
config.keys = {
  {
    key = "s",
    mods = "CMD|SHIFT",
    action = wezterm.action.EmitEvent("screenshot-and-share"),
  },
}

wezterm.on("screenshot-and-share", function(window, pane)
  screenshot_and_share(window, pane)
end)
```

**Bidirectional Flow**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    LOCAL ↔ REMOTE FILE FLOW                     │
│                                                                 │
│  REMOTE → LOCAL (Category 8)         LOCAL → REMOTE (Category 9)│
│  ────────────────────────           ────────────────────────    │
│                                                                 │
│  Remote path output                 Take screenshot locally     │
│        ↓                                    ↓                   │
│  Click → Opens locally              Copy to SMB share           │
│                                        ↓                        │
│  [SMB Share - /Volumes/share ↔ /home/user/share]               │
│                                        ↓                        │
│                                  Output remote path to terminal │
│                                        ↓                        │
│                                  Claude reads file on remote    │
└─────────────────────────────────────────────────────────────────┘
```

**Complexity**: Low-Medium (Lua only, no Rust patch)
**Patch Required**: No - achievable via Lua key bindings and actions

---

### Category 6: Rendering/Graphics

| Area | Upstream Status | Fork Potential |
|------|-----------------|----------------|
| Sixel graphics | Supported | Bug fixes possible |
| iTerm2 images | Supported | Bug fixes possible |
| Kitty graphics | Partial | Enhancement possible |
| Font shaping | HarfBuzz | Complex changes |
| Ligatures | Supported | Config-based |

---

## Lua Module Capabilities

WezTerm exposes these modules for configuration:

| Module | Purpose | Patch Alternative |
|--------|---------|-------------------|
| `wezterm` | Core module, actions | Use for key bindings |
| `wezterm.color` | Color manipulation | Use for themes |
| `wezterm.gui` | GUI operations | Use for window control |
| `wezterm.mux` | Multiplexer control | Use for panes/tabs |
| `wezterm.plugin` | Plugin management | Extend functionality |
| `wezterm.procinfo` | Process information | System integration |
| `wezterm.serde` | JSON/TOML parsing | Config parsing |
| `wezterm.time` | Time utilities | Date formatting |
| `wezterm.url` | URL parsing | Link handling |

---

## Recommendations

### Before Patching

1. **Check if configurable**: Most "features" are Lua-configurable
2. **Check upstream issues**: Bug may already be fixed
3. **Check plugins**: Community may have solution
4. **Profile the problem**: Verify the issue exists

### Good Patch Candidates

- Platform-specific optimizations (macOS gamma, X11 resize)
- Default behavior changes upstream won't accept
- New actions requiring Rust code (rare - most are Lua)
- Performance tuning for specific workloads

### Avoid Patching

- Theming (Lua config)
- Key bindings (Lua config)
- Pane/tab layouts (Lua config)
- Font selection (Lua config)

---

## Success Criteria

- [x] SC-001: Research wezterm documentation for feature areas
- [x] SC-002: Identify patch-viable areas vs config-only changes
- [x] SC-003: Catalog Lua modules and their capabilities
- [x] SC-004: Provide actionable recommendations
- [x] SC-005: Document external data integration approach (Home Assistant)
- [x] SC-006: Document local-remote path mapping for Claude Code workflow

---

## Next Steps

### For External Data Integration (Home Assistant)
1. Test HTTP fetching in Lua using `wezterm.serde` for JSON
2. Configure right-status to display sensor data
3. Add refresh timer for polling

### For Local-Remote Path Mapping (Claude Code)
1. Define path mapping table for your SMB mount
2. Configure hyperlink rules for server paths
3. Implement `open-uri` event handler with path translation
4. Test end-to-end: SSH → click path → local open

### If Lua Proves Insufficient
1. Identify specific limitation
2. Design minimal Rust patch
3. Follow constitution guidelines for patch

## Assumptions

- User wants to add value beyond upstream wezterm
- Upstream compatibility remains priority (per constitution)
- Lua configuration is preferred over code patches when possible
- Patches should be minimal and targeted (per constitution)
