# MIOMOS ROI35 — Websocket Test Helper Contract

## Purpose

Lock the direct-test contract for websocket command execution so `^MIOMOST` does not depend on ambient auth state.

## Contract

- Use `COMMANDJSON^MIOMOSWS` for normal runtime websocket command execution.
- Use `COMMANDSIDJSON^MIOMOSWS` when a test or helper has already created a valid MIOMOS session and wants to execute the websocket command boundary directly without a live socket device.
- In prod/local-auth tests, bootstrap the auth cookie with `LOADLOCAL^MIOMOSAUTH`, then create or refresh the MIOMOS session with `ENSURE^MIOMOSST`, then pass that `sessionId` to `COMMANDSIDJSON^MIOMOSWS`.

## Terminal note

The websocket command bus now routes terminal commands to `MIOMOSTPIPE`.

That backend opens `yottadb -direct`, so websocket terminal assertions must use real MUMPS input, for example:

```mumps
write 123,!
```

instead of shell-only commands.
