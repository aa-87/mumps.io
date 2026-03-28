# MIOMOS ROI 10 — Terminal Foundation

## Goal
Add a production-minded terminal foundation to MIOMOS without destabilizing the desktop.

This ROI keeps the existing **single persistent MIOMOS websocket** model and layers a terminal session protocol onto it. The terminal surface is rendered in the browser with **xterm.js**, while MIOMOS remains responsible for session identity, permission checks, persistence, audit, and websocket event handling.

## Scope
This ROI adds:
- a `Terminal` desktop app and window
- terminal profile settings inside the existing `Settings` app
- MUMPS-side terminal session storage and lifecycle helpers in `MIOMOSTERM`
- websocket events for open, attach, input, resize, and close
- updated smoke tests covering terminal render, settings persistence, permission checks, and terminal lifecycle helpers

This ROI does **not** yet provide a true PTY or raw process-backed terminal.

## Architecture
### Browser side
- xterm.js is loaded as the terminal renderer
- the terminal window opens inside the existing MIOMOS desktop shell
- terminal input/output flows over the same single MIOMOS websocket used by the rest of the desktop
- terminal profile updates are applied live from the Settings app

### MUMPS side
- `MIOMOSTERM` stores terminal profile defaults and current terminal sessions
- `MIOMOSWS` handles terminal events on the existing websocket channel
- `MIOMOSSET` persists terminal preferences under the same per-user preference model as themes, density, icons, and fonts
- `MIOMOSPERM` exposes `terminal.use`

## New routines and touched routines
### New
- `MIOMOSTERM.m`

### Updated
- `MIOMOS.m`
- `MIOMOSSET.m`
- `MIOMOSST.m`
- `MIOMOSUI.m`
- `MIOMOSPERM.m`
- `MIOMOSWS.m`
- `MIOMOST.m`
- `templates/pages/miomos_desktop.html`

## Terminal settings
Terminal settings now live under the same settings save/load flow and include:
- font family
- font size
- cursor style
- cursor blink
- renderer preference
- unicode mode
- scrollback
- columns
- rows

## Websocket events
The following terminal events are now supported over `/ws/miomos`:
- `terminal.open`
- `terminal.attach`
- `terminal.input`
- `terminal.resize`
- `terminal.close`

The following replies are emitted:
- `terminal.opened`
- `terminal.attached`
- `terminal.output`
- `terminal.resized`
- `terminal.closed`

## Session storage
Terminal sessions are stored under:
- `^MIO("MIOMOS","TERM","SESSION",termId,...)`
- `^MIO("MIOMOS","TERM","BYSESSION",sessionId)=termId`

## Commands currently supported
This ROI intentionally keeps the shell narrow and testable. The terminal foundation currently supports:
- `help`
- `whoami`
- `roles`
- `date`
- `theme`
- `settings`
- `profile`
- `logs`
- `history`
- `clear`
- `exit`

## Testing
`^MIOMOST` now verifies:
- terminal app/window render tokens
- terminal settings catalog presence in boot payload
- terminal permission availability
- terminal profile persistence through `MIOMOSSET`
- terminal open / input / resize / close through `MIOMOSTERM`

## Known limitations
- no PTY or raw host shell backend yet
- no fit addon or advanced renderer tuning yet
- no legacy TUI compatibility matrix yet
- no transcript retention policy yet

## Why this ROI comes before fidelity work
A stable terminal transport and settings model is required before MIOMOS can pursue:
- xterm.js addon strategy
- resize fidelity
- mouse reporting
- alternate screen buffer behavior
- legacy or curses-style app validation
