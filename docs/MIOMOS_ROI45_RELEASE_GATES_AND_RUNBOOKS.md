# MIOMOS ROI45 — Release gates and production runbooks

This ROI adds product-operations metadata without changing the runtime websocket, resume, terminal, or security behavior.

## Goals

- keep release discipline visible in the shell contract
- tie shipping readiness to the authoritative `^MIOMOST` suite
- publish deploy, restart, and route-rebuild runbook metadata in boot JSON
- add explicit websocket and browser smoke checklists for future admin/release surfaces

## Added boot contract

The boot payload now includes a `release` object with:

- `model = test-runbook-checklist`
- `tests.suite = ^MIOMOST`
- `tests.quietSuccess = 1`
- `runbooks.deploy = systemd-caddy-nginx`
- `runbooks.restart = graceful-websocket-aware`
- `runbooks.routeRebuild = REG^MIOMOS+COMPILE^MIOROUTE`
- websocket smoke checklist entries
- browser smoke checklist entries
- `docsCurrent = 1`

## SSR contract tokens

The desktop page now emits release/readiness tokens for:

- release gates model
- deploy runbook
- route rebuild runbook
- websocket smoke checklist
- browser checklist

## Testing

`^MIOMOST` now verifies:

- SSR release tokens in `T003`
- boot `release` metadata in `T004`
- direct helper output from `RELEASEARY^MIOMOSST` in `T021`

## Guardrail

This ROI is additive documentation and contract metadata only. It must not change:

- websocket reconnect behavior
- terminal transport or xterm behavior
- session/resume/reattach behavior
- security/session enforcement
