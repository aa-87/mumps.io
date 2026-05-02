# ROI 64C — Standalone Advanced Table Component Rewrite

ROI 64C rewrites the advanced table as a standalone, configurable component for internal MIOOS UI and user-created modules.

## Contract

The client-visible table contract is now `mioos-advanced-table-v3`.

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

- Standalone `mioos-advanced-table-v3` configuration surface.
- Configurable feature gates for search, filters, grouping, column picker, row CRUD, column CRUD, selection, bulk actions, pagination, row details, and column resizing.
- Backend filtering through `filters` in the query payload.
- Page clamping after search/filter operations so out-of-range pages do not show false-empty results.
- Mutation status feedback for row and column saves/deletes.
- Defensive column-key sanitization that avoids invalid M syntax and rejects bad column metadata before persistence.
- Confirmation for destructive row, bulk row, and column operations.
- Column visibility, resize, and CRUD remain server-authoritative.

## Accessibility and integration notes

The table exposes status regions for loading/saving/toast feedback and keeps selection, grouping, and row details keyboard-accessible through native buttons, inputs, and details controls. User-created modules should avoid directly mutating table internals; they should set `dataset`, `folderId`, and `config`, then let the table query/mutation contract own state synchronization.
