# MIOMOS Rebuild ROI 1

This rebuild resets MIOMOS onto a simpler, production-minded foundation:

- MIO remains the server of record for routes, rendering, sessions, websocket handling, and audit events.
- Development defaults to a `dev` MIOMOS profile so the desktop is reachable while the subsystem is under active construction.
- The browser shell uses a compact SSR desktop with a plain-JavaScript window manager so the page stays usable even if Vue or the OS.js bridge fails.
- Vue 3 Options API UMD is mounted for live status.
- OS.js client UMD is initialized in standalone mode as a bridge layer so later ROIs can move more desktop services into OS.js abstractions.
- 7.css scoped styling is used for desktop chrome and refined with denser custom CSS.

## Implemented

- `/miomos` SSR shell route
- `/api/miomos/bootstrap` bootstrap payload
- `/ws/miomos` persistent websocket route
- dev-profile route exemption and auth-disabled development behavior
- MIOMOS session model with idle and absolute timeout tracking
- websocket session resume via `sessionId`
- structured audit scaffold
- launcher, desktop icons, taskbar, and window controls
- real drag and resize handling
- local layout persistence plus websocket `layout.sync`
- smoke tests for route auth, render tokens, bootstrap data, and websocket auth injection

## Not yet implemented

- OS.js package loading and application launch through `core.run`
- server-backed VFS and settings adapters for OS.js
- admin/security application surfaces beyond the scaffold windows
- richer MIOMOS UI partial library split into dedicated `MIOMOSUI*` routines/templates
- role-aware desktop app catalog and per-app authorization checks
- full server-side layout restore instead of the current raw-session scaffold
