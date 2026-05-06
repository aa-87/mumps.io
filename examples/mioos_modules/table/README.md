# Table UI Module Example

This example demonstrates the first reusable MIOOS UI module component: the backend table.

## Files

- `module.json` — user-module manifest.
- `table_module.mjs` — optional browser-side registration shim for custom bundles.

## How it works

The manifest launches a window with:

```text
componentKey = table
surface      = mioos-surface-table
backend      = MIOOSTBL
route        = /api/mioos/table/query
```

The shell resolves the surface and renders `mioos-full-table`. Data remains backend-owned.

## Next steps for a real module

1. Copy `module.json`.
2. Change `id`, `key`, `appKey`, `title`, and `description`.
3. Point `config.dataset` at a backend dataset supported by your query routine.
4. Register the manifest in the user module global or add it as an internal module in `MIOOSMOD`.

## Relationship to ROI 64B UI examples

The `UI + Form Elements` example is no longer implemented as a table dataset. Table modules should still use `mioos-surface-table`, but UI/form examples now use `mioos-surface-ui-elements` so form reference behavior remains stable while the advanced table component is rewritten in ROI 64C.


## ROI 64C standalone configuration

The table example now targets `mioos-advanced-table-v8`. Use MUMPS module/tableState nodes first. `window.MIOOSTable.createConfig()` exists for internal shell code, but the examples are intentionally written as MUMPS contracts for developers with no frontend experience.

## DataTables-style server-side integration

The example now targets `mioos-advanced-table-v8`. The native MIOOS table request includes `draw`, `start`, `length`, `order`, and `columns` fields so developers familiar with DataTables can reason about server-side paging and ordering without adopting jQuery/DataTables as a dependency.

Do not load DataTables in MIOOS modules. Use the built-in `mioos-full-table` / `mioos-surface-table` component and configure it with safe JSON or `window.MIOOSTable.createConfig()`.

## ROI 64C redo 2 table variations

The example manifest now targets `mioos-advanced-table-v8`. Queries may use WebSocket; mutations default to WebSocket acknowledgement JSON with HTTP fallback to avoid socket timeout on saves.

Open the built-in **Table Samples** module to view copyable MUMPS contract variations:

- Simple read-mostly table
- Dense operational table
- Editable CRUD table
- Patient registration table
- Massive read-only table

Minimal MUMPS user-created module configuration:

```mumps
SET MOD("componentKey")="table"
SET MOD("surface")="mioos-surface-table"
SET MOD("tableState","dataset")="demo"
SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
SET MOD("tableState","config","transport")="websocket"
SET MOD("tableState","config","mutateTransport")="websocket"
SET MOD("tableState","config","density")="compact"
SET MOD("tableState","config","defaultPageSize")=25
```


## ROI 64D MUMPS-only examples

The visible Table Samples cards now show MUMPS snippets rather than JavaScript snippets. A simple read-only table should explicitly disable mutation and selection features so the rendered table has no Actions column:

```mumps
SET MOD("tableState","config","features","rowCrud")=0
SET MOD("tableState","config","features","columnCrud")=0
SET MOD("tableState","config","features","selection")=0
SET MOD("tableState","config","features","bulkActions")=0
SET MOD("tableState","config","features","rowDetails")=0
```

Editable tables enable the same feature nodes and rely on `MIOOSTBL` mutation actions such as `row.save`, `row.delete`, `rows.delete`, `column.save`, `column.resize`, and `column.visibility`.

## Complete MUMPS-first dataset and render contract

The Table Samples surface now includes complete copyable MUMPS examples. Each example shows three things:

1. How to define the dataset schema and rows under `^MIO("MIOOS","TABLE",user,dataset,...)`.
2. How to register the module/window with `MOD("componentKey")="table"` and `MOD("tableState",...)`.
3. Which routines to reload and test:

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSAPI"
ZLINK "MIOOSWS"
ZLINK "MIOOSMOD"
ZLINK "MIOOST"
DO INIT^MIOOS(.CONF)
DO ^MIOOST
```

Example dataset seed:

```mumps
NEW USER,ROOT,MOD
SET USER=$GET(STATE("principal"),"admin")
SET ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"orders"))
KILL @ROOT
SET @ROOT@("schema","columns",1,"key")="id"
SET @ROOT@("schema","columns",1,"label")="ID"
SET @ROOT@("schema","columns",1,"type")="text"
SET @ROOT@("schema","columns",1,"width")=120
SET @ROOT@("schema","columns",2,"key")="name"
SET @ROOT@("schema","columns",2,"label")="Name"
SET @ROOT@("schema","columns",2,"type")="text"
SET @ROOT@("schema","columns",2,"width")=220
SET @ROOT@("rows",1,"id")="orders-1"
SET @ROOT@("rows",1,"name")="First order"
KILL MOD
SET MOD("componentKey")="table"
SET MOD("surface")="mioos-surface-table"
SET MOD("tableState","dataset")="orders"
SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
SET MOD("tableState","config","features","rowCrud")=1
SET MOD("tableState","config","features","columnCrud")=1
```

Mutation path is validated by `VALIDATE^MIOOSTBL` before row/column updates. Both HTTP and WebSocket mutation paths return deterministic JSON errors instead of timing out.

## Typed filters, option values, and CSV export

Use schema type metadata to control the browser editor and filter input. For select-like fields, store allowed values in the validation enum table:

```mumps
SET @ROOT@("schema","columns",3,"key")="status"
SET @ROOT@("schema","columns",3,"label")="Status"
SET @ROOT@("schema","columns",3,"type")="select"
SET @ROOT@("validation","fields","status","enum",1)="Active"
SET @ROOT@("validation","fields","status","enum",2)="Pending"
```

The table UI can add a value to this dictionary by sending `column.option.add`. The backend updates the dataset-specific table global; no frontend code is required.

Selected-row CSV export is server-side:

```json
{
  "dataset": "demo",
  "action": "rows.export",
  "ids": ["demo-1", "demo-2"],
  "mutationOnly": true
}
```

Editable-cell examples are now implemented in `docs/mioos/ROI_64I_Editable_Cells.md`. Column reorder and fixed columns remain planned in `docs/mioos/ROI_64I_64K_Table_DataTables_Parity.md`.


## Editable cells with MUMPS callbacks

To make a cell editable, define the column type and editable flag in MUMPS. Select-like controls should also define their allowed values under `validation("fields",key,"enum")`.

```mumps
SET @ROOT@("schema","columns",3,"key")="status"
SET @ROOT@("schema","columns",3,"label")="Status"
SET @ROOT@("schema","columns",3,"type")="select"
SET @ROOT@("schema","columns",3,"editable")=1
SET @ROOT@("schema","columns",3,"cellCallback")="STATUS^MYTABCB"
SET @ROOT@("validation","fields","status","enum",1)="Active"
SET @ROOT@("validation","fields","status","enum",2)="Pending"
SET MOD("tableState","config","features","cellEditing")=1
```

The browser sends a single-cell mutation; both WebSocket and HTTP fallback enter `MUTATE^MIOOSTBL`:

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

Example callback:

```mumps
MYTABCB ; cell callback
STATUS(STATE,DATASET,ROWID,COLUMN,VALUE,OUT,ERR)
 IF VALUE'="Active",VALUE'="Pending" DO  QUIT 0
 . SET ERR("error")="validation_failed"
 . SET ERR("field")=COLUMN
 . SET ERR("message")="Unknown status"
 . SET ERR("fieldErrors",COLUMN)="Unknown status"
 SET OUT("value")=VALUE
 QUIT 1
```

## Column reorder example

To let users reorder columns without frontend code, enable the feature in the table module metadata:

```mumps
SET MOD("tableState","config","features","columnReorder")=1
```

The persisted order is the order of `schema("columns",n)` under the dataset root. The Columns modal sends `column.reorder`; `MIOOSTBL` validates that every column key is present exactly once before rewriting the schema order.

Reload and validate:

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSMOD"
ZLINK "MIOOSMTBL"
ZLINK "MIOOST"
DO ^MIOOST
```

## ROI 64L hardening example additions

To enable the final polished Advanced Table behavior from MUMPS, add fixed-column defaults and keep the rest of the table contract server-owned:

```mumps
SET @ROOT@("schema","fixedColumns","start")=1
SET @ROOT@("schema","fixedColumns","end")=0
SET MOD("tableState","config","features","columnReorder")=1
SET MOD("tableState","config","features","fixedColumns")=1
SET MOD("tableState","config","fixedColumns","start")=1
SET MOD("tableState","config","fixedColumns","end")=0
```

Reload and validate:

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSMOD"
ZLINK "MIOOSMTBL"
ZLINK "MIOOST"
DO ^MIOOST
```

## ROI 68A Sample matrix

The table examples are now organized as a MUMPS-first sample matrix. Use these files as copy/paste starting points; they intentionally avoid frontend framework code.

| Sample | File | What it demonstrates |
| --- | --- | --- |
| Basic read-only table | `samples/basic_readonly.m` | Read-only table with no Actions column, no selection, and no CRUD controls. |
| Editable cells | `samples/editable_cells.m` | `cell.save`, typed inline controls, and a MUMPS `cellCallback`. |
| Validation rules | `samples/validation_rules.m` | Required, max length, enum/select, multiselect, boolean, date, number, numeric range, row hook, and cell callback validation. |
| Advanced filters | `samples/advanced_filters.m` | Include, exclude, contains, starts, ends, range, blank, and not blank filters. |
| Grouping/reorder/fixed columns | `samples/grouping_reorder_fixed.m` | Multi-column grouping, column visibility, column reorder, and fixed-column metadata. |
| Server CSV export | `samples/server_csv_export.m` | `rows.export` with selected row IDs only and server-generated CSV. |
| Module registration | `samples/table_module_registration.m` | Desktop/App Catalogue entry point using `MOD(...)` and `tableState` without frontend code. |

Every sample answers the same operational questions:

- **What routine do I edit?** Copy the sample routine or move its `SET` blocks into your module seed routine.
- **What globals do I set?** Seed `^MIO("MIOOS","TABLE",USER,dataset,...)` for schema, rows, validation rules, fixed columns, and callbacks.
- **What command do I run?** `ZLINK` the sample and table routines, seed the data, then run `DO ^MIOOST`.
- **How do I make an icon appear?** Register a module record with `key`, `appKey`, `title`, `icon`, `componentKey="table"`, `surface="mioos-surface-table"`, and `tableState.dataset`.
- **How do I open this table from the shell?** Sign in as the same `USER`, open App Catalogue/Start Menu, and launch the registered module.
- **How do I validate that it works?** Confirm the table opens, then run the backend regression suite in YottaDB / GT.M.

Recommended validation commands:

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSTBLC"
ZLINK "MIOOSAPI"
ZLINK "MIOOSWS"
ZLINK "MIOOSMOD"
ZLINK "MIOOSMTBL"
ZLINK "MIOOSPAT"
ZLINK "MIOOST"
DO ^MIOOST
```

Browser/example checks from the repository root:

```bash
node --check public/mioos/app/mioos_table.js
python3 -m json.tool examples/mioos_modules/table/module.json
```

## ROI 68A backend contract notes

The current contract is `mioos-advanced-table-v8`. `QUERY^MIOOSTBL` returns the contract version in `OUT("contract")`. Query requests are WebSocket-first with HTTP fallback. Mutations use `table.mutate` / `/api/mioos/table/mutate`; both call `MUTATE^MIOOSTBL` and both return deterministic field errors instead of timing out.

Small successful mutation acknowledgement shape:

```json
{
  "ok": 1,
  "dataset": "demo",
  "action": "cell.save",
  "mutationOnly": 1,
  "refetch": 1,
  "message": "Cell saved",
  "mutated": { "rowId": "demo-1", "columnKey": "status" }
}
```

Failed mutation shape after HTTP/WebSocket normalization:

```json
{
  "ok": 0,
  "dataset": "demo",
  "action": "row.save",
  "error": "table_mutate_failed",
  "message": "Please fix the highlighted fields",
  "fieldErrors": { "name": "Name is required" },
  "mutationOnly": 1,
  "refetch": 0
}
```

## Final regression stabilization

For table-backed modules, keep the manifest/server definition MUMPS-first and set `componentKey="table"`, `surface="mioos-surface-table"`, and `tableState.config.contract="mioos-advanced-table-v8"`. Mutations are shared by HTTP and WebSocket paths through `MUTATE^MIOOSTBL`, and the shell now requires visible success/failure feedback instead of silent failures.

## Login/theme/start-menu/text-viewer regression ROI note

This table example remains MUMPS-first and does not require frontend framework changes. When testing it from the shell, remember that unauthenticated boot hides all desktop/module surfaces until sign-in succeeds. Theme Studio changes should be made through explicit Save/Save As semantics, and dark custom titlebar CSS should be verified in both light and dark shells without changing the table module contract.

## New Table Module example notes (ROI 91)

The same table surface used by this example is now available through **New Table Module** in the UI Modules catalogue. Backend-generated modules do not require new frontend code: `MIOOSMTBL` installs a user module with `componentKey=table`, `surface=mioos-surface-table`, and `tableState.config.contract=mioos-advanced-table-v8`.

For MUMPS-first examples, keep the table module contract explicit in module JSON or generated definitions and let `MIOOSTBL` own query/mutate behavior.
