# MIOMOS ROI 12 — Themes, Window Manager, Motion, and PIPE Terminal Foundation

This ROI pushes MIOMOS further toward a production-ready, MUMPS-owned desktop runtime.

## Goals
- keep Vue as a thin render and interaction layer
- move more desktop policy into MUMPS-authored contracts
- expand themes, titlebar styles, motion profiles, and layout presets
- add a first MUMPS-owned YottaDB PIPE terminal bridge over the existing websocket channel
- keep smoke tests safe and environment-independent

## Included changes
- richer theme catalog via `MIOMOSTH`
- new window-manager catalog and preset geometry via `MIOMOSWM`
- enhanced settings persistence via `MIOMOSSET`
- boot/view model contract additions in `MIOMOSST` and `MIOMOSVM`
- command boundary additions in `MIOMOSCMD`
- websocket terminal event handling in `MIOMOSWS`
- new PIPE-backed bridge in `MIOMOSTPIPE`
- updated desktop shell/page for:
  - window preset
  - snap mode
  - motion profile
  - titlebar style
  - YDB PIPE terminal open / poll / close

## PIPE terminal design
The terminal bridge is intentionally MUMPS-owned:
- browser captures input and renders xterm.js
- websocket carries terminal events
- MUMPS launches and supervises the child process using PIPE devices
- stdout/stderr are read in MUMPS and serialized back to the browser

The first step here is a line-oriented PIPE foundation. It is suitable for YottaDB direct-mode style interaction and operational commands. It is not yet a full PTY.

## Why PIPE first
YottaDB PIPE devices support COMMAND, SHELL, STDERR, and INDEPENDENT parameters, which makes them a strong first backend for a MUMPS-controlled terminal bridge. xterm.js expects a real visible DOM element when open(...) is called and exposes a resize API for column/row updates, which matches the Vue-side responsibilities in MIOMOS.

## Testing posture
This ROI adds safe smoke tests for:
- theme/window-manager catalogs
- window preset defaults
- terminal transport contract

It does **not** automatically spawn a live YottaDB child in smoke tests, because that would make the tests environment-dependent and more fragile. The PIPE terminal bridge is intended for integration testing on the target host.

## Suggested compile/load set
```mumps
ZL "MIOMOS.m","MIOMOSAPI.m","MIOMOSCMD.m","MIOMOSSET.m","MIOMOSST.m","MIOMOST.m","MIOMOSTERM.m","MIOMOSTH.m","MIOMOSUI.m","MIOMOSVM.m","MIOMOSWM.m","MIOMOSWS.m","MIOMOSTPIPE.m","MIOMOSPIPET.m"
```

## Suggested test run
```mumps
D ^MIOMOST
D ^MIOMOSPIPET
```

## Next ROIs after this one
1. PIPE integration hardening and prompt detection
2. richer YDB session controls and transcript policy
3. PTY decision point for legacy full-screen apps
4. final production hardening and deployment docs
