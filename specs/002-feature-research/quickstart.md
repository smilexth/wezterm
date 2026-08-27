# Quickstart: WezTerm Lua Configuration Features

**Feature**: 002-feature-research
**Setup Time**: ~10 minutes

## Prerequisites

- wezterm installed
- (Optional) Home Assistant instance with API access
- (Optional) SMB share mounted for remote path mapping

---

## Feature 1: Home Assistant Status

### Step 1: Get Home Assistant API Token

1. Open Home Assistant → Profile → Long-Lived Access Tokens
2. Create new token named "wezterm"
3. Copy the token

### Step 2: Create Config Directory

```bash
mkdir -p ~/.config/wezterm/lua
```

### Step 3: Create `ha-status.lua`

```lua
-- ~/.config/wezterm/lua/ha-status.lua
local wezterm = require "wezterm"

local HA_URL = "http://homeassistant.local:8123"
local HA_TOKEN = "YOUR_LONG_LIVED_TOKEN"
local HA_SENSOR = "sensor.temperature"

local function fetch_sensor()
  local url = string.format("%s/api/states/%s", HA_URL, HA_SENSOR)
  local cmd = string.format(
    'curl -s -H "Authorization: Bearer %s" "%s"',
    HA_TOKEN, url
  )
  local handle = io.popen(cmd)
  if handle then
    local response = handle:read("*a")
    handle:close()
    local ok, data = pcall(wezterm.serde.json_decode, response)
    if ok and data then
      return data.state, data.attributes.unit_of_measurement
    end
  end
  return nil, nil
end

local last_status = ""

wezterm.time.call_after(5, function()
  wezterm.time.call_every(60, function()
    local value, unit = fetch_sensor()
    if value then
      last_status = string.format("%s%s", value, unit or "")
    end
  end)
end)

return {
  get_status = function()
    return last_status
  end
}
```

### Step 4: Add to Main Config

```lua
-- ~/.config/wezterm/wezterm.lua
local wezterm = require "wezterm"
local ha_status = require "lua.ha-status"

wezterm.on("update-right-status", function(window, pane)
  local status = ha_status.get_status()
  window:set_right_status(wezterm.format({
    { Text = status or "" },
  }))
end)

return {}
```

### Step 5: Reload Config

Save the file - wezterm auto-reloads on save.

---

## Feature 2: Local-Remote Path Mapping

### Step 1: Mount SMB Share (macOS)

```bash
# Via Finder: Cmd+K → smb://server/share
# Or via terminal:
open "smb://your-server/share"
```

Verify mount:
```bash
ls /Volumes/share
```

### Step 2: Create `path-mapper.lua`

```lua
-- ~/.config/wezterm/lua/path-mapper.lua
local wezterm = require "wezterm"

-- Map remote paths to local SMB mount points
local PATH_MAPPINGS = {
  ["/home/user/projects"] = "/Volumes/share/projects",
  ["/home/user/data"] = "/Volumes/share/data",
  -- Add your mappings here
}

local function translate_path(remote_path)
  for remote_prefix, local_prefix in pairs(PATH_MAPPINGS) do
    if remote_path:sub(1, #remote_prefix) == remote_prefix then
      return remote_path:gsub("^" .. remote_prefix, local_prefix)
    end
  end
  return remote_path
end

local function path_exists(path)
  local stat = io.popen(string.format('[ -e "%s" ] && echo 1', path))
  if stat then
    local result = stat:read("*a")
    stat:close()
    return result:find("1") ~= nil
  end
  return false
end

local function open_file(path)
  local opener
  if wezterm.target_triple:find("darwin") then
    opener = "open"
  elseif wezterm.target_triple:find("linux") then
    opener = "xdg-open"
  else
    opener = "start"
  end
  os.execute(string.format('%s "%s" >/dev/null 2>&1 &', opener, path))
end

return {
  translate_path = translate_path,
  path_exists = path_exists,
  open_file = open_file,
  PATH_MAPPINGS = PATH_MAPPINGS,
}
```

### Step 3: Configure Hyperlink Rules

```lua
-- ~/.config/wezterm/wezterm.lua
local wezterm = require "wezterm"
local path_mapper = require "lua.path-mapper"

local config = {}

-- Default rules + custom path rule
config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
  regex = [[(/home/[^\s]+)]],
  format = "file://$1",
})

-- Handle file:// URLs with path translation
wezterm.on("open-uri", function(window, pane, uri)
  if uri:sub(1, 7) == "file://" then
    local remote_path = uri:sub(8)
    local local_path = path_mapper.translate_path(remote_path)

    if local_path ~= remote_path and path_mapper.path_exists(local_path) then
      path_mapper.open_file(local_path)
      return false  -- Prevent default handling
    end
  end
  return true  -- Use default
end)

return config
```

### Step 4: Test

1. SSH to your remote server
2. Run `ls /home/user/projects/somefile.txt`
3. Click the path in terminal output
4. File should open locally

---

## Combined Config Example

```lua
-- ~/.config/wezterm/wezterm.lua
local wezterm = require "wezterm"
local ha_status = require "lua.ha-status"
local path_mapper = require "lua.path-mapper"

local config = {}

-- Home Assistant status
wezterm.on("update-right-status", function(window, pane)
  local ha = ha_status.get_status()
  local right = {}
  if ha and ha ~= "" then
    table.insert(right, { Text = ha .. "  " })
  end
  window:set_right_status(wezterm.format(right))
end)

-- Path mapping hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = [[(/home/[^\s]+)]],
  format = "file://$1",
})

wezterm.on("open-uri", function(window, pane, uri)
  if uri:sub(1, 7) == "file://" then
    local remote_path = uri:sub(8)
    local local_path = path_mapper.translate_path(remote_path)
    if local_path ~= remote_path and path_mapper.path_exists(local_path) then
      path_mapper.open_file(local_path)
      return false
    end
  end
  return true
end)

return config
```

---

## Feature 3: Local-to-Remote Screenshot Sharing

### Step 1: Ensure SMB Share is Writable

```bash
# Verify write access
touch /Volumes/share/uploads/test.txt
rm /Volumes/share/uploads/test.txt
```

### Step 2: Add Screenshot Functions to `path-mapper.lua`

```lua
-- Add to ~/.config/wezterm/lua/path-mapper.lua

-- Reverse mapping: local path → remote path
local function local_to_remote(local_path)
  for remote_prefix, local_prefix in pairs(PATH_MAPPINGS) do
    if local_path:sub(1, #local_prefix) == local_prefix then
      return local_path:gsub("^" .. local_prefix:gsub("(%W)", "%%%1"), remote_prefix)
    end
  end
  return nil
end

-- Share a local file to remote (via SMB)
local function share_file(local_path, window, pane)
  -- Check if already on share
  local remote_path = local_to_remote(local_path)
  if remote_path then
    pane:inject_output(remote_path .. "\n")
    return remote_path
  end

  -- Copy to share
  local filename = local_path:match("([^/]+)$")
  local share_path = PATH_MAPPINGS["/home/user/uploads"] or "/Volumes/share/uploads/"
  os.execute(string.format('cp "%s" "%s"', local_path, share_path))

  -- Output remote path
  local remote = "/home/user/uploads/" .. filename
  pane:inject_output(remote .. "\n")
  return remote
end

-- Take screenshot and share
local function screenshot_and_share(window, pane)
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local local_path = string.format("/tmp/screenshot_%s.png", timestamp)

  -- Take screenshot (macOS interactive)
  os.execute(string.format('screencapture -i "%s"', local_path))

  -- Check if screenshot was taken
  local f = io.open(local_path, "r")
  if f then
    f:close()
    share_file(local_path, window, pane)
  end
end

-- Add to return table
return {
  translate_path = translate_path,
  local_to_remote = local_to_remote,
  path_exists = path_exists,
  open_file = open_file,
  share_file = share_file,
  screenshot_and_share = screenshot_and_share,
  PATH_MAPPINGS = PATH_MAPPINGS,
}
```

### Step 3: Add Key Binding to `wezterm.lua`

```lua
-- Add to ~/.config/wezterm/wezterm.lua
local path_mapper = require "lua.path-mapper"

local config = {}

-- ... existing config ...

-- Screenshot and share key binding
config.keys = config.keys or {}
table.insert(config.keys, {
  key = "s",
  mods = "CMD|SHIFT",
  action = wezterm.action.EmitEvent("screenshot-and-share"),
})

wezterm.on("screenshot-and-share", function(window, pane)
  path_mapper.screenshot_and_share(window, pane)
end)

return config
```

### Step 4: Test

1. Open wezterm with SSH to remote server
2. Press `Cmd+Shift+S`
3. Select screen area to capture
4. Remote path should appear in terminal
5. Claude can now read that file: "Please look at /home/user/uploads/screenshot_xxx.png"

---

## Combined Config Example (All 3 Features)

```lua
-- ~/.config/wezterm/wezterm.lua
local wezterm = require "wezterm"
local ha_status = require "lua.ha-status"
local path_mapper = require "lua.path-mapper"

local config = {}

-- Feature 1: Home Assistant status
wezterm.on("update-right-status", function(window, pane)
  local ha = ha_status.get_status()
  local right = {}
  if ha and ha ~= "" then
    table.insert(right, { Text = ha .. "  " })
  end
  window:set_right_status(wezterm.format(right))
end)

-- Feature 2: Path mapping hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = [[(/home/[^\s]+)]],
  format = "file://$1",
})

wezterm.on("open-uri", function(window, pane, uri)
  if uri:sub(1, 7) == "file://" then
    local remote_path = uri:sub(8)
    local local_path = path_mapper.translate_path(remote_path)
    if local_path ~= remote_path and path_mapper.path_exists(local_path) then
      path_mapper.open_file(local_path)
      return false
    end
  end
  return true
end)

-- Feature 3: Screenshot sharing
config.keys = {
  {
    key = "s",
    mods = "CMD|SHIFT",
    action = wezterm.action.EmitEvent("screenshot-and-share"),
  },
}

wezterm.on("screenshot-and-share", function(window, pane)
  path_mapper.screenshot_and_share(window, pane)
end)

return config
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Status not updating | Check HA URL and token, test curl manually |
| Paths not clickable | Verify hyperlink_rules regex matches your paths |
| Files won't open | Check SMB mount is active: `ls /Volumes/share` |
| Screenshot not appearing | Check screencapture permissions in System Preferences |
| Remote path wrong | Update PATH_MAPPINGS with correct paths |
| Claude can't read file | Verify file exists at remote path, check permissions |

## Next Steps

- Customize `PATH_MAPPINGS` for your environment
- Add multiple HA sensors
- Adjust polling interval in `ha-status.lua`
- Add file picker dialog for sharing arbitrary files
- Add keyboard shortcut to share clipboard image
