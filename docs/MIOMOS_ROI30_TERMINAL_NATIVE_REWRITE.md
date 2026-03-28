# MIOMOS ROI30 — Native Terminal Rewrite

This ROI stabilizes the MIOMOS terminal after the xterm.js removal by making the terminal path coherent again.

## What changed

- Added `session.ui.save` handling to `MIOMOSCMD` so UI state persistence no longer returns HTTP 400.
- Rebuilt the browser terminal surface as a native Vue/CSS terminal window with:
  - textarea-backed command entry
  - history navigation with Up/Down
  - `Ctrl+L` clear
  - `Ctrl+C` input cancel marker
  - command-only terminal transport for reliability
- Reworked `MIOMOSTERM` into a MUMPS-owned shell emulator with:
  - open/attach/poll/resize/close contract
  - prompt and cwd state
  - command history
  - pseudo filesystem commands: `pwd`, `ls`, `cd`, `cat`
  - session/profile introspection: `whoami`, `roles`, `theme`, `settings`, `profile`, `logs`, `history`
- Removed terminal websocket dependency from the frontend so the browser no longer splits terminal behavior across incompatible handlers.

## Intent

The goal of this ROI is not to emulate a full PTY. The goal is a dependable, professional terminal-like surface that behaves like a real shell from the user's perspective while staying fully MUMPS-owned and testable.

## Next steps

- richer prompt styling and cursor treatment
- optional autocomplete for known shell commands
- pseudo file editing flows for MIOMOS workspace content
- server-backed command transcript export
- optional progressive enhancement to a true PTY path later, without changing the browser contract
