# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is WezTerm

A GPU-accelerated cross-platform terminal emulator and multiplexer written in Rust. User-facing configuration is done via Lua. Docs at https://wezterm.org/.

## Build Commands

```bash
cargo check                          # Fast type-check (preferred while iterating)
cargo check -p <crate>               # Type-check a single crate
cargo build -p wezterm -p wezterm-gui -p wezterm-mux-server  # Build main binaries
cargo run                            # Run in debug mode (slow, but better backtraces)
cargo nextest run                    # Run all tests (preferred over cargo test)
cargo nextest run -p wezterm-escape-parser  # Run tests for a single crate
cargo nextest run -p <crate> -- <test_name> # Run a single test
cargo +nightly fmt                   # Format code (requires nightly toolchain)
cargo fmt --all                      # Format all code (stable toolchain)
```

The `Makefile` wraps these: `make check`, `make test`, `make build`, `make fmt`. The `no_std` crates — `wezterm-escape-parser`, `wezterm-cell`, `wezterm-surface`, and `wezterm-ssh` — must be checked/tested in isolation to catch accidental `std` dependencies. `make check` and `make test` already do this. Don't collapse those into a single `cargo check`.

### Debugging

- `RUST_BACKTRACE=1 cargo run` — debug build with a readable backtrace on panic.
- For inspecting locals on panic: `cargo build && gdb ./target/debug/wezterm`, then `break rust_panic` before `run`.

### Docs

```bash
ci/build-docs.sh          # Build documentation (uses mkdocs)
ci/build-docs.sh serve     # Serve docs locally with live reload
```

### System Dependencies

Run `./get-deps` to install OS-level build dependencies (platform-specific). Use `./get-deps --testing` for test dependencies, `./get-deps --docs` for doc build dependencies.

## Architecture

This is a Cargo workspace with many crates. The key ones and their roles:

- **`term/`** (`wezterm-term`) — Core terminal emulation model. Handles escape sequences, screen buffer, input processing. Agnostic of any windowing system. Aims for xterm compatibility (ref: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html).
- **`wezterm-gui/`** — The GUI renderer. Uses wgpu for GPU-accelerated rendering (shaders in `shader.wgsl`, `glyph-*.glsl`). The main rendering logic lives in `wezterm-gui/src/termwindow/`.
- **`wezterm/`** — The main CLI binary (`wezterm` command). Contains CLI subcommands and the asciicast recorder.
- **`wezterm-mux-server/`** — The multiplexer server binary for remote/detached sessions.
- **`mux/`** — Multiplexer core: manages panes, tabs, domains (local, SSH, remote mux client).
- **`config/`** — Configuration parsing and types. Lua config is evaluated here. All config structs live in `config/src/`. Has a derive macro crate at `config/derive/` providing `#[derive(ConfigMeta)]`.
- **`window/`** — Cross-platform windowing abstraction. Platform backends in `window/src/os/` (macOS/Cocoa, X11, Wayland, Windows).
- **`termwiz/`** — Terminal widget library. Provides terminal capabilities, input handling, line editing, rendering, and widgets. Also usable as a standalone library.
- **`wezterm-font/`** — Font discovery, loading, shaping (via HarfBuzz), and rasterization (via FreeType). Platform font backends (CoreText, DirectWrite, Fontconfig).
- **`wezterm-ssh/`** — SSH client implementation wrapping libssh2/libssh-rs.
- **`wezterm-client/`** — Client-side mux protocol for connecting to `wezterm-mux-server`.
- **`lua-api-crates/`** — Lua API bindings exposed to user config scripts. Each subdirectory is a separate crate (battery, color-funcs, filesystem, mux, window-funcs, etc.). Each crate exposes a `pub fn register(lua: &Lua)` entry point.
- **`codec/`** — Serialization codec for the mux client-server protocol.
- **`wezterm-dynamic/`** — Dynamic value type system with `FromDynamic`/`ToDynamic` derive macros. This is the bridge between Lua values and Rust types — most config/API types derive these traits.
- **`luahelper/`** — Utilities for Rust↔Lua type conversion. Provides `impl_lua_conversion_dynamic!` macro that implements `IntoLua`/`FromLua` via the `ToDynamic`/`FromDynamic` traits.
- **`deps/`** — Vendored C dependencies (cairo, freetype, harfbuzz, fontconfig).

### Data Flow

1. User config (Lua) → `config/` parses and resolves
2. `window/` creates platform window → `wezterm-gui/` sets up GPU rendering
3. PTY output → `term/` processes escape sequences → updates screen model
4. `wezterm-gui/` reads terminal state → renders via wgpu
5. Keyboard/mouse input → `window/` → `wezterm-gui/` → key bindings (`config/`) → actions dispatched to `mux/` panes

### Lua ↔ Rust Type Pattern

When adding config options or Lua-exposed types, the standard pattern is:
1. Derive `FromDynamic` and `ToDynamic` on the Rust type (from `wezterm-dynamic`)
2. Use `impl_lua_conversion_dynamic!(TypeName)` (from `luahelper`) to bridge Lua conversion
3. Config structs in `config/src/` also derive `ConfigMeta` (from `config/derive/`)

### Lua Configuration

WezTerm embeds Lua (via `mlua` crate). Config files are `~/.wezterm.lua` or `~/.config/wezterm/wezterm.lua`. The Lua API crates in `lua-api-crates/` expose Rust functionality to Lua.

## Code Style

- Rust, following standard Rust conventions
- Format with `cargo +nightly fmt` before submitting
- Lua code is formatted with StyLua (config in `ci/stylua.toml`: 78 cols, 2-space indent, single quotes)
- Tests go alongside code or in `test/` subdirectories within crates
- For escape-sequence / terminal-behavior tests, see the helpers in `term/src/test/` — `TestTerm` sets up a headless terminal and lets you assert on screen contents
