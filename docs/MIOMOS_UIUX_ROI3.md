# MIOMOS UI/UX ROI 3

This ROI focuses on two concrete user-facing problems:

1. Window movement felt broken because the shell never implemented actual drag logic.
2. The desktop chrome used too much space, which made the shell feel like a static demo instead of a professional dense workspace.

## What changed

- Added real pointer-driven window drag behavior from the title bar.
- Added resize handles on all edges and corners.
- Preserved focus, minimize, maximize/restore, close, and taskbar recovery behavior.
- Added local desktop persistence so window state survives refreshes per session.
- Reduced shell padding, taskbar height, and surface spacing to increase usable workspace area.
- Upgraded the default workspace composition to a denser operations layout.
- Added an Activity Center app/window to make the desktop feel more like a working shell instead of a placeholder.

## Files changed

- `routines/MIOMOSST.m`
- `routines/MIOMOSUI.m`
- `routines/MIOMOST.m`
- `templates/layouts/miomos_shell.html`
- `templates/pages/miomos_desktop.html`

## Notes

- This ROI keeps Vue 3 Options API UMD and the existing websocket contract.
- The OS.js client remains an adapter boundary only. Full provider-backed OS.js boot is still deferred.
- The test updates are token-level only and intentionally keep the current route/bootstrap/websocket contracts intact.
