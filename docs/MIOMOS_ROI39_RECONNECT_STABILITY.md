# MIOMOS ROI39.1 - reconnect stability hardening

This follow-up hardens the browser-side websocket liveness model without changing the single-active lease server contract.

## Why

The earlier heartbeat/stale-socket implementation could recycle a healthy socket too aggressively after background-tab timer throttling or delayed message delivery.

## Changes

- Add `desktop.policy.maxMissedHeartbeats` (default `3`).
- Heartbeats now require repeated missed acknowledgement windows before the browser closes and reconnects the socket.
- The stale monitor no longer closes an open socket on the first stale interval. It sends a ping probe instead.
- Visibility resume and online events trigger a liveness probe rather than an immediate disconnect/reconnect cycle.

## Result

- One active socket lease per MIOMOS session remains the contract.
- Healthy but quiet sockets stay connected longer.
- Background tabs resume more gracefully.
- Reconnect only happens after repeated missed heartbeat acknowledgement windows.


Follow-up stability notes
- Terminal launch promises are caught at the app boundary so routine socket recycling does not leak unhandled `socket_closed` errors into the browser console.
- T010 clears observability stores before seeding probe entries so websocket hello/audit traffic from earlier tests does not reorder export assertions.
- The heartbeat token remains part of the SSR surface: `data-miomos-heartbeat-model="ack-before-recycle"`.
