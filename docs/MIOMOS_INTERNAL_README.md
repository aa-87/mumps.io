# MIOMOS Internal README (ongoing)

## Purpose
MIOMOS is a MIO-native desktop subsystem. The backend remains the source of truth. Browser code is an enhancement layer, not the authority.

## Current subsystem map
- `MIOMOS` route registration, defaults, desktop entrypoint
- `MIOMOSST` session/state/bootstrap composition
- `MIOMOSAPI` JSON and download endpoints
- `MIOMOSAUTH` optional local-auth helpers
- `MIOMOSPERM` role/permission matrix
- `MIOMOSOBS` access/error observability helpers
- `MIOMOSAUD` audit helpers
- `MIOMOSUI` SSR data shaping for templates
- `MIOMOSWS` websocket message handling
- `MIOMOST` smoke/regression coverage

## Engineering posture
Follow the standing project rules:
- YottaDB/GT.M compatible
- no `ZSYSTEM`
- no `GOTO` in production code
- quiet tests on success
- structured `ERR("routine")` / `ERR("error")`
- avoid MAXSTRING issues for large bodies; prefer globals or chunked refs when payloads grow

## Observability model in ROI 7
Access, error, and audit records now capture:
- ISO timestamp
- M date/time components for pruning
- event name
- principal
- session id
- route
- request id
- correlation id

Correlation priority:
1. `CTX("request_id")`
2. websocket/session-derived MIOMOS session id
3. sentinel fallback

## Export endpoints
The API now exposes JSON downloads for logs/audit plus a text digest.

Implementation note:
- downloads use `RESPX^MIOHTTP` instead of `RESPJSONX^MIOHTTP` so headers like `Content-Disposition` can be attached cleanly.

## Retention
Retention is configured in `CONFDEF^MIOMOS` and enforced via explicit prune helpers:
- `PRUNE^MIOMOSOBS`
- `PRUNE^MIOMOSAUD`

Current design choice:
- pruning is explicit/on-demand in ROI 7
- no scheduler/background worker is assumed
- counts iterate active records instead of trusting `LAST` ids after pruning

## Testing
`^MIOMOST` now covers:
- route registration for observability endpoints
- boot payload changes
- export permission grants
- correlation IDs
- export helper correctness
- prune correctness

## Known limitations
- desktop UI only links to export endpoints; prune is still API-first
- exports are JSON/text only in this ROI
- websocket disconnect lifecycle is still only partially observable
- per-room chat moderation and multi-user fan-out are still future work
