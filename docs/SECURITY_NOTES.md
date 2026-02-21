# MIOTPL2 Security Notes

## Path traversal protection (NAME-based renders)

MIOTPL2 rejects:
- `..`
- `:`
- absolute paths (`/`)

Recommendation: allow-list template names and keep the templates directory non-writable by untrusted users.

## Recursion limits (partials/parents)

MIOTPL2 enforces `CONF("templates","maxPartialDepth")` (default 20). Exceeding it returns `ERR("code")="TPL_PARTIAL_DEPTH"`.

## Lambda safety

Lambdas execute via `X` (XECUTE). Treat them as trusted-only. If user-controlled data can reach lambda values, add an allow-list gate or disable lambdas in production.

## Large output / MAXSTRING

For endpoints that can produce large output, prefer REF output (`RENDERREF`) or `RENDERX` auto mode.
