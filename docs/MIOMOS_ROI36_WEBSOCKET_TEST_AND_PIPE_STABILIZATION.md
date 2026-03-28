# MIOMOS ROI36 — Websocket test/session and pipe command stabilization

## Goal

Make the websocket command tests deterministic and align websocket command execution with the same terminal backend used by live websocket terminal events.

## What changed

- Added `COMMANDSIDJSON^MIOMOSWS` as the explicit session-aware websocket command test helper.
- Kept `COMMANDJSON^MIOMOSWS` strict for normal runtime behavior.
- Rewired `MIOMOSCMD` terminal commands to `MIOMOSTPIPE` so command-bus terminal calls and live websocket terminal events use one backend.
- Normalized terminal input handling so `line` input is converted to a command plus carriage return before being written to the pipe terminal.
- Updated `^MIOMOST` to bootstrap a real authenticated session before websocket command tests and to assert pipe transport plus terminal output behavior.

## Why

The failing tests were exercising `COMMANDJSON^MIOMOSWS` directly after the suite had moved into prod/local-auth mode, but without any cookie or explicit session id. That was not a valid runtime contract.

At the same time, `MIOMOSCMD` was still routing `terminal.*` commands through `MIOMOSTERM` while the live websocket event path already used `MIOMOSTPIPE`. That created a split transport/ownership model and made the websocket tests drift away from the intended architecture.

## Exit criteria

- `desktop.ping`, `view.refresh`, and `session.ui.save` pass through the websocket command helper with an explicit session id.
- `terminal.open` returns a nested terminal payload with `transport="pipe"`.
- `terminal.input` produces pipe terminal output and increments `writeCount`.
- Tests, docs, and `miomos_llm.md` stay aligned.
