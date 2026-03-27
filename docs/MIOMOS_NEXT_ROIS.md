# MIOMOS next ROIs

## Current stabilization ROI
- Keep exactly one desktop websocket per browser tab.
- Remove interaction-triggered socket traffic until server-push surfaces are ready.
- Replace fragile title-bar controls with custom controls.
- Remove extra chrome: no top bar, no side rail, no redundant internal toolbars.
- Keep one primary workspace window open by default and minimize secondary windows.
- Make development mode first-class with auth disabled for `/miomos`, `/api/miomos/bootstrap`, and `/ws/miomos`.

## ROI 4 — production window manager
- Persist workspace layout server-side, not only in `localStorage`.
- Add snap zones, half-screen docking, restore stacks, and keyboard shortcuts.
- Add double-click maximize and proper restore bounds memory.
- Add viewport-aware first-run layout for laptop vs large desktop screens.
- Expand tests for drag, resize, minimize, maximize, restore, close, and taskbar activation.

## ROI 5 — OS.js integration done safely
- Promote OS.js from deferred bridge to actively used desktop services.
- Keep MUMPS authoritative for auth, session, audit, routing, and websocket.
- Use OS.js for launcher model, notifications, dialogs, settings, and app lifecycle.
- Prevent any second transport layer unless explicitly mapped to the MIO websocket contract.
- Add SSR boot data contracts for OS.js packages, icons, capabilities, and permissions.

## ROI 6 — MIOMOSUI component system
- Build `MIOMOSUI*` routines for dense grids, forms, tabs, drawers, toasts, command palette, and inspectors.
- Keep components SSR-first with progressive enhancement.
- Reuse MIOUI patterns where appropriate instead of inventing parallel controls.
- Add token tests per component and page-level render tests.

## ROI 7 — security and HIPAA posture
- Session timeout warnings, idle lock, and privileged action confirmation.
- Structured desktop audit events for open, close, launch, export, and security actions.
- Policy surfaces for minimum necessary data display.
- Screen privacy controls and workstation-safe masking states.
- Production defaults for auth-on, secure cookies, websocket timeout posture, and request logging.

## ROI 8 — app surfaces
- Workspace app for queue triage and batch operations.
- Operations app for throughput, health, backlog, and delivery posture.
- Audit app for session registry, privileged activity, and websocket diagnostics.
- Admin/settings app for theme, density, profile, and desktop defaults.
- File drop and automation app when the shell is stable enough to support it cleanly.

## ROI 9 — hardening and release readiness
- Full MIOMOST coverage for dev and prod profiles.
- Route-registration tests for auth-required vs auth-disabled modes.
- Websocket persistence and reconnect regression tests.
- Browser-side smoke checklist for drag, resize, restore, taskbar, menu, and persistence.
- Documentation for startup, route rebuild, dev profile, and production deployment.
