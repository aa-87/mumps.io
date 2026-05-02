# MIOOS UI Modules

The module registry is installed but disabled by default in boot state. The App Catalogue fetches the registry after sign-in through `/api/mioos/modules/catalog`.

Built-in catalogue entries include:

- App Catalogue
- Table Samples
- Massive Dataset Table
- Permissions UI
- UI + Form Elements
- Patient Registration

The module catalogue can launch table-backed surfaces by setting:

```json
{
  "componentKey": "table",
  "surface": "mioos-surface-table",
  "tableState": { "dataset": "patient-registration" }
}
```

Permissions UI uses `mioos-surface-permissions` and demonstrates tabbed permission panels, role matrix toggles, and an audit sample.

## ROI 64B UI elements example rewrite

`UI + Form Elements` is no longer table-backed. It now launches as a standalone component gallery:

```json
{
  "componentKey": "ui-elements",
  "surface": "mioos-surface-ui-elements"
}
```

The gallery is interactive and stateful. It demonstrates text inputs, textareas, selects, radio groups, checkbox groups, switches, date and number inputs, file-picker metadata capture, validation, required/optional indicators, disabled/read-only states, saving/loading states, inline help, tabbed form sections, modal forms, confirmation dialogs, toasts, empty states, and error states.

The example intentionally avoids backend table coupling. Production modules should copy the interaction and accessibility patterns, then submit sanitized payloads through authenticated backend routes for persistence and audit.


## ROI 64C table modules

Table-backed modules should use `mioos-surface-table` with the `mioos-advanced-table-v5` contract. Provide a dataset and optional `config` object instead of writing custom table state logic. The table owns WebSocket-first query/mutation state with HTTP fallback, server filtering, selection, grouping, column visibility, resizing, and row/column CRUD.

## ROI 64C redo table module guidance

Table modules should now target `mioos-advanced-table-v5`. The contract is DataTables-inspired but remains a MIOOS-native Vue Options API component. Module authors should configure datasets, columns, and feature gates; they should not fork table rendering or implement custom client-side pagination for large datasets.

## Table Samples showcase

`table-samples` now opens `mioos-surface-table-showcase` instead of a single static table. The showcase demonstrates simple, dense, editable, patient-registration, and massive read-only table variations. Each card includes the `MIOOSTable.createConfig(...)` code needed to open that table from a simple MIOOS window or user-created module.

The table component itself remains `mioos-full-table`; the showcase is a developer reference surface for choosing the right configuration.
