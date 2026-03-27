# MIOMOS ROI 4 — production-grade window manager on the stable single-socket baseline

This ROI builds on the lean shell that already has:
- quiet passing tests
- one persistent websocket
- a minimal desktop surface without the extra top rail and panels

## What this ROI adds

### Window manager behavior
- title-bar double-click maximize/restore
- edge snap on drag release
  - top edge → maximize
  - left edge → left half
  - right edge → right half
- keyboard shortcuts
  - `Alt+1` focus Workspace
  - `Alt+2` focus Operations
  - `Alt+3` focus Audit
  - `Alt+M` toggle Menu
  - `Alt+Left` snap active window left
  - `Alt+Right` snap active window right
  - `Alt+Up` maximize active window
  - `Alt+Down` restore active window
  - `Escape` closes Menu

### Persistence
- local layout persistence remains enabled
- layout changes are also synchronized to the server over the existing MIOMOS websocket using `layout.sync`
- the saved server payload is normalized to layout JSON so bootstrap restore stays compatible

### UI/UX tightening
- denser default layout
- cleaner compact taskbar
- denser tables and KPI cards
- smaller chrome and less wasted whitespace
- a single main workspace window open by default

## Production-ready next ROIs

### ROI 5 — real work surfaces
- replace placeholder workspace cards with actual MIO-backed data grids
- add command surfaces for queue actions, review, export, and audit drilldowns
- add richer app launching through the OS.js bridge

### ROI 6 — persisted workspace policy
- store per-user layout preferences server-side beyond the current session
- add policy-driven defaults by role
- add window docking presets for operations vs analyst workflows

### ROI 7 — security and HIPAA hardening
- stricter audit records for privileged actions
- session termination controls
- stronger route and websocket policy tests
- explicit PHI-safe logging posture

### ROI 8 — transport and reconnect hardening
- backoff and jitter tuning
- server push channels for queue counts and audit notices
- heartbeat telemetry and quiet timeout recovery tests

### ROI 9 — reusable MIOMOS UI library
- server-rendered form, toolbar, tabs, drawer, table, and status primitives under `MIOMOSUI*`
- token-level test coverage for all primitives
- consistent desktop app composition rules

### ROI 10 — release readiness
- production config examples
- deployment guide for dev/staging/prod
- operator manual
- admin manual
- handoff prompt and continuation plan
