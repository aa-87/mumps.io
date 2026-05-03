# MIOOS Backend Table

The advanced table component is WebSocket-first for table queries and server mutations, with authenticated HTTP fallback. WebSockets remain available for shell control and real-time commands, but table rows, sort requests, and CRUD mutations prefer WebSocket commands and fall back to the protected HTTP routes when the socket is unavailable.

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

The production table track now uses the client-visible contract `mioos-advanced-table-v7`. The component is intended to be standalone and embeddable in internal shell surfaces or user-created modules:

```html
<mioos-full-table table-id="patients" title="Patients" dataset="patient-registration" :config="tableConfig"></mioos-full-table>
```

`window.MIOOSTable.createConfig()` returns a safe default configuration that can enable or disable toolbar features such as dataset switching, search, grouping, column picker, row CRUD, column CRUD, selection, bulk actions, pagination, and row details. Backend query and mutation routes remain authoritative. Queries may use WebSocket command mode, while mutations default to HTTP-safe JSON to avoid `socket_timeout` on correctness-critical saves.

`column.visibility` is a supported mutation action. Column visibility changes are persisted through `/api/mioos/table/mutate`, not treated as browser-only state.

## ROI 64C rewrite

ROI 64C upgrades the table to `mioos-advanced-table-v7`. The standalone component now accepts `defaultPageSize`, `defaultSort`, `columns`, and feature gates for `filters`, `resizeColumns`, row details, CRUD, grouping, selection, pagination, and bulk actions. Query payloads include `filters`, and the backend applies exact-match filter arrays before sorting and pagination. Mutations still return a refreshed query-shaped payload so the browser does not have to infer post-mutation state. See `docs/mioos/ROI_64C_Advanced_Table_Rewrite.md`.

## ROI 64C redo — DataTables-style server-side processing

The advanced table contract is now `mioos-advanced-table-v7`. It remains a native MIOOS component, but its request/response envelope is intentionally modeled after DataTables server-side processing so module authors have a familiar mental model.

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

## ROI 64C redo 2 update — `mioos-advanced-table-v7`

The advanced table now uses the `mioos-advanced-table-v7` contract. Table query may use `table.query` over WebSocket. Table mutation now defaults to `/api/mioos/table/mutate` over authenticated HTTP, with WebSocket mutation reserved for future transport hardening.

The visible UI no longer exposes internal draw counters or response timestamps. Draw/start/length remain protocol fields for server-side paging compatibility, but the user-facing footer only shows row counts and page navigation.

The default table density is `compact` for data-intensive MIOOS screens. Module authors can still opt into a larger layout by passing `density: 'comfortable'` through `MIOOSTable.createConfig`.

The `massive` dataset is read-only and page-materialized on the server. For the common no-search/no-filter path, `MIOOSTBL` calculates the requested page directly and generates only those rows instead of building a full 10,000-row work array.

### Copyable API variations

Simple table:

```javascript
this.openBackendTableWindow({
  title: 'Simple Table',
  dataset: 'demo',
  config: MIOOSTable.createConfig({
    features: {
      filters: false,
      grouping: false,
      columnPicker: false,
      rowCrud: false,
      columnCrud: false,
      selection: false,
      bulkActions: false,
      rowDetails: false
    }
  })
});
```

Dense editable table:

```javascript
this.openBackendTableWindow({
  title: 'Dense Operations',
  dataset: 'demo',
  config: MIOOSTable.createConfig({
    density: 'compact',
    transport: 'websocket',
    defaultPageSize: 50,
    actionsWidth: 132,
    features: {
      rowCrud: true,
      columnCrud: true,
      selection: true,
      bulkActions: true,
      resizeColumns: true,
      columnGroups: false
    }
  })
});
```

Massive read-only table:

```javascript
this.openBackendTableWindow({
  title: 'Massive Dataset',
  dataset: 'massive',
  config: MIOOSTable.createConfig({
    defaultPageSize: 100,
    features: {
      rowCrud: false,
      columnCrud: false,
      rowDetails: false
    }
  })
});
```


## ROI 64D — MUMPS-first table contract

The table contract is now `mioos-advanced-table-v7`. Table examples are written for MUMPS developers first: register a module with `componentKey="table"`, `surface="mioos-surface-table"`, and `tableState` nodes. Normal table modules should not require Vue or JavaScript authoring.

Mutations default to authenticated HTTP (`/api/mioos/table/mutate`) to avoid the reported `socket_timeout` on `table.mutate`. Queries may still use WebSocket for responsive server-side paging.

Read-only/simple variants disable `selection`, `bulkActions`, `rowCrud`, `columnCrud`, and `rowDetails`, which removes the selection and Actions columns from the rendered table.

## ROI 64E update — mutation validation and MUMPS-first examples

The advanced table now uses `mioos-advanced-table-v7`. Mutation reliability is handled through a shared MUMPS path: HTTP `/api/mioos/table/mutate` and WebSocket `table.mutate` both call `MUTATE^MIOOSTBL`, which now validates row fields, row IDs, column keys, column width, and field length before updating table globals. Validation/runtime failures return a deterministic `{ok:false,error:"table_mutate_failed",detail:...}` JSON payload instead of leaving the browser waiting for a socket timeout.

Table Samples now show complete MUMPS snippets: dataset global definition, module `MOD(...)` metadata, and the routines to `ZLINK`/run so a MUMPS developer can render a table without writing frontend code.

Row details are no longer mixed into row actions. Details render as an expand arrow in the ID/control column. Simple/read-only tables continue to omit Actions entirely.

## ROI 64G stabilization — visibility, validation, Notes, and modal controls

Table mutation booleans are normalized server-side before persistence. This is important because the JSON parser represents JSON booleans as `"true"` / `"false"` literals; `column.visibility` now uses `TRUTH^MIOOSTBL` so hiding and showing columns survives the acknowledgement/refetch cycle.

Existing demo table globals are upgraded in place. If a user already had a seeded demo table without ROI 64G validation nodes, `ENSURE^MIOOSTBL` now backfills validation rules and the editable `notes` column without wiping rows. The Notes value is copied from `_expand("body")` when needed.

The browser table surface now uses modal dialogs for filter and grouping setup, shows non-blocking success toasts after mutations, and renders pagination as a visible page range instead of a static filtered/total-only count.

## ROI 64G stabilization follow-up — table controls and validation

This follow-up fixes the post-ROI 64G table behavior without starting ROI 64H.

- Column visibility now normalizes JSON booleans through `TRUTH^MIOOSTBL`, so `true`, `false`, `1`, `0`, `yes`, and `on` are handled deterministically when `/api/mioos/table/mutate` receives `column.visibility`.
- Existing seeded datasets are upgraded in place by `UPGRADE^MIOOSTBL`; the demo table receives the editable `notes` schema column and validation rules even when the user already had table globals from an earlier ROI.
- Row validation is enforced by `VALRULES^MIOOSTBL` before persistence. HTTP and WebSocket mutation errors include `fieldErrors` so the browser can keep the editor open and highlight the affected fields.
- The browser uses modal controls for filtering, grouping, and column visibility. Grouping sends `groupByColumns` and may include more than one grouping key.
- The pagination footer now reports the visible page range, for example `Showing 51–100 of 237 rows`, instead of always showing only total rows.

## Table stabilization before ROI 64H — typed editing and selected-row CSV export

This stabilization pass keeps the project on the ROI 64G table track and fixes runtime behavior before the next ROI begins.

### Strict date validation

Date-typed columns are validated both in the browser and in `DATEOK^MIOOSTBL`. The accepted format is `YYYY-MM-DD`, and impossible calendar dates such as `2026-02-31` are rejected before persistence. Mutation failures keep the editor open and return `fieldErrors`, for example:

```json
{
  "ok": false,
  "error": "table_mutate_failed",
  "detail": "validation_failed",
  "fieldErrors": {
    "updated": "Use YYYY-MM-DD"
  },
  "mutationOnly": true,
  "refetch": false
}
```

### Server-side CSV export

Selected-row export is a backend mutation-style command named `rows.export`. The browser sends the selected row IDs, and `EXPORT^MIOOSTBL` builds RFC-style CSV server-side with escaped commas, quotes, and line breaks. The response includes `exportOnly=1`, a file name, `contentType="text/csv"`, row count, and the CSV text.

```json
{
  "dataset": "demo",
  "action": "rows.export",
  "ids": ["demo-1", "demo-2"]
}
```

### Column key safety

Column keys are identity values. When an existing column is edited, the UI carries `originalKey` and disables key editing. The backend honors `originalKey` and updates the existing schema entry instead of creating a new column with the changed key.

### Cell typing

Schema and validation metadata are reflected into browser editor controls:

- `type="date"` renders a date input and server date validation.
- `type="number"` renders a numeric input and numeric validation.
- `type="textarea"` renders a multi-line editor.
- enum validation metadata renders a select control.
- `type="multiselect"` renders a multiple select control when options exist.
- `type="boolean"` renders a checkbox.

The `notes` demo column is now a textarea-backed editable grouped column rather than only an expansion body.

### System-style draggable dialogs

Table dialogs use the same system-window visual language as other shell components. Filter, grouping, column picker, and editor dialogs are emitted as `.mioos-system-modal` windows with a `.mioos-table-window-titlebar` drag handle.
