# MIOMOS ROI43 — Websocket observability and admin diagnostics

This ROI adds a lightweight server-authored websocket registry without changing the stable runtime transport contract.

## Added
- Per-session / per-connection websocket registry under `^MIO("MIOMOS","WS","REG",...)`
- Summary counters for hello, pong, command execution, command errors, and terminal stdout
- Boot payload exposure for websocket observability so admin surfaces can render current metrics
- Export helper for registry inspection in tests and future admin tooling

## Intent
Keep websocket diagnostics additive and inspectable while leaving reconnect, resume, and terminal continuity behavior unchanged.
