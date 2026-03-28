# MIOMOS ROI 17 — Behavior Hardening and Production Reliability

## Goal
Lock down shell behavior and reduce operational drift without changing the MUMPS-first architecture.

## Principles
- MUMPS remains authoritative for routes, settings, window-manager policy, and terminal/session behavior.
- Vue stays a thin render and interaction layer.
- No transport redesign in this ROI.
- Preserve the stabilized test contract.

## What changed

### Server-authored desktop policy
`MIOMOSST` now emits a `desktop.policy` contract in the boot payload:
- `heartbeatMs`
- `reconnectBaseMs`
- `reconnectMaxMs`
- `staleSocketMs`
- `commandMaxInflight`
- `persistMenuState`
- `persistActiveWindow`
- `persistLayout`
- `showReliabilityPanel`

This lets the browser stay policy-driven instead of inventing its own shell rules.

### Shell reliability UX
The desktop shell now includes:
- a dismissible reliability alert banner
- launcher reliability summary pills
- taskbar reliability metadata (socket, inflight commands, reconnect count)

### Thin-client behavior hardening
The Vue layer now adds:
- persisted menu/active-window UI state in local storage
- duplicate-command suppression for the same command payload
- max in-flight command enforcement using the server policy
- reconnect count tracking
- stale-socket detection and recycle
- command failure visibility without changing the MUMPS command contract

## Why this ROI exists
Earlier ROIs focused on structure, visuals, shell semantics, and terminal foundations. This ROI focuses on predictable behavior over long-running sessions and repeated operator workflows.

## Expected user-visible outcomes
- fewer accidental repeated command submissions
- clearer reconnect/offline feedback
- menu/window state feels more consistent across refreshes
- better confidence during long-running sessions

## Risk posture
Low to moderate.
- Template and thin-client logic changed.
- No route or transport contract redesign.
- Server contract only extended, not replaced.

## Suggested verification
- Load `/miomos`
- Open/close the menu and refresh
- Focus different windows and refresh
- Temporarily drop/restart the websocket path and confirm reconnect status feedback
- Repeatedly trigger the same command and confirm duplicate suppression
- Confirm terminal, settings, menu, and taskbar still behave normally
