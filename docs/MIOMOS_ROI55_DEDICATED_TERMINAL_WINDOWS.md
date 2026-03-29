# MIOMOS ROI55 — Dedicated terminal windows and sessions

## Goal

Make every shell launch of Terminal create a new desktop window with its own backend terminal session and its own client-side xterm state.

## Behavior delivered

- `terminal.open` now supports an explicit fresh-session path from the shell using `forceNew=1`
- the PIPE backend treats the `__new__` terminalId sentinel as a request for a new terminal session instead of reusing the session-level default
- the desktop shell now creates a distinct terminal window per launch
- each window keeps its own transcript, prompt, cwd, history, busy state, xterm host, and terminalId
- closing a terminal window closes only that window's terminal session

## Files changed

- `routines/MIOMOSCMD.m`
- `routines/MIOMOSTPIPE.m`
- `routines/MIOMOST.m`
- `templates/pages/miomos_desktop.html`
- `miomos_llm.md`

## Notes

This ROI deliberately keeps the single MIOMOS websocket model. Multiple terminal windows coexist by using distinct terminal ids on the same command/event transport.
