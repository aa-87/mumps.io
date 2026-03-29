# MIOMOS ROI41 — Terminal Reattach and Grace

This ROI adds a conservative terminal continuity layer on top of the current passing websocket and YottaDB terminal baseline.

## Goals
- Keep the existing YottaDB PIPE terminal contract intact
- Add an explicit terminal reattach command/event
- Preserve the current `terminalId` through transient socket loss on the browser side
- Attempt same-session reattach after the websocket handshake returns
- Expose a reconnect grace policy in boot JSON and terminal metadata

## Server changes
- `MIOMOSTPIPE` now exposes `REATTACH^MIOMOSTPIPE`
- `MIOMOSCMD` supports `terminal.reattach`
- `MIOMOSWS` supports direct websocket `terminal.reattach` and includes terminal-resume metadata in `hello`
- `MIOMOS` / `MIOMOSST` publish:
  - `desktop.policy.terminalResumeMode = same-session-terminal-id`
  - `desktop.policy.terminalReconnectGraceSeconds`
  - `terminal.resumeMode`
  - `terminal.reconnectGraceSeconds`

## Browser behavior
- On socket close, MIOMOS keeps the current `terminalId` and marks reattach pending
- On the next `hello`, if the server says terminal resume is ready, the browser issues `terminal.reattach`
- The terminal polling loop restarts after reattach succeeds

## Scope note
This ROI is intentionally conservative. It improves continuity for same-session reconnects without reworking the already-stable websocket ownership and heartbeat behavior.
