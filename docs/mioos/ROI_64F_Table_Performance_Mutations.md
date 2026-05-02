# ROI 64F — Table mutation acknowledgements, performance, multi-column grouping, and MUMPS-first table entry points

## Diagnosis

The attached source was still on the `mioos-advanced-table-v7` contract. Table mutation requests used the same payload shape as a full table query and `MUTATE^MIOOSTBL` called `QUERY^MIOOSTBL` after writing. That meant a small change such as `column.visibility` could wait for a refreshed table payload and could surface as `socket_timeout` instead of a deterministic JSON acknowledgement.

## Contract

ROI 64F upgrades the table contract to `mioos-advanced-table-v8`.

### Query request

```json
{
  "dataset": "demo",
  "page": 1,
  "pageSize": 50,
  "draw": 4,
  "start": 0,
  "length": 50,
  "serverSide": true,
  "processing": true,
  "search": "alpha",
  "filters": { "status": ["Active", "Pending"] },
  "sort": { "column": "name", "direction": "ascending" },
  "groupBy": "status",
  "groupByColumns": ["status", "priority"],
  "includeDataAlias": false
}
```

### Query response

```json
{
  "ok": true,
  "contract": "mioos-advanced-table-v8",
  "dataset": "demo",
  "draw": 4,
  "recordsTotal": 10000,
  "recordsFiltered": 120,
  "schema": { "columns": [] },
  "rows": [],
  "groups": [],
  "pagination": {
    "page": 1,
    "pageSize": 50,
    "totalRows": 10000,
    "filteredRows": 120,
    "pageRows": 50,
    "pageCount": 3
  },
  "features": {},
  "rowActions": [],
  "bulkActions": []
}
```

`data` is not returned by default. It is emitted only when `includeDataAlias: true` is requested for legacy consumers.

## Mutation acknowledgement

Mutation requests should be small and mutation-only:

```json
{
  "dataset": "demo",
  "action": "column.visibility",
  "columnKey": "updated",
  "hidden": false,
  "mutationOnly": true
}
```

Successful acknowledgement:

```json
{
  "ok": true,
  "dataset": "demo",
  "action": "column.visibility",
  "mutationOnly": true,
  "refetch": true,
  "message": "Column visibility updated"
}
```

Validation/error acknowledgement:

```json
{
  "ok": false,
  "dataset": "demo",
  "action": "row.save",
  "error": "validation_failed",
  "message": "Name is required",
  "fieldErrors": { "name": "Required" },
  "mutationOnly": true,
  "refetch": false
}
```

HTTP `/api/mioos/table/mutate` and WebSocket `table.mutate` both call the same `MUTATE^MIOOSTBL` backend logic. Both paths now return deterministic JSON and do not perform a full table query before acknowledgement.

## Performance

The massive dataset remains server-side. The `MASSFASTQ` path receives the query context, materializes only the requested page, avoids browser-side full arrays, and avoids the duplicate `data` alias unless explicitly requested.

Read-only datasets such as `massive` and `vfs` do not emit row actions or bulk actions. Their feature flags disable row CRUD, column CRUD, selection, bulk actions, and row details.

## Multi-column grouping

The query contract supports:

```json
"groupByColumns": ["status", "priority"]
```

`GROUPREQ^MIOOSTBL` normalizes `groupByColumns` and falls back to the legacy single `groupBy` field. `GROUPS^MIOOSTBL` builds stable compound group keys such as `status=Active / priority=High` and labels such as `Active / High`.

The UI renders a grouping checklist and active grouping chips. The legacy one-column selector is replaced by the checklist so MUMPS developers can configure multiple grouping columns without writing frontend code.

## Pagination page jump

The table footer now includes a direct page jump input with a **Go** button. Invalid values are clamped between page 1 and `pagination.pageCount`, then the table refetches the selected page.

## Timeout behavior

Table mutation timeout is command-specific. The default frontend config uses:

```text
tableMutationTimeoutMs: 4500
tableQueryTimeoutMs: 8000
```

WebSocket `command()` now accepts per-command options so `table.query` and `table.mutate` can use shorter timeouts without changing unrelated socket commands. HTTP mutations use `AbortController` where available. Timeout UX shows:

```text
Table mutation timed out. The change was not confirmed. Please retry.
```

## MUMPS-first entry points

The table examples document:

- dataset schema and rows under `^MIO("MIOOS","TABLE",user,dataset,...)`
- module metadata with `componentKey="table"` and `surface="mioos-surface-table"`
- desktop/app entry point shape using `appKey`, `title`, `icon`, `surface`, and `tableState`
- reload and validation commands: `ZLINK "MIOOSTBL"`, `ZLINK "MIOOSAPI"`, `ZLINK "MIOOSWS"`, `ZLINK "MIOOSMOD"`, `ZLINK "MIOOST"`, `DO INIT^MIOOS(.CONF)`, `DO ^MIOOST`

## Tests

`T068^MIOOST` locks the ROI 64F contract markers: table v8, mutation acknowledgement shape, `groupByColumns`, `includeDataAlias`, massive fast path context, short mutation timeout, page jump, deterministic HTTP/WS mutation errors, MUMPS-first examples, and LLM notes.
