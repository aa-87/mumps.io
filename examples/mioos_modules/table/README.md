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

The table example now targets `mioos-advanced-table-v7`. Use MUMPS module/tableState nodes first. `window.MIOOSTable.createConfig()` exists for internal shell code, but the examples are intentionally written as MUMPS contracts for developers with no frontend experience.

## DataTables-style server-side integration

The example now targets `mioos-advanced-table-v7`. The native MIOOS table request includes `draw`, `start`, `length`, `order`, and `columns` fields so developers familiar with DataTables can reason about server-side paging and ordering without adopting jQuery/DataTables as a dependency.

Do not load DataTables in MIOOS modules. Use the built-in `mioos-full-table` / `mioos-surface-table` component and configure it with safe JSON or `window.MIOOSTable.createConfig()`.

## ROI 64C redo 2 table variations

The example manifest now targets `mioos-advanced-table-v7`. Queries may use WebSocket; mutations default to HTTP-safe JSON to avoid socket timeout on saves.

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
SET MOD("tableState","config","contract")="mioos-advanced-table-v7"
SET MOD("tableState","config","transport")="websocket"
SET MOD("tableState","config","mutateTransport")="http"
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
SET MOD("tableState","config","contract")="mioos-advanced-table-v7"
SET MOD("tableState","config","features","rowCrud")=1
SET MOD("tableState","config","features","columnCrud")=1
```

Mutation path is validated by `VALIDATE^MIOOSTBL` before row/column updates. Both HTTP and WebSocket mutation paths return deterministic JSON errors instead of timing out.

## ROI 64G stabilization notes

The demo/sample table now treats Notes as a normal editable column:

```mumps
SET @ROOT@("schema","columns",4,"key")="notes"
SET @ROOT@("schema","columns",4,"label")="Notes"
SET @ROOT@("schema","columns",4,"group")="Notes"
SET @ROOT@("rows",1,"notes")="Editable notes column"
```

Column visibility requests should send JSON booleans, and the backend normalizes them before storing `hidden=1` or `hidden=0`:

```json
{ "dataset": "demo", "action": "column.visibility", "columnKey": "notes", "hidden": true, "mutationOnly": true }
```

The UI exposes grouping and filters in modals so MUMPS-authored tables remain usable without frontend code.

## ROI 64G stabilization follow-up

The demo dataset should include an editable `notes` column rather than keeping notes only in `_expand("body")`:

```mumps
SET @ROOT@("schema","columns",6,"key")="notes"
SET @ROOT@("schema","columns",6,"label")="Notes"
SET @ROOT@("schema","columns",6,"type")="text"
SET @ROOT@("schema","columns",6,"group")="Notes"
SET @ROOT@("rows",1,"notes")="Editable notes column"
```

Column visibility mutations may be sent with JSON booleans:

```json
{
  "dataset": "demo",
  "action": "column.visibility",
  "columnKey": "notes",
  "hidden": true
}
```

Validation rules are backend data, not frontend code:

```mumps
SET @ROOT@("validation","fields","name","required")=1
SET @ROOT@("validation","fields","name","message")="Name is required"
```

## Stabilization notes before ROI 64H

### Date validation

To make a date column validate correctly, set the column type and validation flag in MUMPS:

```mumps
SET @ROOT@("schema","columns",5,"key")="updated"
SET @ROOT@("schema","columns",5,"label")="Updated"
SET @ROOT@("schema","columns",5,"type")="date"
SET @ROOT@("validation","fields","updated","date")=1
```

Invalid values such as `2026-02-31` should fail before row persistence and should be returned as `fieldErrors("updated")`.

### Select and typed controls

Enum validation metadata drives select controls in the table editor:

```mumps
SET @ROOT@("validation","fields","status","enum",1)="Open"
SET @ROOT@("validation","fields","status","enum",2)="Done"
SET @ROOT@("validation","fields","status","enum",3)="Review"
```

Use schema `type="textarea"` for long notes, `type="boolean"` for checkboxes, `type="number"` for numeric input, and `type="multiselect"` when a column should accept multiple option values.

### Selected-row CSV export

The table bulk export command sends selected IDs to the server:

```json
{
  "dataset": "demo",
  "action": "rows.export",
  "ids": ["demo-1", "demo-2"]
}
```

`EXPORT^MIOOSTBL` builds the CSV on the server and returns the CSV payload to the browser for download.

### Column key edits

Do not change an existing column key to rename a column. Column keys are persistent identity values. The editor locks the key for existing columns and sends `originalKey` so the backend updates the existing schema entry instead of creating a new column.

## ROI 64H server-side table module library

A MUMPS developer can now register a complete table-backed module through `HANDLE^MIOOSMTBL` instead of hand-editing frontend files. The service validates the definition, writes the table dataset, installs a launchable module entry, and keeps revision snapshots before overwrite.

```mumps
NEW STATE,CONF,IN,OUT,ERR
SET STATE("principal")="developer"
SET IN("action")="save"
SET IN("definition","key")="example_table"
SET IN("definition","title")="Example Table"
SET IN("definition","dataset")="example_table"
SET IN("definition","category")="Operations"
SET IN("definition","icon")="▤"
SET IN("definition","schema","columns",1,"key")="name"
SET IN("definition","schema","columns",1,"label")="Name"
SET IN("definition","schema","columns",1,"type")="text"
SET IN("definition","schema","columns",2,"key")="status"
SET IN("definition","schema","columns",2,"label")="Status"
SET IN("definition","schema","columns",2,"type")="select"
SET IN("definition","validation","fields","name","required")=1
SET IN("definition","validation","fields","status","enum",1)="Active"
SET IN("definition","validation","fields","status","enum",2)="Pending"
SET IN("definition","rows",1,"id")="example-1"
SET IN("definition","rows",1,"name")="Demo row"
SET IN("definition","rows",1,"status")="Active"
DO HANDLE^MIOOSMTBL(.STATE,.CONF,.IN,.OUT,.ERR)
```

Reload after applying this ROI:

```mumps
ZLINK "MIOOSMTBL"
ZLINK "MIOOSMOD"
ZLINK "MIOOSAPI"
ZLINK "MIOOSWS"
ZLINK "MIOOS"
ZLINK "MIOOSST"
ZLINK "MIOOST"
DO ^MIOOST
```
