# MIOMIDE UI/UX ROI 2

This ROI hardens the MIOIDE foundation into a more credible VS Code-like workbench while keeping the current backend API surface stable.

## Goals completed

- The shell now has a stronger VS Code-style chrome:
  - title bar controls
  - activity bar
  - collapsible primary side bar
  - editor tabs
  - resizable side bar
  - resizable bottom panel
  - status bar
- Vue 3 UMD Options API remains the single client-side state owner for the workbench.
- Local workspace state now persists in `localStorage`:
  - theme
  - active sidebar
  - active panel
  - sidebar visibility
  - panel visibility
  - sidebar width
  - panel height
  - open tabs
  - active routine
- Added command surfaces:
  - Command Palette
  - Quick Open
  - keyboard shortcuts for primary workbench actions
- Added polished empty states and transient toast feedback.
- The editor shell now feels more like an IDE even before debugger and deeper editor ROIs land.

## Scope intentionally kept stable

This ROI does **not** change the overall server contract for routine loading, saving, compile, run, search, globals, events, or terminal.

That keeps this pass focused on:

- shell resilience
- workbench ergonomics
- layout persistence
- user confidence

## Files changed

- `routines/MIOMIDE.m`
- `routines/MIOMIDEST.m`
- `routines/MIOMIDET.m`
- `templates/layouts/miomide_shell.html`
- `templates/pages/miomide_index.html`
- `docs/MIOMIDE_UIUX_ROI2.md`

## Deferred to the next ROI

- stronger routine dirty-state conflict handling
- richer problems parsing and diagnostics mapping
- terminal session lifecycle hardening
- improved editor intelligence for M labels and indentation rules
- command palette actions backed by deeper workspace APIs
- server-side preferences and workspace persistence
