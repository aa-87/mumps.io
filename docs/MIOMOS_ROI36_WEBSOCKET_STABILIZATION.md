# MIOMOS ROI36 — WebSocket Helper Session Contract and Terminal Backend Convergence

## Goal

Stabilize the websocket command helper path and make terminal command execution use the same server-side owner as the live websocket terminal transport.

## Why this ROI

The ROI35 websocket bus established the right browser transport posture, but two backend gaps still remained:

- direct test/helper execution through `COMMANDJSON^MIOMOSWS` still depended on ambient auth or an already-populated websocket context
- `MIOMOSCMD` still routed `terminal.*` commands through `MIOMOSTERM` while the live websocket event path already used `MIOMOSTPIPE`

That created exactly the failures seen in `^MIOMOST`:

- websocket helper calls returned `command.error` with `session_error` when tests invoked them without a session
- command-driven terminal calls did not share the same backend as websocket terminal events

## Changes in this ROI

### 1) Explicit helper-session websocket command entrypoint

`MIOMOSWS` now exposes:

- `COMMANDJSON^MIOMOSWS` for ordinary runtime behavior
- `COMMANDSIDJSON^MIOMOSWS` for test/helper execution with an explicit session id

This keeps the runtime websocket path strict while making test execution deterministic.

### 2) One terminal backend for websocket command paths

`MIOMOSCMD` now routes:

- `terminal.open`
- `terminal.input`
- `terminal.poll`
- `terminal.resize`
- `terminal.close`

through `MIOMOSTPIPE`, matching the websocket terminal event path already used by `MIOMOSWS`.

This removes split terminal ownership across command and event traffic.

### 3) Tests tightened around the intended contract

`MIOMOST` now verifies both sides of the helper contract:

- calling `COMMANDJSON^MIOMOSWS` without a session in the local-auth production profile fails deterministically with `command.error` / `session_error`
- calling `COMMANDSIDJSON^MIOMOSWS` with an explicit session id succeeds for ping, view refresh, UI save, and terminal actions

It also asserts that websocket-command terminal traffic reports `transport="pipe"`.

## Architectural posture after ROI36

### Websocket helper contract

- live runtime socket handling still resolves session/auth through the normal request/context path
- direct non-socket helper execution must provide explicit session identity when no live auth context exists
- production helper behavior is now deterministic rather than depending on incidental prior state

### Terminal ownership

- the terminal is now websocket-owned at the server boundary
- websocket terminal events and websocket command bus terminal actions share `MIOMOSTPIPE`
- `MIOMOSTERM` remains useful as a terminal foundation/test surface, but it is no longer the live websocket command owner

## Exit criteria

This ROI is complete when:

- `^MIOMOST` passes for websocket ping, view refresh, UI save, and terminal command tests
- direct helper calls without session fail predictably
- terminal command paths no longer diverge from websocket terminal event handling

## Next ROIs

### ROI37 — Realtime event fabric
Add sequence-aware push events for view invalidation, notifications, job progress, and reconnect replay.

### ROI38 — Shell state machine hardening
Separate z-order from task order more formally and add stronger tests around Start, overflow, and surface state.

### ROI39 — Mini desktop MVP
Turn the shell into a small but truly functional desktop with app launch, pinned items, terminal, settings, workspace, UI library, and files-lite surfaces.

### ROI40 — Performance and security hardening
Add websocket backpressure, slow-client posture, stronger session binding, and operability tooling for the live desktop.
