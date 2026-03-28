# MIOMOS ROI29 — Native Terminal Lite

## Goal
Remove the **xterm.js** dependency from the MIOMOS shell and replace it with a lighter **native Vue/CSS replica terminal** while keeping the existing MUMPS-owned terminal lifecycle, websocket transport, and command boundary intact.

## Why this ROI
MIOMOS is already SSR-first and MUMPS-owned. The terminal renderer did not need a full external terminal library anymore. This ROI simplifies the shell by:
- removing third-party xterm assets from the desktop layout
- keeping terminal session ownership in MUMPS
- preserving websocket-based live interaction
- adding a small command fallback for terminal input
- styling the terminal to feel close to a real console using MIOMOS-native CSS

## What changed
- Removed xterm CSS and JS from the shell layout.
- Replaced the terminal window body with a native MIOMOS terminal surface:
  - replica terminal header
  - transcript viewport
  - prompt + input row
  - send button
- Added a lightweight transcript model in Vue instead of an xterm instance.
- Added line submission fallback through `terminal.input` on the command route.
- Added low-frequency polling fallback when the socket is unavailable.
- Updated app and view-model copy to describe the terminal as native MIOMOS chrome.
- Updated the boot version and smoke tests for the new terminal contract.

## Files changed
- `templates/layouts/miomos_shell.html`
- `templates/pages/miomos_desktop.html`
- `routines/MIOMOSCMD.m`
- `routines/MIOMOSST.m`
- `routines/MIOMOST.m`
- `routines/MIOMOSUI.m`
- `routines/MIOMOSVM.m`
- `miomos_llm.md`

## Terminal behavior in this ROI
The terminal is intentionally simple:
- open session
- attach/reuse session id
- submit a full line on Enter
- receive stdout chunks from websocket or command fallback
- resize notification remains server-aware
- clear viewport locally
- close session through the same MUMPS boundary

This is not yet a full PTY-grade emulator. It is a lighter shell-aligned terminal surface that keeps the backend contract stable while removing unnecessary frontend weight.

## Constraints preserved
- MIO/MUMPS remains the source of truth.
- Existing terminal ownership stays server-side.
- No Node runtime added.
- Vue 3 UMD Options API remains the browser framework.
- Native MIOMOS window manager direction remains intact.

## Recommended next ROI
- improve terminal keyboard handling and command history UX
- add prompt detection and smarter local echo suppression
- improve transcript retention and copy/select ergonomics
- add shell-friendly status badges and reconnect banners inside the terminal chrome
