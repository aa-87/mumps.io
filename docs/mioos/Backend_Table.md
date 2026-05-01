# MIOOS Backend Table Component

The backend table component is a reusable MIOOS data-grid surface derived from the Explorer details table interaction model. It keeps the Explorer implementation stable while exposing a generic, server-backed table for future MUMPS application screens.

## Goals

- Server-authored query contract through `MIOOSTBL`.
- Thin Vue 3 Options API UMD component in `public/mioos/app/mioos_table.js`.
- Native shell styling that matches Explorer details views without coupling to Explorer state.
- No new framework, build step, or client-only data authority.

## Backend contract

HTTP route:

```text
POST /api/mioos/table/query
```

Route handler:

```text
TABLEQUERY^MIOOSAPI -> QUERY^MIOOSTBL
```

Request shape:

```json
{
  "dataset": "demo | vfs",
  "folderId": "optional VFS folder id/path for vfs dataset",
  "page": 1,
  "pageSize": 25,
  "search": "optional global search",
  "sort": { "column": "name", "direction": "ascending" },
  "groupBy": "optional column key",
  "columns": [
    { "key": "name", "hidden": false, "width": 240 }
  ]
}
```

Response shape:

```json
{
  "ok": 1,
  "dataset": "vfs",
  "schema": {
    "columns": [
      { "key": "name", "label": "Name", "type": "text", "width": 260, "sortable": 1, "resizable": 1 }
    ]
  },
  "rows": [],
  "pagination": {
    "page": 1,
    "pageSize": 25,
    "totalRows": 100,
    "filteredRows": 45,
    "pageRows": 25,
    "pageCount": 2
  },
  "groups": [],
  "rowActions": [],
  "bulkActions": [],
  "features": {
    "serverPagination": 1,
    "serverSorting": 1,
    "columnVisibility": 1,
    "columnGrouping": 1,
    "expansionRows": 1,
    "actionRows": 1,
    "selection": 1,
    "filtering": 1
  }
}
```

## Supported features

- Backend pagination with configurable page size and max page-size guard.
- Per-column server sorting.
- Global search filtering.
- Column visibility toggles.
- Resizable column widths using pointer events.
- Column group header rows.
- Row expansion details.
- Row action buttons.
- Bulk action buttons with selected-row count.
- Multi-row selection.
- VFS-backed dataset for folders and a demo dataset for application scaffolding.
- Client fallback transformation if the HTTP request fails, so development surfaces remain usable.

## Extension rules

- Add new datasets in `MIOOSTBL`, not in the browser.
- Keep row shape JSON-compatible and avoid executable client payloads.
- Use schema columns for all table behavior; do not hard-code application columns in Vue surfaces.
- Keep action execution auditable. The initial component records queued actions in the table state; future application screens should map actions to explicit MIOOS routes or websocket commands.

## Regression coverage

`D ^MIOOST` includes `T062`, which verifies:

- route registration,
- API handler,
- backend query routine,
- client component registration,
- resizable columns,
- sorting,
- pagination,
- column visibility,
- grouping,
- expansion rows,
- action rows,
- CSS,
- documentation,
- and LLM handoff notes.
