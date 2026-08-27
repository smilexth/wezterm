<!--
Sync Impact Report
==================
Version change: 1.0.0 → 1.1.0 (new operational principles added)

Modified principles: None renamed

Added sections:
- VI. Token Efficiency (NON-NEGOTIABLE)
- VII. Operational Modes

Removed sections: None

Templates requiring updates:
- .specify/templates/plan-template.md ✅ (no changes needed - Constitution Check section is generic)
- .specify/templates/spec-template.md ✅ (no changes needed - no constitution-specific references)
- .specify/templates/tasks-template.md ✅ (no changes needed - no constitution-specific references)

Follow-up TODOs: None
-->

# WezTerm Fork Constitution

## Core Principles

### I. Upstream Compatibility

All patches and additions MUST maintain the ability to merge upstream changes.

- Keep modifications minimal and well-scoped
- Avoid changes to core architecture unless absolutely necessary
- Document all deviations from upstream with clear rationale
- Maintain compatibility with upstream's build system and configuration

**Why**: Ensures long-term maintainability and ability to incorporate upstream bug fixes and features.

**How to apply**: Before making any change, consider "Can this be rebased on upstream easily?" If not, document the reason.

### II. Rust Code Quality

All code MUST follow Rust best practices and wezterm's existing patterns.

- Use `cargo fmt` and `cargo clippy` before commits
- Match existing code style in the file/module being modified
- Add appropriate error handling using `anyhow` or `thiserror` as the project does
- Document public APIs with doc comments

**Why**: Consistency with upstream makes merging easier and maintains code quality.

**How to apply**: Run `cargo fmt --check` and `cargo clippy` as part of the review process.

### III. Targeted Patches

Patches MUST be focused and address specific needs.

- One logical change per patch/feature
- Clear commit messages explaining the "why" not just the "what"
- Prefer configuration options over hard-coded behavior changes
- Avoid "while I'm here" refactoring in patch commits

**Why**: Smaller, focused patches are easier to review, debug, and potentially upstream.

**How to apply**: If a change touches multiple unrelated areas, split into separate commits.

### IV. Testing Requirements

Changes MUST include appropriate testing.

- New functionality requires tests
- Bug fixes should include regression tests
- Verify existing tests pass before merging
- Manual testing for UI/terminal-specific features

**Why**: Prevents regressions and ensures patches work as intended.

**How to apply**: Run `cargo test` before finalizing any change. Add test cases in the same pattern as existing tests.

### V. Documentation

All changes MUST be documented.

- Update relevant docs for user-facing changes
- Add inline comments for non-obvious logic
- Maintain a changelog of patches in the fork
- Document configuration options added

**Why**: Future maintainers (including yourself) need to understand why changes exist.

**How to apply**: If a user would ask "what does this do?", document it.

### VI. Token Efficiency (NON-NEGOTIABLE)

All AI responses MUST maximize information density and precision.

- NO conversational filler (e.g., "Certainly," "I can help with that," "Here is the solution")
- NO generic theories, background concepts, or unsolicited explanations
- Assume the user is a senior expert
- Output ONLY the exact information requested
- Use concise bullet points and short sentences

**Why**: Reduces cognitive load and accelerates problem resolution for expert users.

**How to apply**: Every sentence must add value. If it doesn't, delete it.

### VII. Operational Modes

AI responses MUST follow structured formats based on request type.

#### Mode 1: Debugging & Log Analysis

**Trigger**: User provides error logs or bug reports

**Required Structure**:
1. **Root Cause**: 1-2 sentences maximum explaining exactly why it failed
2. **Exact Fix**: The precise CLI command, code snippet, or configuration change required (output only changed lines with minimal context)
3. **Verification**: 1 concise command or method to verify the fix

**Constraint**: Never echo or repeat the user's logs back to them.

#### Mode 2: Architecture & Planning

**Trigger**: User requests system design, pipelines, or infrastructure plans

**Required Structure**:
1. **Component Skeleton**: Bulleted list of core resources needed
2. **Data/Traffic Flow**: Step-by-step flow in text format (e.g., Client -> ALB -> EKS -> RDS)
3. **Top 2 Critical Risks**: The most severe potential bottlenecks or failure points

**Constraint**: DO NOT generate complete infrastructure code during planning phase unless explicitly requested. Keep response under 300 words.

**Why**: Structured responses reduce ambiguity and accelerate decision-making.

**How to apply**: Detect the request type and apply the appropriate format strictly.

## Technology Standards

**Language**: Rust (follow edition 2021 standards as used by upstream)

**Build System**: Cargo (maintain compatibility with upstream's build configuration)

**Target Platforms**: macOS, Linux (Windows optional)

**Dependencies**: Minimize additions; prefer features already available in the project

**Testing**: `cargo test` for unit/integration tests; manual terminal testing for UI

## Development Workflow

### Branch Strategy

- `main` tracks upstream closely
- Feature branches for each patch/addition
- Merge or rebase from upstream regularly

### Commit Standards

- Use conventional commit format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `refactor`, `patch`
- Reference issue numbers when applicable

### Review Checklist

1. Does this change maintain upstream merge compatibility?
2. Are tests passing?
3. Is the change documented?
4. Would this be useful to upstream? (Consider contributing back)

## Governance

This constitution establishes the rules for development in this fork. Amendments require:

1. Clear documentation of the change
2. Justification for why the amendment is needed
3. Update to this file with version increment

**Versioning**: MAJOR.MINOR.PATCH
- MAJOR: Fundamental changes to how the fork operates
- MINOR: New principles or sections added
- PATCH: Clarifications and wording improvements

**Compliance**: All changes should be checked against these principles. When in doubt, prefer upstream compatibility.

**Version**: 1.1.0 | **Ratified**: 2026-03-19 | **Last Amended**: 2026-03-24
