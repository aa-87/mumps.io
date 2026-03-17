# MIOUI Adaptive Workspaces Plan

## ROI 15 goal

Add reusable adaptive workspace structures for dense, data-intensive applications.

## Implemented in this ROI

- role and task presets
- keyboard-first pane focus map
- persistent pane ratios
- collapsed rails
- responsive dense stacking
- keyboard shortcut cheatsheet
- dedicated adaptive workspace demo page

## Why this matters

Dense operator products need more than widgets and tables. They need shell behavior that fits the job:

- collectors need triage-first shells
- reviewers need inspector-heavy shells
- supervisors need command-center shells
- analysts need comparison-heavy shells

## Component contracts

### `layout_role_preset_bar`
Use when a single click should switch multiple layout decisions together.

### `keyboard_pane_focus_map`
Use when keyboard travel between panes is important.

### `persistent_pane_ratios`
Use when split percentages should survive route changes or login sessions.

### `collapsed_rail_toggle_strip`
Use when left, right, or bottom rails need to collapse without losing context.

### `responsive_dense_stack_layout`
Use when narrow screens must preserve density by reordering panes instead of hiding them.

### `keyboard_shortcut_cheatsheet`
Use when the shell itself owns a shortcut vocabulary.

## Next likely follow-up

- session-restored workspace state
- role-specific default presets from auth/session context
- per-route ratio persistence
- layout policy rules by screen width
- threaded annotations inside adaptive rails
