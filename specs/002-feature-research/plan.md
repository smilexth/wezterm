# Implementation Plan: Feature Research - WezTerm Lua Configurations

**Branch**: `002-feature-research` | **Date**: 2026-03-19 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-feature-research/spec.md`

## Summary

Two Lua-based features for wezterm configuration:
1. **External Data Integration**: Display Home Assistant sensor values in wezterm status bar via REST API polling
2. **Local-Remote Path Mapping**: Enable clicking remote file paths in terminal to open local SMB-mounted files for Claude Code workflow

**Implementation**: Pure Lua configuration - no Rust code patches required.

## Technical Context

**Language/Version**: Lua 5.1-5.4 (wezterm embedded)
**Primary Dependencies**: wezterm built-in modules (`wezterm`, `wezterm.serde`, `wezterm.time`, `wezterm.gui`)
**Storage**: N/A (runtime state only, optional file cache for API responses)
**Testing**: Manual testing in wezterm, hot-reload via config save
**Target Platform**: macOS (primary), Linux (secondary)
**Project Type**: Configuration/scripts (not a code patch)
**Performance Goals**: <100ms status update, <50ms path translation
**Constraints**: No external Lua packages (wezterm embedded only)
**Scale/Scope**: 2 Lua modules, ~100-200 lines each

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Upstream Compatibility | ✅ PASS | No Rust patches - pure Lua config |
| II. Rust Code Quality | ✅ N/A | No Rust code changes |
| III. Targeted Patches | ✅ PASS | Each feature is focused, single-purpose |
| IV. Testing Requirements | ✅ PASS | Manual testing sufficient for config |
| V. Documentation | ✅ PASS | Will document in config comments + spec |

**Gate Status**: ✅ PASS - No violations

## Project Structure

### Documentation (this feature)

```text
specs/002-feature-research/
├── spec.md              # Feature specification ✅
├── plan.md              # This file ✅
├── research.md          # Phase 0 output
├── quickstart.md        # Phase 1 output
├── checklists/
│   └── requirements.md  # Quality checklist ✅
└── contracts/           # N/A - no API contracts
```

### Source Code (Lua configuration)

```text
config/
├── wezterm.lua          # Main config (user edits)
└── lua/
    ├── ha-status.lua    # Home Assistant status module
    └── path-mapper.lua  # Local-remote path mapping
```

**Structure Decision**: Single config directory at `~/.config/wezterm/` or user-defined location. Modules stored in `lua/` subdirectory per wezterm convention.

## Feature Breakdown

### Feature 1: Home Assistant Status

| Component | Description |
|-----------|-------------|
| `ha-status.lua` | Module for HA API communication |
| Polling timer | Periodic fetch (configurable interval) |
| Status display | Right-status bar integration |
| Error handling | Graceful fallback on API failure |

### Feature 2: Path Mapping

| Component | Description |
|-----------|-------------|
| `path-mapper.lua` | Path translation logic |
| Hyperlink rules | Detect remote paths in output |
| `open-uri` handler | Intercept and remap to local |
| SMB mount detection | Verify local path exists |

## Dependencies

| Dependency | Source | Purpose |
|------------|--------|---------|
| `wezterm.serde` | Built-in | JSON parsing for HA API |
| `wezterm.time` | Built-in | Timer for polling |
| `wezterm.gui` | Built-in | Window/status operations |
| HTTP client | LuaSocket (bundled) | API requests |

## Complexity Tracking

No constitution violations - pure configuration changes.

---

## Phase 0 Complete

Research not required - all technical details resolved in spec. Lua implementation path is straightforward using wezterm's built-in modules.
