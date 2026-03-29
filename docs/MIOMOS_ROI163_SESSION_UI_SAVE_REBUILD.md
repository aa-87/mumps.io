# MIOMOS ROI 163 — Session UI Save Rebuild

## Goal
Reintroduce `session.ui.save` on top of the repaired auth baseline without letting low-priority shell persistence interfere with primary websocket commands or auth transitions.

## What changed
- kept the existing websocket command contract: `command.exec` + `session.ui.save`
- rebuilt server-side save normalization in `MIOMOSST` so UI booleans and shell-surface values are sanitized consistently
- changed `MIOMOSCMD` to save UI state directly from the decoded command tree instead of re-encoding and re-decoding the payload
- rebuilt the browser-side autosave path as best-effort fire-and-forget websocket traffic
- made autosave debounced, fingerprinted, and ignored during sign-out or page unload

## Why this is safer
The desktop should not treat UI-state persistence the same way it treats user-facing commands like terminal, refresh, or sign-out. Those primary commands need request tracking and backpressure; UI save does not. The rebuilt flow still uses the same websocket event system, but autosave no longer competes for inflight command slots.

## Server contract
Saved UI fields:
- `menuOpen`
- `activeWindowId`
- `focusedAppKey`
- `layoutMode`
- `lastCommandName`
- `terminalId`
- `activeTerminalTabId`
- `startMenuSection`
- `startMenuQuery`
- `shellSurface`
- `reason`

Normalization rules:
- string booleans such as `"true"`, `"yes"`, `"on"` become `1`
- invalid or empty shell surfaces collapse to `desktop`
- `menuOpen=1` plus `shellSurface=desktop` normalizes to `start-menu`
- `menuOpen=0` plus `shellSurface=start-menu` normalizes to `desktop`
- blank `startMenuSection` defaults to `Pinned`

## Browser contract
- local storage remains the immediate cache
- websocket autosave remains enabled
- autosave is debounced and deduped by a fingerprint of the state payload
- autosave does not use the generic `socketRequest` inflight/pending queue
- sign-out and forced sign-out suppress queued autosaves

## Regression coverage
- boolean parsing for `menuOpen="true"`
- shell-surface normalization to `start-menu`
- websocket command result still returns the saved section and query
- view model exposes `uiStateTransport="websocket-best-effort"`
