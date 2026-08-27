# Feature Specification: Fork Comparison Research - nazt/wezterm

**Feature Branch**: `001-fork-comparison-research`
**Created**: 2026-03-19
**Status**: Closed (2026-08-27)
**Input**: User description: "research and compare on https://github.com/nazt/wezterm/ with original wezterm to check what they patch/edit something and summarize to make a desicion to follow"

## Executive Summary

Research completed to compare the nazt/wezterm fork with upstream wezterm/wezterm to identify custom patches or modifications that could inform the development approach for this fork (smilexth/wezterm).

**Key Finding**: nazt/wezterm has **12 feature branches** with experimental patches, but they are **stale** (circa 2021) and have never been rebased to current upstream.

---

## Branch Analysis

### Main Branch
| Aspect | nazt/wezterm | wezterm/wezterm (upstream) |
|--------|--------------|---------------------------|
| Branch:main | Identical | Reference |
| Custom patches | None | N/A |
| Divergence | 0 commits | N/A |

### Feature Branches (12 total)

Each branch has **1 commit ahead, 1 commit behind** main - indicating they diverged from an old upstream point and were never rebased.

| Branch | Description | Category | Viable? |
|--------|-------------|----------|---------|
| `altwin` | Avoid panic during shutdown | Bug fix | ⚠️ Stale |
| `boxrender` | Treat Constant ease-in-out as "1 fps" case | Rendering | ⚠️ Stale |
| `gamma` | Gamma fix on CGL (macOS) | Color | ⚠️ Stale |
| `gammafix` | GUI gamma fixup across platforms | Color | ⚠️ Stale |
| `libssh` | Use first known host location for libssh | SSH | ⚠️ Stale |
| `newssh` | RemoteSshDomain uses wezterm-ssh crate | SSH | ⚠️ Stale |
| `recording` | Add Windows support for recording | Feature | ⚠️ Stale |
| `remove-nix` | Remove Nix from repo and CI | Build | ⚠️ Stale |
| `svg` | WIP: SVG font support | Fonts | ⚠️ Stale |
| `wgpu` | wgpu builds on Windows | Rendering | ⚠️ Stale |
| `wgpu-020` | wgpu → v22.1 | Dependencies | ⚠️ Stale |
| `x11resizecoalesce` | Max FPS 60, improve resize coalesce | Performance | ⚠️ Stale |

---

## Detailed Patch Analysis

### High-Value Patches (if modernized)

#### 1. `gammafix` - Color Management Fix
```
gui: gamma fixup

Fixes colorspace handling on macOS, Linux (X11, Wayland), Windows (WGL).
Issue: ANGLE EGL on Windows over-gamma corrects.
Solution: Use WGL by default instead of EGL.
Refs: wez/wezterm#544
```
**Value**: Proper color rendering across platforms
**Status**: Likely fixed in upstream by now

#### 2. `x11resizecoalesce` - Performance Improvement
```
increase max fps to 60 by default, improve coalesce

* Trigger paint immediately from invalidate if not throttled
* Defer events until about to sleep for xcb events
* Maximizes coalesce around resize/expose events
Refs: wez/wezterm#1051
```
**Value**: Smoother X11 performance
**Status**: Likely merged to upstream

#### 3. `remove-nix` - Simplified Build
```
Remove nix bits from repo and CI

Reason: Workflows fail often, maintainer has no time for nix,
no community volunteers to maintain it.
```
**Value**: Cleaner repo, simpler CI
**Status**: Opinionated - may not align with your needs

#### 4. `svg` - SVG Font Support (WIP)
```
WIP: svg font support

Note: vertical alignment is wonky
```
**Value**: Support for SVG color fonts
**Status**: Incomplete, needs work

---

## Conclusion

### Viability Assessment

| Factor | Assessment |
|--------|------------|
| Patch quality | Generally good (authored by wez) |
| Current relevance | **Low** - all patches are 3-4+ years old |
| Merge effort | **High** - require rebasing on modern codebase |
| Learning value | **Moderate** - shows patch patterns |

### Key Insight

The nazt/wezterm branches appear to be **upstream author's experimental branches**, not community patches. They show what features the author was working on circa 2021. Most have likely been:
- Merged to upstream in improved form
- Abandoned
- Superseded by different implementations

---

## Recommendations

### Option A: Check Upstream First
Before considering any nazt patches:
1. Check if the issue/feature exists in current upstream
2. Many fixes (gamma, FPS improvements) are likely already merged
3. Search upstream issues for the referenced numbers

### Option B: Use as Reference Only
These branches are valuable for:
- Understanding how to structure patches
- Seeing what files to modify for specific features
- Learning the author's development patterns

### Option C: Define Your Own Requirements
Since these patches are stale, better to:
1. Identify your specific needs
2. Check upstream for existing solutions
3. Create fresh patches on current codebase

---

## Success Criteria

- [x] SC-001: Compare nazt/wezterm main with upstream wezterm
- [x] SC-002: Identify all custom branches and their purposes
- [x] SC-003: Analyze patch viability and relevance
- [x] SC-004: Provide actionable recommendations

---

## Next Steps

1. **Verify upstream status**: Check if desired features already exist in current wezterm
2. **Define requirements**: What specific patches do you want?
3. **Fresh implementation**: Build on current codebase rather than cherry-picking stale branches

## Assumptions

- The user's goal is to maintain a fork with useful patches/additions
- Upstream compatibility remains a priority (per constitution)
- The fork should provide value beyond what upstream offers
- Stale patches from 2021 are of limited direct use
