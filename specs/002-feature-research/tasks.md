---

description: "Task list for WezTerm Lua Configuration Features"
---

# Tasks: WezTerm Lua Configuration Features

**Input**: Design documents from `/specs/002-feature-research/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, quickstart.md ✅

**Tests**: Manual testing only - no automated tests for Lua config.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Path Conventions

- **Config location**: `~/.config/wezterm/` (user's local config)
- **Lua modules**: `~/.config/wezterm/lua/`
- **Main config**: `~/.config/wezterm/wezterm.lua`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create config directory structure

- [x] T001 Create wezterm config directory at ~/.config/wezterm/
- [x] T002 Create lua modules directory at ~/.config/wezterm/lua/

**Checkpoint**: ✅ Directory structure ready

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: None required - both features are independent

**⚠️ NOTE**: No foundational tasks needed - each feature is self-contained Lua module.

**Checkpoint**: Skip to user story implementation

---

## Phase 3: User Story 1 - Home Assistant Status (Priority: P1) 🎯 MVP

**Goal**: Display Home Assistant sensor values in wezterm status bar via REST API polling

**Independent Test**: Can be tested by opening wezterm and verifying sensor value appears in right status area

### Implementation for User Story 1

- [x] T003 [US1] Create ha-status.lua module at ~/.config/wezterm/lua/ha-status.lua
- [x] T004 [US1] Add HTTP fetch function using curl via io.popen in ha-status.lua
- [x] T005 [US1] Add JSON parsing using wezterm.serde.json_decode in ha-status.lua
- [x] T006 [US1] Add polling timer using wezterm.time.call_every in ha-status.lua
- [x] T007 [US1] Add error handling for API failures in ha-status.lua
- [x] T008 [US1] Export get_status() function from ha-status.lua module
- [x] T009 [US1] Add update-right-status event handler to main config at ~/.config/wezterm/wezterm.lua
- [ ] T010 [US1] Test sensor value displays in wezterm status bar (manual test required)

**Checkpoint**: ✅ Home Assistant status implemented (awaiting user test)

---

## Phase 4: User Story 2 - Local-Remote Path Mapping (Priority: P2)

**Goal**: Enable clicking remote file paths in terminal to open local SMB-mounted files

**Independent Test**: SSH to remote server, output a file path, click path in terminal, verify local file opens

### Implementation for User Story 2

- [x] T011 [US2] Create path-mapper.lua module at ~/.config/wezterm/lua/path-mapper.lua
- [x] T012 [US2] Add PATH_MAPPINGS table with remote-to-local path mappings in path-mapper.lua
- [x] T013 [US2] Add translate_path() function for path translation in path-mapper.lua
- [x] T014 [US2] Add path_exists() function using shell test in path-mapper.lua
- [x] T015 [US2] Add open_file() function with platform detection (macOS/Linux) in path-mapper.lua
- [x] T016 [US2] Add custom hyperlink rule for /home/ paths to wezterm.lua
- [x] T017 [US2] Add open-uri event handler with path translation to wezterm.lua
- [ ] T018 [US2] Test SSH to remote server, click file path, verify local file opens (manual test required)

**Checkpoint**: ✅ Path mapping implemented (awaiting user test)

---

## Phase 5: User Story 3 - Local-to-Remote File Sharing (Priority: P3)

**Goal**: Send screenshots/files from local machine to remote server so Claude Code can read them

**Independent Test**: Press key binding, take screenshot, verify remote path appears in terminal for Claude to read

### Implementation for User Story 3

- [x] T019 [US3] Add local_to_remote() function to path-mapper.lua for reverse mapping
- [x] T020 [US3] Add share_file_to_remote() function to copy files to SMB share in path-mapper.lua
- [x] T021 [US3] Add screenshot_and_share() function using macOS screencapture in path-mapper.lua
- [x] T022 [US3] Add key binding Cmd+Shift+S for screenshot-and-share in wezterm.lua
- [x] T023 [US3] Add wezterm.on event handler for screenshot-and-share in wezterm.lua
- [x] T024 [US3] Add pane:inject_output() to print remote path to terminal in wezterm.lua
- [ ] T025 [US3] Test: press key, take screenshot, verify remote path output, verify Claude can read file (manual test required)

**Checkpoint**: ✅ Local-to-remote sharing implemented (awaiting user test)

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Integration, documentation, and refinements

- [x] T026 [P] Add inline documentation to ha-status.lua
- [x] T027 [P] Add inline documentation to path-mapper.lua
- [x] T028 Create combined wezterm.lua example with all three features integrated
- [x] T029 Add configuration comments for easy customization (API URL, paths, share location)
- [ ] T030 Test all three features work together without conflicts (manual test required)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Skipped - no shared prerequisites
- **User Story 1 (Phase 3)**: Depends on Setup only - can start after T001-T002
- **User Story 2 (Phase 4)**: Depends on Setup only - can start after T001-T002
- **Polish (Phase 5)**: Depends on user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Independent - no dependencies on other stories
- **User Story 2 (P2)**: Independent - no dependencies on other stories
- **User Story 3 (P3)**: Depends on US2 (extends path-mapper.lua)

### Within Each User Story

For US1:
- T003 (create module) first
- T004-T008 (core functions) can run in sequence
- T009 (event handler) depends on T008
- T010 (testing) last

For US2:
- T011 (create module) first
- T012-T015 (core functions) can run in sequence
- T016-T017 (config integration) depend on T011-T015
- T018 (testing) last

For US3:
- T019-T021 (extend path-mapper) depend on US2 (T011-T015)
- T022-T024 (key binding and event) depend on T019-T021
- T025 (testing) last

### Parallel Opportunities

- T001 and T002 can run in parallel (different directories)
- After Setup: US1 and US2 can be implemented in parallel by different developers
- T026 and T027 can run in parallel (different files)

---

## Parallel Example: Setup + User Stories

```bash
# Launch setup tasks together:
Task: T001 "Create wezterm config directory at ~/.config/wezterm/"
Task: T002 "Create lua modules directory at ~/.config/wezterm/lua/"

# After setup, US1 and US2 can proceed in parallel:
# Developer A: T003-T010 (Home Assistant Status)
# Developer B: T011-T018 (Path Mapping)

# US3 must wait for US2 to complete (extends path-mapper.lua):
# Developer B: T019-T025 (Local-to-Remote Sharing) after T011-T018
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T002)
2. Complete Phase 3: User Story 1 (T003-T010)
3. **STOP and VALIDATE**: Test HA status displays correctly
4. Deploy/use - working HA integration

### Incremental Delivery

1. Complete Setup → Directories ready
2. Add User Story 1 → Test independently → Working HA status (MVP!)
3. Add User Story 2 → Test independently → Working path mapping
4. Add User Story 3 → Test independently → Working screenshot sharing
5. Add Polish → All features documented and integrated
6. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Both developers complete Setup together (T001-T002)
2. Once Setup is done:
   - Developer A: User Story 1 (T003-T010)
   - Developer B: User Story 2 (T011-T018) then User Story 3 (T019-T025)
3. Stories complete and integrate independently
4. Both work on Polish tasks (T026-T030)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Manual testing via wezterm hot-reload (save config to reload)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence

---

## Task Summary

| Phase | Tasks | Parallel | Story |
|-------|-------|----------|-------|
| Setup | T001-T002 | 2 | - |
| US1: HA Status | T003-T010 | 0 | US1 |
| US2: Path Mapping | T011-T018 | 0 | US2 |
| US3: File Sharing | T019-T025 | 0 | US3 |
| Polish | T026-T030 | 2 | - |
| **Total** | **30 tasks** | **4 parallelizable** | - |

---

## Feature Summary

| Feature | Direction | Use Case |
|---------|-----------|----------|
| US1: HA Status | N/A | Display Home Assistant sensors in status bar |
| US2: Path Mapping | Remote → Local | Click remote paths, open locally |
| US3: File Sharing | Local → Remote | Send screenshots to remote for Claude to read |
