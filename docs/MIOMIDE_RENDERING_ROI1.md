# MIOIDE Rendering ROI 1

This ROI focuses only on rendering correctness and shell stability.

Included:
- SSR-first `/mioide` workbench page
- stable sidebar, editor, panel, and status bar layout
- canonical route ownership for `HOME^MIOIDE`, `APILOAD^MIOIDE`, `APIDBGST^MIOIDER`, `APIDBGSN^MIOIDER`, and `TERM^MIOIDEWS`
- routine explorer populated from the `routines/` directory with a `%RSEL` fallback
- Monaco and xterm placeholder mounts so the page still renders cleanly before client-side editors initialize
- Vue 3 UMD Options API shell state for sidebar/panel collapse persistence

Deferred to later ROIs:
- full Monaco integration
- xterm lifecycle and PTY bridge
- drag/drop tab orchestration
- command palette and file actions
- debugger state machine
