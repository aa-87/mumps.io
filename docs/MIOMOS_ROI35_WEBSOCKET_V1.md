# MIOMOS ROI35 — Websocket Command Bus and v1 Stability Contract

## Goal

Shift live MIOMOS shell communication onto a single websocket request/response bus and lock a broader v1 behavior contract with tests.

## Why this ROI

MIOMOS had already converged on a single live websocket session for presence, chat, and reconnect posture, but command execution still relied on HTTP `POST` requests from the browser shell.

That split created an avoidable architectural mismatch:

- socket for live presence
- HTTP for commands and saves
- a native shell that still behaved like a mixed transport app

This ROI makes the live shell transport more coherent:

- settings saves
- view refreshes
- layout persistence
- UI-state persistence
- terminal actions
- signout eventing

all move through the websocket path from the browser shell.

## Scope

### Browser shell

- remove `fetch()`-based shell command transport from `miomos_desktop.html`
- add websocket request/response command bus with request IDs and timeouts
- add websocket signout event path
- keep chat and heartbeat on the same socket
- expose render tokens for websocket-only shell transport
- surface websocket transport posture in shell chrome

### MUMPS backend

- extend `MIOMOSWS` with websocket command execution support via `command.exec`
- return structured `command.result` and `command.error` payloads
- add helper entrypoints that make websocket command behavior testable without a real socket device
- add websocket signout acknowledgement path
- keep existing HTTP command route for compatibility, but treat the websocket bus as the live shell transport

### Tests

Add and expand tests around:

- websocket transport render contract
- boot contract for websocket command metadata
- websocket command execution for `desktop.ping`
- websocket command execution for `view.refresh`
- websocket command execution for `session.ui.save`
- websocket command execution for terminal open/input
- command transport metadata in boot/view models

## Architecture after ROI35

### Live transport posture

- page bootstrap remains SSR over HTTP
- the interactive MIOMOS shell uses one websocket session for live command/event traffic
- MUMPS remains the source of truth for session state, UI state, settings, layout, and terminal behavior

### Browser event names

- command request: `command.exec`
- command success: `command.result`
- command failure: `command.error`
- signout event: `auth.signout`
- signout acknowledgement: `auth.signout.ack`

## Product direction

This ROI is part of the move from “desktop concept” to “deliverable product shell.”

It supports the v1 posture by making the shell transport simpler to reason about, easier to test, and closer to how a real persistent desktop session should behave.
