# Research: WezTerm Lua Configuration Features

**Feature**: 002-feature-research
**Date**: 2026-03-19
**Status**: Complete

## Research Summary

This feature requires minimal external research - both implementations use wezterm's built-in Lua APIs. The following documents key decisions and patterns.

---

## Topic 1: WezTerm Status Bar Customization

### Decision
Use `wezterm.on("update-right-status", ...)` event with timer-based polling.

### Rationale
- Built-in event for status updates
- Can combine with `wezterm.time.call_after` for periodic refresh
- No external dependencies required

### Alternatives Considered

| Alternative | Rejected Because |
|-------------|------------------|
| Left status | Right status is conventional for system info |
| Tab title | Less visible, already used for pane info |
| Overlay | Intrusive, blocks content |

### Implementation Pattern

```lua
wezterm.on("update-right-status", function(window, pane)
  local status = fetch_external_data()
  window:set_right_status(wezterm.format({
    { Text = status },
  }))
end)
```

---

## Topic 2: HTTP Requests in WezTerm Lua

### Decision
Use `io.popen` with `curl` for HTTP requests (simplest approach).

### Rationale
- WezTerm's Lua environment may not have full LuaSocket
- `curl` is universally available on macOS/Linux
- JSON parsing via `wezterm.serde.json_decode()`

### Alternatives Considered

| Alternative | Rejected Because |
|-------------|------------------|
| LuaSocket | May not be available in embedded Lua |
| wezterm procinfo | Process info only, no HTTP |
| External script | More complex, harder to maintain |

### Implementation Pattern

```lua
local function http_get(url, headers)
  local header_args = ""
  for k, v in pairs(headers or {}) do
    header_args = header_args .. string.format("-H '%s: %s' ", k, v)
  end
  local handle = io.popen(string.format("curl -s %s '%s'", header_args, url))
  if handle then
    local response = handle:read("*a")
    handle:close()
    return response
  end
  return nil
end
```

---

## Topic 3: Hyperlink Rule Configuration

### Decision
Use `config.hyperlink_rules` for path detection, `wezterm.on("open-uri")` for interception.

### Rationale
- hyperlink_rules handles regex matching automatically
- open-uri event allows path transformation before opening
- Supports any file:// URL scheme

### Alternatives Considered

| Alternative | Rejected Because |
|-------------|------------------|
| Quick select | Requires user action, not automatic |
| Custom parser | Reinventing built-in functionality |
| OSC 8 links | Only works if server emits them |

### Implementation Pattern

```lua
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = [[(/home/[^/]+/[^\s]+)]],
  format = "file://$1",
})

wezterm.on("open-uri", function(window, pane, uri)
  if uri:sub(1, 7) == "file://" then
    local path = uri:sub(8)
    path = translate_to_local(path)
    if path_exists(path) then
      open_with_default_app(path)
      return false  -- Prevent default
    end
  end
  return true  -- Use default handling
end)
```

---

## Topic 4: SMB Mount Points (macOS)

### Decision
SMB shares mount at `/Volumes/<sharename>` by default on macOS.

### Rationale
- Standard macOS behavior
- User can customize mount point if needed
- Path validation ensures mount is active

### Common Mount Points

| Remote Path | Local Mount (macOS) |
|-------------|---------------------|
| //server/share | /Volumes/share |
| //192.168.1.100/data | /Volumes/data |

### Verification Pattern

```lua
local function path_exists(path)
  local stat = io.popen(string.format('test -e "%s" && echo 1', path))
  if stat then
    local result = stat:read("*a")
    stat:close()
    return result:find("1") ~= nil
  end
  return false
end
```

---

## Topic 5: Opening Files Locally

### Decision
Use `open` command on macOS, `xdg-open` on Linux.

### Rationale
- System default handlers
- Supports all file types
- No configuration needed

### Implementation Pattern

```lua
local function open_with_default_app(path)
  local opener = wezterm.target_triple:find("darwin") and "open" or "xdg-open"
  os.execute(string.format('%s "%s" &', opener, path))
end
```

---

## External References

1. [WezTerm Events Reference](https://wezterm.org/config/lua/wezterm.on.html)
2. [WezTerm Hyperlink Rules](https://wezterm.org/config/lua/config/hyperlink_rules.html)
3. [WezTerm Serde Module](https://wezterm.org/config/lua/wezterm.serde/index.html)
4. [Home Assistant REST API](https://developers.home-assistant.io/docs/api/rest/)
