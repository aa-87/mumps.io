# MIOMOS ROI44 — Security and session hardening

This ROI hardens the shell session contract without changing the stable websocket, reconnect, resume, reattach, or terminal runtime behavior.

## Deliverables

- principal/session binding enforcement in `ENSURE^MIOMOSST`
- server-authored session registry under `^MIO("MIOMOS","SESSION","REG",...)`
- forced signout and lock helpers
- websocket `session.signout` event for direct event-path session guard failures
- audit coverage for forbidden websocket actions and privileged terminal actions

## Policy

- `security.sessionBinding = principal-and-session`
- `security.forcedSignoutEvent = session.signout`
- `security.permissionDeniedEvent = command.error`
- `security.idleLock.model = server-authored-idle-lock`
- `security.sessionRegistry.model = server-authored`
