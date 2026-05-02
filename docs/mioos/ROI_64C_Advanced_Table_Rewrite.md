# ROI 64C — Standalone Advanced Table Component Rewrite

ROI 64C rewrites the advanced table as a standalone, configurable component for internal MIOOS UI and user-created modules.

## Contract

The client-visible table contract is now `mioos-advanced-table-v4`.

Use the table through the Vue Options API component:

```html
<mioos-full-table
  table-id="patients"
  title="Patients"
  dataset="patient-registration"
  :config="tableConfig">
</mioos-full-table>
```

Or create configuration through the browser helper:

```js
const tableConfig = window.MIOOSTable.createConfig({
  defaultPageSize: 25,
  defaultSort: { column: 'lastName', direction: 'ascending' },
  features: {
    datasetSwitcher: false,
    search: true,
    filters: true,
    grouping: true,
    columnPicker: true,
    rowCrud: true,
    columnCrud: true,
    selection: true,
    bulkActions: true,
    pagination: true,
    rowDetails: true,
    resizeColumns: true
  }
});
```

## Query shape

The table sends HTTP-first query requests to `/api/mioos/table/query`:

```json
{
  "dataset": "patient-registration",
  "page": 1,
  "pageSize": 25,
  "search": "smith",
  "filters": { "status": ["Active"] },
  "sort": { "column": "lastName", "direction": "ascending" },
  "groupBy": "status",
  "columns": [
    { "key": "lastName", "hidden": false, "width": 180 }
  ]
}
```

## Mutation shape

The table sends HTTP-first mutation requests to `/api/mioos/table/mutate` and expects a refreshed query-shaped payload after mutation.

Supported actions:

- `row.save`
- `row.delete`
- `rows.delete`
- `column.save`
- `column.delete`
- `column.resize`
- `column.visibility`

All column keys are validated server-side and must start with a letter and contain only letters, numbers, and underscores. Invalid non-namespaced actions are rejected.

## Production behavior added in ROI 64C

- Standalone `mioos-advanced-table-v4` configuration surface.
- Configurable feature gates for search, filters, grouping, column picker, row CRUD, column CRUD, selection, bulk actions, pagination, row details, and column resizing.
- Backend filtering through `filters` in the query payload.
- Page clamping after search/filter operations so out-of-range pages do not show false-empty results.
- Mutation status feedback for row and column saves/deletes.
- Defensive column-key sanitization that avoids invalid M syntax and rejects bad column metadata before persistence.
- Confirmation for destructive row, bulk row, and column operations.
- Column visibility, resize, and CRUD remain server-authoritative.

## Accessibility and integration notes

The table exposes status regions for loading/saving/toast feedback and keeps selection, grouping, and row details keyboard-accessible through native buttons, inputs, and details controls. User-created modules should avoid directly mutating table internals; they should set `dataset`, `folderId`, and `config`, then let the table query/mutation contract own state synchronization.

## ROI 64C redo — DataTables-style server-side contract

This redo addresses the post-ROI findings:

1. Table controls and headers must remain legible in light and dark themes. The table CSS now explicitly sets readable foreground/background combinations for the toolbar, filters, headers, rows, group rows, editor, pager, and processing indicators.
2. Large datasets must use server-side paging/order/filter semantics. The client now sends DataTables-style `draw`, `start`, `length`, `order`, and `columns` metadata on each query/mutation request while keeping the existing MIOOS `page`, `pageSize`, `sort`, `filters`, and `columns` compatibility shape.
3. Mutations must not leave the browser with an unhandled `Failed to fetch` error. The client now parses response text defensively, reports empty/invalid responses as table errors, keeps the editor open on failed saves, and displays the server-communication state while the request is in flight.
4. The API is modeled around the DataTables server-side processing pattern: every draw has a counter, a zero-based record start, a page length, order metadata, column metadata, and a response containing `draw`, `recordsTotal`, `recordsFiltered`, and page `data` in addition to the native MIOOS `rows` payload.
5. The backend sort path no longer uses an O(n²) bubble sort. `MIOOSTBL` now builds an indexed sort map and then pages the sorted working set, which is materially faster for the 10,000-row sample.

### DataTables-style query overlay

The table still posts to `/api/mioos/table/query`, but each request includes both the native MIOOS shape and a DataTables-compatible overlay:

```json
{
  "dataset": "massive",
  "page": 1,
  "pageSize": 25,
  "draw": 7,
  "start": 0,
  "length": 25,
  "serverSide": true,
  "processing": true,
  "search": "worker 4",
  "sort": { "column": "name", "direction": "ascending" },
  "order": [{ "column": 1, "dir": "asc", "name": "name" }],
  "columns": [
    { "data": "name", "name": "name", "searchable": true, "orderable": true, "hidden": false, "width": 210 }
  ]
}
```

### DataTables-style response overlay

Responses include the native MIOOS table payload and these DataTables-compatible fields:

```json
{
  "ok": true,
  "draw": 7,
  "recordsTotal": 10000,
  "recordsFiltered": 10000,
  "rows": [],
  "data": [],
  "pagination": {
    "page": 1,
    "pageSize": 25,
    "totalRows": 10000,
    "filteredRows": 10000,
    "pageRows": 25,
    "pageCount": 400
  }
}
```

`rows` remains the canonical MIOOS field; `data` is provided for developers familiar with DataTables conventions.
