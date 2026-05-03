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

The production table track now uses the client-visible contract `mioos-advanced-table-v8`. The component is intended to be standalone and embeddable in internal shell surfaces or user-created modules:

```html
<mioos-full-table table-id="patients" title="Patients" dataset="patient-registration" :config="tableConfig"></mioos-full-table>
```

`window.MIOOSTable.createConfig()` returns a safe default configuration that can enable or disable toolbar features such as dataset switching, search, grouping, column picker, row CRUD, column CRUD, selection, bulk actions, pagination, and row details. Backend query and mutation routes remain authoritative. Queries may use WebSocket command mode, while mutations default to WebSocket acknowledgement JSON with HTTP fallback to avoid `socket_timeout` on correctness-critical saves.

`column.visibility` is a supported mutation action. Column visibility changes are persisted through `/api/mioos/table/mutate`, not treated as browser-only state.

## ROI 64C rewrite

ROI 64C upgrades the table to `mioos-advanced-table-v8`. The standalone component now accepts `defaultPageSize`, `defaultSort`, `columns`, and feature gates for `filters`, `resizeColumns`, row details, CRUD, grouping, selection, pagination, and bulk actions. Query payloads include `filters`, and the backend applies exact-match filter arrays before sorting and pagination. Mutations still return a refreshed query-shaped payload so the browser does not have to infer post-mutation state. See `docs/mioos/ROI_64C_Advanced_Table_Rewrite.md`.

## ROI 64C redo — DataTables-style server-side processing

The advanced table contract is now `mioos-advanced-table-v8`. It remains a native MIOOS component, but its request/response envelope is intentionally modeled after DataTables server-side processing so module authors have a familiar mental model.

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

## ROI 64C redo 2 update — `mioos-advanced-table-v8`

The advanced table now uses the `mioos-advanced-table-v8` contract. Table query may use `table.query` over WebSocket. Table mutation now defaults to `/api/mioos/table/mutate` over authenticated HTTP, with WebSocket mutation reserved for future transport hardening.

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

The table contract is now `mioos-advanced-table-v8`. Table examples are written for MUMPS developers first: register a module with `componentKey="table"`, `surface="mioos-surface-table"`, and `tableState` nodes. Normal table modules should not require Vue or JavaScript authoring.

Mutations default to WebSocket `table.mutate` with authenticated HTTP `/api/mioos/table/mutate` fallback. Both transports call `MUTATE^MIOOSTBL` and return acknowledgement JSON rather than full refreshed table payloads.

Read-only/simple variants disable `selection`, `bulkActions`, `rowCrud`, `columnCrud`, and `rowDetails`, which removes the selection and Actions columns from the rendered table.

## ROI 64E update — mutation validation and MUMPS-first examples

The advanced table now uses `mioos-advanced-table-v8`. Mutation reliability is handled through a shared MUMPS path: HTTP `/api/mioos/table/mutate` and WebSocket `table.mutate` both call `MUTATE^MIOOSTBL`, which now validates row fields, row IDs, column keys, column width, and field length before updating table globals. Validation/runtime failures return a deterministic `{ok:false,error:"table_mutate_failed",detail:...}` JSON payload instead of leaving the browser waiting for a socket timeout.

Table Samples now show complete MUMPS snippets: dataset global definition, module `MOD(...)` metadata, and the routines to `ZLINK`/run so a MUMPS developer can render a table without writing frontend code.

Row details are no longer mixed into row actions. Details render as an expand arrow in the ID/control column. Simple/read-only tables continue to omit Actions entirely.

## Table stabilization update — typed filters, option dictionaries, and selected-row export

The current table contract is `mioos-advanced-table-v8`.

Stabilization behavior added before the next ROI:

- Table dialogs use bounded, table-window-relative dragging instead of fixed viewport coordinates.
- The network indicator is a thin loading bar only; there is no loading text block, so draws/sorts do not shift the table layout.
- Filters are modal-first and typed from schema metadata: `text`, `textarea`, `select`, `multiselect`, `boolean`, `date`, and `number` render matching controls.
- Advanced filters support `include`, `exclude`, `contains`, `starts`, `ends`, `range`, `blank`, and `notblank` modes.
- Select-like columns can add a new allowed option with `column.option.add`; the backend stores it under `validation("fields",column,"enum")` and mirrors it into schema options.
- Selected-row CSV export uses the server-side `rows.export` mutation path and returns escaped CSV generated by `EXPORT^MIOOSTBL`.
- Column keys are immutable when editing an existing column; changing the key requires creating a new column.

Example option dictionary update:

```mumps
SET @ROOT@("schema","columns",3,"key")="status"
SET @ROOT@("schema","columns",3,"type")="select"
SET @ROOT@("validation","fields","status","enum",1)="Active"
SET @ROOT@("validation","fields","status","enum",2)="Pending"
```

Runtime option add request:

```json
{
  "dataset": "demo",
  "action": "column.option.add",
  "columnKey": "status",
  "value": "Deferred",
  "mutationOnly": true
}
```

Selected-row CSV export request:

```json
{
  "dataset": "demo",
  "action": "rows.export",
  "ids": ["demo-1", "demo-2"],
  "mutationOnly": true
}
```

The next ROI sequence is defined in `docs/mioos/ROI_64I_64K_Table_DataTables_Parity.md`.


## ROI 64I update — editable cells

The advanced table now supports in-place editable cells through the `cell.save` mutation action. The UI renders the cell editor from schema type metadata (`text`, `textarea`, `select`, `multiselect`, `boolean`, `date`, and `number`) and shows only Save/Cancel controls inside the active cell.

Cell saves use WebSocket `table.mutate` first and HTTP `/api/mioos/table/mutate` as fallback. Both paths call `MUTATE^MIOOSTBL`; the backend validates the target row, column key, editable flag, field rules, and optional `cellCallback` before writing.

MUMPS schema example:

```mumps
SET @ROOT@("schema","columns",3,"key")="status"
SET @ROOT@("schema","columns",3,"label")="Status"
SET @ROOT@("schema","columns",3,"type")="select"
SET @ROOT@("schema","columns",3,"editable")=1
SET @ROOT@("schema","columns",3,"cellCallback")="STATUS^MYTABCB"
SET @ROOT@("validation","fields","status","enum",1)="Active"
SET @ROOT@("validation","fields","status","enum",2)="Pending"
```

Mutation request:

```json
{
  "dataset": "demo",
  "action": "cell.save",
  "rowId": "demo-1",
  "columnKey": "status",
  "value": "Active",
  "mutationOnly": true
}
```

See `docs/mioos/ROI_64I_Editable_Cells.md` for the full callback contract and MUMPS-only example.

## ROI 64J column reorder

Advanced Table modules can enable server-persisted column ordering with:

```mumps
SET MOD("tableState","config","features","columnReorder")=1
```

The browser exposes up/down controls in the Columns modal and sends `column.reorder` through the normal WebSocket-first / HTTP-fallback mutation path. `MUTATE^MIOOSTBL` validates the order with `VALORDER`, rewrites `schema("columns")` in the requested sequence, and returns an acknowledgement-only response so the browser can refetch the table.

The mutation payload must include every existing column exactly once:

```json
{
  "dataset": "demo",
  "action": "column.reorder",
  "columns": [
    { "key": "status", "order": 1 },
    { "key": "name", "order": 2 }
  ]
}
```



## ROI 68 patient-registration foundation

The `patient-registration` dataset now advertises `patientRegistration` metadata in table query responses and is backfilled by `INIT^MIOOSPAT`. Patient-specific validation is layered on top of generic table validation through `VALPAT^MIOOSPAT` / `VALFIELD^MIOOSPAT`, and patient mutations call `AUDPAT^MIOOSPAT` to write sample audit/status markers. Rows still use the same `MUTATE^MIOOSTBL` and `QUERY^MIOOSTBL` paths as other table modules.

## ROI 64L hardening notes

ROI 64L stabilizes the ROI 64F–64K table feature set. The fixed-column contract is now returned from `QUERY^MIOOSTBL` as `schema.fixedColumns` and `fixedColumns`, and fixed-column changes are persisted through `column.fixed` in `MUTATE^MIOOSTBL`. Massive/read-only datasets explicitly return `features.fixedColumns=0`, so sticky user controls are not exposed for the large generated read-only sample.


## ROI 68A backend contract lock

The current Advanced Table contract is `mioos-advanced-table-v8`. `QUERY^MIOOSTBL` returns `OUT("contract")="mioos-advanced-table-v8"` so the browser, docs, and tests can verify the backend response shape. Query responses must include the server-owned rows, schema, grouping, pagination, feature, row-action, and bulk-action nodes. The duplicate `data` alias is omitted unless the request explicitly sets `includeDataAlias` to a true value.

Successful mutation responses are acknowledgement-only. They include `ok`, `dataset`, `action`, `mutationOnly`, `refetch`, `message`, and a small `mutated` node. They must not include `rows` or `schema`. Failed mutations are normalized by both `TABLEMUTATE^MIOOSAPI` and `TABLEMUTATE^MIOOSWS` as deterministic JSON with `ok:false`, `error:"table_mutate_failed"`, `dataset`, `action`, `message`, `fieldErrors` where applicable, `mutationOnly:true`, and `refetch:false`.

Validation metadata supported by `MIOOSTBL` now includes:

```mumps
SET @ROOT@("validation","fields","name","required")=1
SET @ROOT@("validation","fields","owner","maxLength")=40
SET @ROOT@("validation","fields","status","enum",1)="Open"
SET @ROOT@("validation","fields","updated","date")=1
SET @ROOT@("validation","fields","score","numeric")=1
SET @ROOT@("validation","fields","score","min")=0
SET @ROOT@("validation","fields","score","max")=100
SET @ROOT@("validation","fields","active","boolean")=1
SET @ROOT@("validation","fields","tags","multiselect")=1
SET @ROOT@("validation","fields","tags","enum",1)="Core"
SET @ROOT@("validation","routine")="VALMYROW^MYTABVAL"
```

The optional row validation hook signature is `HOOK(IN,ERR,ROOT)`. Return `1` to accept the row and `0` to reject it. Set `ERR("fieldErrors",field)` for browser field highlighting. Optional per-column cell callbacks still use `CALLBACK(STATE,DATASET,ROWID,COLUMN,VALUE,OUT,ERR)` and may set `OUT("value")` to normalize a saved value.

`RUN^MIOOSTBLC` is now part of `D ^MIOOST` and covers query shape, mutation acknowledgements, validation, filtering, grouping, sorting, feature composition, and known table browser regressions.

## ROI 70 patient registration table contract

The `patient-registration` dataset extends the Advanced Table v8 contract with `patientRegistration` metadata from `PATMETA^MIOOSPAT`. The metadata includes review queues, duplicate candidate counts, workflow labels, and direct entry-point guidance. Patient row actions use the normal `MUTATE^MIOOSTBL` path with action keys such as `patient.duplicate.mark`, `patient.duplicate.clear`, `patient.review.pending`, and `patient.review.needs-correction`. Bulk actions include `patient.bulk.pending` and `patient.bulk.needs-correction`.

All patient mutations remain server-side MUMPS actions. Successful mutations return small acknowledgement-only payloads and failed mutations return deterministic validation JSON.

## ROI 71 patient permission and PHI masking contract

The `patient-registration` dataset is permission-gated before patient rows are loaded or mutated. `QUERY^MIOOSTBL` calls `ALLOW^MIOOSPAT(.STATE,"query",.ERR)` before `LOADDATA`, and `MUTATE^MIOOSTBL` calls `ALLOW^MIOOSPAT(.STATE,ACTION,.ERR)` before validation or mutation. Failed access returns deterministic `patient_access_denied` metadata instead of a partial patient payload.

Read-only patient roles receive masked rows through `MASKOUT^MIOOSPAT(.OUT,.STATE)`. The response advertises `features.phiMasked=1` and `patientRegistration.phiMasked=1` so the browser and tests can distinguish a masked list from a full PHI list.

## Regression note — mutation acknowledgements and validation metadata

Successful table mutations may return acknowledgement-only payloads with `mutationOnly: true`. Browser code must not apply those acknowledgements as full query payloads because they do not contain `rows`, `schema.columns`, feature flags, or pagination metadata. Row and cell saves should refetch when the backend asks for it, while preserving the existing table state until the refetch completes.

Query responses now expose `validation.fields` so row editor UIs can mark required fields and provide immediate client-side feedback before the authoritative server-side validation runs. Server-side MUMPS validation remains the source of truth.

## ROI 72 Patient Registration import/reconciliation actions

Patient Registration now exposes import and reconciliation through the same table mutation contract used by row/cell/table actions:

- `patient.import.preview`
- `patient.import.commit`
- `patient.reconcile.report`
- `patient.export.selected`

The browser should call these as mutation-only operations. Backend validation and permissions remain authoritative. `rows.export` remains the CSV-byte export action for selected rows.

## ROI 72A stabilization notes

- Patient Registration status transitions now expose `patient.review.active` and `patient.review.inactive` as MUMPS-owned table actions. `patient.bulk.active` marks selected patients active through the same backend mutation channel.
- Table action feedback should be rendered as a floating modal toast. Do not reintroduce inline success text that shifts the table body.
- Cell editors must keep compact save/cancel controls visible in narrow cells. Enter saves the active cell edit and Escape cancels it.
- Select/multiselect Add Value remains a `column.option.add` mutation, not a browser-only option injection.
