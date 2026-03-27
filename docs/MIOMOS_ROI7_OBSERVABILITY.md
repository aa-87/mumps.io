# MIOMOS ROI 7: observability hardening and retention

## Scope
This ROI moves MIOMOS from basic in-memory operational logging to a more production-minded observability baseline.

Implemented in this ROI:
- explicit observability/export routes registered through `MIOROUTE`
- structured access/error/audit export helpers
- correlation IDs captured in access, error, and audit records
- retention policy config defaults in `CONF("miomos",...)`
- on-demand pruning for access, error, and audit stores
- downloadable JSON exports for access/error/audit
- downloadable text security digest
- SSR security window links for summary/export/digest endpoints
- smoke tests for routes, boot payload, exports, permissions, and pruning

Not yet implemented in this ROI:
- scheduled/background pruning jobs
- CSV exports
- redaction policy editor UI
- full admin form wiring for retention actions
- multi-tenant partitioning of observability data

## New route surface
- `GET /api/miomos/observability/summary`
- `GET /api/miomos/observability/access/export`
- `GET /api/miomos/observability/error/export`
- `GET /api/miomos/observability/audit/export`
- `GET /api/miomos/observability/digest`
- `POST /api/miomos/observability/retention/prune`

## Permission model
New permissions added:
- `logs.export`
- `audit.export`
- `digest.export`
- `retention.manage`

Role grants in this ROI:
- `developer`: all four
- `security`: all four
- `auditor`: log/audit/digest export
- `support`: log export + digest export
- `admin`: all permissions through admin wildcard behavior

## Retention defaults
`CONFDEF^MIOMOS` now sets:
- `CONF("miomos","log","maxEntries")=500`
- `CONF("miomos","log","exportLimit")=250`
- `CONF("miomos","log","digestTail")=6`
- `CONF("miomos","log","access","retainDays")=30`
- `CONF("miomos","log","error","retainDays")=90`
- `CONF("miomos","audit","retainDays")=180`

## Correlation model
Correlation is intentionally simple and MIO-aligned:
1. use `CTX("request_id")` when available
2. otherwise fall back to MIOMOS session id
3. otherwise use a sentinel correlation id

This gives operators a stable join key across:
- desktop render
- bootstrap
- auth actions
- admin actions
- websocket-originated actions that were resumed from a MIOMOS session

## Operational notes
- pruning is on-demand in ROI 7 and safe to call repeatedly
- exports are JSON attachments to keep downstream parsing simple
- the digest is text/plain so it can be archived or attached to support tickets easily
- counts are based on active records, not just `LAST` ids, so gaps after pruning do not break summaries

## Testing notes
`^MIOMOST` now covers:
- new observability route registration
- new boot payload fields
- correlation capture
- export payload content
- permission grants for observability exports
- prune behavior for access and audit stores
