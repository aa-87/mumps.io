# ROI 64D — Table performance, mutation correctness, and MUMPS developer contracts

This ROI follows the table rewrite and addresses the latest production feedback from the attached source state.

## Goals

1. Stop table mutations from timing out on the core WebSocket path.
2. Keep large table reads server-side and fast.
3. Remove selection/action chrome from read-only and simple table variants.
4. Make the table examples useful to MUMPS developers with no frontend experience.
5. Keep the browser component generic; MUMPS owns module registration, dataset shape, query, mutation, validation, and persistence.

## Transport contract

The table contract is now:

```text
mioos-advanced-table-v8
```

Query remains server-side and may use WebSocket command mode:

```text
table.query
```

Mutations now default to the authenticated HTTP route:

```text
POST /api/mioos/table/mutate
```

Reason: the reported `socket_timeout` occurred on `table.mutate`. Row and column mutations are small but correctness-critical, so the component now uses an HTTP-safe mutation path by default while retaining WebSocket query support for read performance. `mutateTransport` may be changed later after a dedicated WebSocket mutation transport test harness exists.

## Performance behavior

The `massive` dataset now has a fast path in `MIOOSTBL` for the common no-search/no-filter server-page query. It calculates the requested page directly and materializes only those rows. It does not build a 10,000-row work array for default paging.

When search, filters, or non-linear generated sorts are used, `MIOOSTBL` still evaluates server-side so the browser never receives the full dataset.

## Read-only and simple table correctness

Read-only/simple tables should not show a useless Actions column. The client now computes whether to render:

- the selection column
- the Actions column
- bulk action bar
- row detail buttons

from the merged client feature gates and backend feature flags.

The massive dataset publishes:

```mumps
SET OUT("features","readOnly")=1
SET OUT("features","crudRows")=0
SET OUT("features","crudColumns")=0
SET OUT("features","selection")=0
SET OUT("features","bulkActions")=0
SET OUT("features","actionRows")=0
SET OUT("features","expansionRows")=0
```

## MUMPS-first module examples

The Table Samples surface now shows MUMPS contract snippets instead of JavaScript `MIOOSTable.createConfig(...)` calls. A MUMPS developer should be able to create a table module by setting the module catalog/tableState nodes.

Minimal MUMPS registration shape:

```mumps
SET MOD("componentKey")="table"
SET MOD("surface")="mioos-surface-table"
SET MOD("tableState","id")="orders-table"
SET MOD("tableState","title")="Orders"
SET MOD("tableState","dataset")="orders"
SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
SET MOD("tableState","config","density")="compact"
SET MOD("tableState","config","defaultPageSize")=25
```

Simple read-only table with no action column:

```mumps
SET MOD("tableState","config","features","rowCrud")=0
SET MOD("tableState","config","features","columnCrud")=0
SET MOD("tableState","config","features","selection")=0
SET MOD("tableState","config","features","bulkActions")=0
SET MOD("tableState","config","features","rowDetails")=0
```

Editable table:

```mumps
SET MOD("tableState","config","features","rowCrud")=1
SET MOD("tableState","config","features","columnCrud")=1
SET MOD("tableState","config","features","selection")=1
SET MOD("tableState","config","features","bulkActions")=1
```

## Guardrails

- Do not teach frontend-first table integration in the examples.
- Do not require module authors to write Vue code for normal table modules.
- Keep all table persistence and validation in MUMPS.
- Keep VFS upload transport changes for a dedicated transport ROI; this ROI only removes the mutation timeout from table operations.
