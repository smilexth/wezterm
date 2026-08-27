# Spec Closed: 002-feature-research

**Closed**: 2026-08-27
**Status at close**: All 30 tasks done except manual tests (T010, T018, T025, T030).

## Why closed

- The deliverable was never code in this repo — it is the Lua config living at
  `~/.config/wezterm/` (`wezterm.lua`, `lua/ha-status.lua`, `lua/path-mapper.lua`,
  plus a US4 clipboard-detect feature added beyond the original scope).
- Keeping the spec open buys nothing: no remaining task touches this repo, and
  the open items are "try it in a live terminal", which the user has been doing
  in daily use since March.

## What was kept

- `spec.md`, `plan.md`, `research.md`, `quickstart.md`, `tasks.md`,
  `checklists/requirements.md` — full paper trail of what was built and how to
  rebuild it from scratch (quickstart has copy-paste Lua for all three user
  stories).
- Note: `config.mouse_bindings` must stay unset in the user's `wezterm.lua` —
  custom bindings break Shift+Click link opening inside tmux on this setup.
  Documented in the dotfiles memory; applies to any future edit of that file.

## Follow-ups spawned

- None open. Ideas that were floated (file picker for sharing, clipboard-image
  shortcut) were either implemented (US4 clipboard auto-share) or dropped as
  not worth it.
