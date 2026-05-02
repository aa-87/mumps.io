# MIOOS Backend Table

The advanced table component is HTTP-first for bulk data and server mutations. WebSockets remain available for shell control and real-time commands, but table rows, sort requests, and CRUD mutations use HTTP routes for predictable performance and MAXSTRING-safe behavior.

## Current routes

- `POST /api/mioos/table/query`
- `POST /api/mioos/table/mutate`

## Current query payload

```json
{
  "dataset": "demo",
  "page": 1,
  "pageSize": 25,
  "search": "",
  "groupBy": "status",
  "sort": { "column": "name", "direction": "ascending" }
}
```

## Current mutation payloads

```json
{ "dataset": "demo", "action": "row.save", "row": { "name": "New row" } }
{ "dataset": "demo", "action": "row.delete", "rowId": "demo-1" }
{ "dataset": "demo", "action": "rows.delete", "ids": ["demo-1", "demo-2"] }
{ "dataset": "demo", "action": "column.save", "column": { "key": "owner", "label": "Owner", "type": "text", "width": 150 } }
{ "dataset": "demo", "action": "column.delete", "columnKey": "owner" }
{ "dataset": "demo", "action": "column.resize", "columnKey": "owner", "width": 180 }
```

## Built-in datasets

- `demo`: sample operational table
- `patient-registration`: patient registration sample with backend persistence
- `ui-elements`: UI and form controls sample
- `massive`: generated large dataset for pagination and sorting validation
- `vfs`: read-only VFS folder table

## ROI 63 redesign target

ROI 63 documents the production table contract before the ROI 66 rewrite. Runtime behavior is intentionally unchanged in this ROI.

### Target query shape

```json
{
  "dataset": "patient-registration",
  "page": 1,
  "pageSize": 25,
  "search": "smith",
  "filters": {
    "status": ["Active"]
  },
  "sort": {
    "column": "lastName",
    "direction": "ascending"
  },
  "groupBy": "status",
  "columns": [
    { "key": "lastName", "hidden": false, "width": 180 }
  ]
}
```

### Target response shape

```json
{
  "ok": true,
  "dataset": "patient-registration",
  "schema": { "columns": [] },
  "rows": [],
  "groups": [],
  "pagination": {
    "page": 1,
    "pageSize": 25,
    "totalRows": 0,
    "filteredRows": 0,
    "pageRows": 0,
    "pageCount": 1
  },
  "rowActions": [],
  "bulkActions": [],
  "features": {}
}
```

### Target mutation actions

- `row.save`
- `row.delete`
- `rows.delete`
- `column.save`
- `column.delete`
- `column.resize`
- `column.visibility`

Every mutation should return a fresh query-shaped table payload, or a documented mutation result plus refetch directive. Prefer returning the refreshed table payload so client state stays deterministic.

### ROI 66 rewrite requirements

The rewritten table must provide reliable sorting, pagination, search/filtering, select-all-visible, selected-row status, multi-row actions, bulk actions with confirmation, row CRUD, column CRUD, column resizing, column visibility, grouping only when active, working group expand/collapse, no expand arrow unless row details or grouping require it, loading/error/empty states, keyboard accessibility, and a developer-friendly integration API.

## Developer guidance

Use `mioos-full-table` inside module surfaces and set `tableState.dataset` to your dataset name. Add a backend dataset handler in `MIOOSTBL` or delegate to a project routine with the same `QUERY` / `MUTATE` shape. Keep Explorer independent: the backend table may share interaction patterns with Explorer details views, but it must not mutate Explorer state or replace VFS-specific Explorer behavior.

See `docs/mioos/ROI_63_Redesign_Contracts.md` for the complete redesign sequence.

## ROI 64A advanced standalone table contract

The production table track now uses the client-visible contract `mioos-advanced-table-v4`. The component is intended to be standalone and embeddable in internal shell surfaces or user-created modules:

```html
<mioos-full-table table-id="patients" title="Patients" dataset="patient-registration" :config="tableConfig"></mioos-full-table>
```

`window.MIOOSTable.createConfig()` returns a safe default configuration that can enable or disable toolbar features such as dataset switching, search, grouping, column picker, row CRUD, column CRUD, selection, bulk actions, pagination, and row details. Backend query and mutation routes remain authoritative.

`column.visibility` is a supported mutation action. Column visibility changes are persisted through `/api/mioos/table/mutate`, not treated as browser-only state.

## ROI 64C rewrite

ROI 64C upgrades the table to `mioos-advanced-table-v4`. The standalone component now accepts `defaultPageSize`, `defaultSort`, `columns`, and feature gates for `filters`, `resizeColumns`, row details, CRUD, grouping, selection, pagination, and bulk actions. Query payloads include `filters`, and the backend applies exact-match filter arrays before sorting and pagination. Mutations still return a refreshed query-shaped payload so the browser does not have to infer post-mutation state. See `docs/mioos/ROI_64C_Advanced_Table_Rewrite.md`.

## ROI 64C redo — DataTables-style server-side processing

The advanced table contract is now `mioos-advanced-table-v4`. It remains a native MIOOS component, but its request/response envelope is intentionally modeled after DataTables server-side processing so module authors have a familiar mental model.

Each server interaction sends:

- `draw`: monotonically increasing client draw counter.
- `start`: zero-based first record requested.
- `length`: requested page length.
- `order`: ordered column metadata with `column`, `dir`, and `name`.
- `columns`: column descriptors with `data`, `name`, `searchable`, `orderable`, `hidden`, and `width`.

The backend responds with:

- `draw`
- `recordsTotal`
- `recordsFiltered`
- `data`
- native MIOOS `rows`, `schema`, `pagination`, `rowActions`, `bulkActions`, and `features`.

The browser always shows a processing indicator during query and mutation requests. Empty or invalid server responses are surfaced as table errors instead of unhandled Vue/fetch exceptions.

Large dataset performance was hardened by replacing the old O(n²) bubble sort in `MIOOSTBL` with an indexed server-side sort pass before paging. Server-side paging is still authoritative; the browser receives only the current page of `rows`/`data`.
