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

Table-backed modules should use `mioos-surface-table` with the `mioos-advanced-table-v8` contract. Provide a dataset and optional `config` object instead of writing custom table state logic. The table owns WebSocket-first query/mutation state with HTTP fallback, server filtering, selection, grouping, column visibility, resizing, and row/column CRUD.

## ROI 64C redo table module guidance

Table modules should now target `mioos-advanced-table-v8`. The contract is DataTables-inspired but remains a MIOOS-native Vue Options API component. Module authors should configure datasets, columns, and feature gates; they should not fork table rendering or implement custom client-side pagination for large datasets.

## Table Samples showcase

`table-samples` now opens `mioos-surface-table-showcase` instead of a single static table. The showcase demonstrates simple, dense, editable, patient-registration, and massive read-only table variations. Each card includes MUMPS `SET MOD(...)` contract snippets needed to register that table from the backend catalog or a user-created module.

The table component itself remains `mioos-full-table`; the showcase is a developer reference surface for choosing the right configuration.

## ROI 64E table module guidance

For table modules, prefer backend `MOD(...)` and dataset globals over frontend snippets. `mioos-surface-table` reads `MOD("tableState",...)`, so a MUMPS developer should define the dataset under `^MIO("MIOOS","TABLE",user,dataset,...)` and then set `MOD("componentKey")="table"`, `MOD("surface")="mioos-surface-table"`, and `MOD("tableState","dataset")=<dataset>`.

The table UI now separates row details from actions. Details are an expand arrow in the control column. Row actions remain in the Actions column and only render when row CRUD/action features are enabled. Column selection is modal-only, and column editing is exposed only when column CRUD is enabled.

## Advanced table stabilization notes

Table modules now target `mioos-advanced-table-v8`. Use schema `type` and validation enum metadata to drive typed row editors and typed filter controls. Table modals should use the bounded table-window dialog helpers, not fixed viewport overlays.

The next planned table module sequence is ROI 64I through ROI 64K:

- ROI 64I: editable cells with typed controls and optional MUMPS cell callbacks. Implemented through `cell.save` and documented in `ROI_64I_Editable_Cells.md`.
- ROI 64J: column reorder on boot and as a user option.
- ROI 64K: fixed columns on boot and as a user option.

See `ROI_64I_64K_Table_DataTables_Parity.md` for the MUMPS contracts.


## ROI 64I editable-cell module behavior

Table-backed modules can enable cell editing with:

```mumps
SET MOD("tableState","config","features","cellEditing")=1
SET MOD("tableState","config","mutateTransport")="websocket"
```

The module author controls each cell from MUMPS schema metadata. Non-ID columns default to editable unless `editable=0`; ID columns remain read-only. Optional column `cellCallback` entries let a MUMPS routine validate or normalize a single cell before persistence without frontend code.


## ROI 64J table modal and column reorder behavior

The table surface now uses table-owned MIOOS dialogs for Add Value and destructive confirmations. Native `prompt()` and `confirm()` are not used for table controls. Close buttons stop pointer events before they reach draggable title bars, so the `×` control dismisses the current dialog reliably.

The Columns modal also includes column reorder controls when `columnReorder` is enabled. Reordering sends `column.reorder` over the same WebSocket-first/HTTP-fallback table mutation path used by other table updates.
