# Table UI Module Example

This example demonstrates the built-in MIOOS backend table module for MUMPS developers. The table remains server-authored: MUMPS owns the schema, rows, module metadata, mutation validation, and desktop/app entry point. Browser code only renders the `mioos-surface-table` surface.

## Contract

- Table contract: `mioos-advanced-table-v8`
- Query route: `POST /api/mioos/table/query`
- Mutation route: `POST /api/mioos/table/mutate`
- WebSocket commands: `table.query` and `table.mutate`
- Backend routine: `MIOOSTBL`
- Module registry routine: `MIOOSMOD`

ROI 64F changes mutations to fast acknowledgements. A mutation validates and writes, then returns a small JSON acknowledgement with `mutationOnly: true` and `refetch: true`; the browser performs a separate query after the acknowledgement. The mutation response no longer includes a full refreshed table payload.

## Files

- `module.json` — user-module manifest targeting `mioos-advanced-table-v8`.
- `table_module.mjs` — optional browser-side registration shim for custom bundles.

## Complete MUMPS-first dataset and render contract

## Dataset definition in MUMPS

Use the current table global contract under `^MIO("MIOOS","TABLE",user,dataset,...)`.

```mumps
NEW USER,ROOT
SET USER=$GET(STATE("principal"),"admin")
SET ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"example"))
KILL @ROOT

SET @ROOT@("schema","columns",1,"key")="id"
SET @ROOT@("schema","columns",1,"label")="ID"
SET @ROOT@("schema","columns",1,"type")="text"
SET @ROOT@("schema","columns",1,"width")=120
SET @ROOT@("schema","columns",1,"sortable")=1
SET @ROOT@("schema","columns",1,"resizable")=1

SET @ROOT@("schema","columns",2,"key")="name"
SET @ROOT@("schema","columns",2,"label")="Name"
SET @ROOT@("schema","columns",2,"type")="text"
SET @ROOT@("schema","columns",2,"width")=220
SET @ROOT@("schema","columns",2,"sortable")=1
SET @ROOT@("schema","columns",2,"resizable")=1

SET @ROOT@("schema","columns",3,"key")="status"
SET @ROOT@("schema","columns",3,"label")="Status"
SET @ROOT@("schema","columns",3,"type")="badge"
SET @ROOT@("schema","columns",3,"width")=120
SET @ROOT@("schema","columns",3,"sortable")=1
SET @ROOT@("schema","columns",3,"resizable")=1

SET @ROOT@("schema","columns",4,"key")="priority"
SET @ROOT@("schema","columns",4,"label")="Priority"
SET @ROOT@("schema","columns",4,"type")="text"
SET @ROOT@("schema","columns",4,"width")=110
SET @ROOT@("schema","columns",4,"sortable")=1
SET @ROOT@("schema","columns",4,"resizable")=1

SET @ROOT@("rows",1,"id")="example-1"
SET @ROOT@("rows",1,"name")="Demo row"
SET @ROOT@("rows",1,"status")="Active"
SET @ROOT@("rows",1,"priority")="High"
SET @ROOT@("rows",1,"_expand","title")="Details"
SET @ROOT@("rows",1,"_expand","body")="Optional row detail text."
```

## Module registration

Register a table-backed module from MUMPS metadata. The current registry API loads internal modules from `MIOOSMOD` and user modules from the module globals it reads. For a MUMPS routine, build the `MOD` array in the same shape:

```mumps
NEW MOD
KILL MOD
SET MOD("id")="user.example.table"
SET MOD("key")="example-table"
SET MOD("appKey")="example-table"
SET MOD("title")="Example Table"
SET MOD("description")="Example table created from MUMPS"
SET MOD("category")="Operations"
SET MOD("icon")="▤"
SET MOD("source")="user"
SET MOD("componentKey")="table"
SET MOD("surface")="mioos-surface-table"
SET MOD("tableState","dataset")="example"
SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
SET MOD("tableState","config","transport")="websocket"
SET MOD("tableState","config","mutateTransport")="http"
SET MOD("tableState","config","tableMutationTimeoutMs")=4500
SET MOD("tableState","config","includeDataAlias")=0
SET MOD("tableState","config","defaultPageSize")=50
SET MOD("tableState","config","groupByColumns",1)="status"
SET MOD("tableState","config","groupByColumns",2)="priority"
```

`groupByColumns` is the ROI 64F multi-column grouping contract. The browser sends the same array in table queries, and `MIOOSTBL` returns compound groups in stable order.

## Desktop icon / app entry point

Use the module metadata above to make the table appear in the App Catalogue. The App Catalogue and start menu launch by `appKey` / `surface`; no frontend code is required.

To add a desktop-facing table entry in MUMPS, create the module metadata and then expose an app entry with the same key, title, icon, component, surface, and table dataset. Internal examples are registered in `INTERNAL^MIOOSMOD` with `ADDTABLE^MIOOSMOD`; user-created entries should mirror that shape:

```mumps
; App Catalogue / desktop launcher identity
SET MOD("key")="example-table"
SET MOD("appKey")="example-table"
SET MOD("title")="Example Table"
SET MOD("icon")="▤"
SET MOD("componentKey")="table"
SET MOD("surface")="mioos-surface-table"
SET MOD("tableState","dataset")="example"

; Opening from the shell uses the app entry point. The frontend window manager
; creates a mioos-surface-table window from MOD("surface") and MOD("tableState").
```

What to edit:

- Dataset and rows: your setup routine that writes `^MIO("MIOOS","TABLE",user,dataset,...)`.
- Internal built-in catalogue entries: `INTERNAL^MIOOSMOD`.
- User-created catalogue entries: the user module registry globals consumed by `USER^MIOOSMOD`.
- Table behavior: `MIOOSTBL`.

How to open it:

1. Sign in to MIOOS.
2. Open **App Catalogue** or **Table Samples**.
3. Launch the module whose `appKey` is `example-table`.
4. The shell opens `mioos-surface-table` and queries dataset `example`.

## Query example

```json
{
  "dataset": "example",
  "page": 1,
  "pageSize": 50,
  "draw": 4,
  "start": 0,
  "length": 50,
  "serverSide": true,
  "processing": true,
  "search": "alpha",
  "filters": { "status": ["Active"] },
  "sort": { "column": "name", "direction": "ascending" },
  "groupBy": "status",
  "groupByColumns": ["status", "priority"],
  "includeDataAlias": false
}
```

By default, responses include `rows` only. Legacy `data` is returned only when `includeDataAlias: true` is requested.

## Mutation acknowledgement

```json
{
  "dataset": "example",
  "action": "column.visibility",
  "columnKey": "priority",
  "hidden": false,
  "mutationOnly": true
}
```

Successful acknowledgement:

```json
{
  "ok": true,
  "dataset": "example",
  "action": "column.visibility",
  "mutationOnly": true,
  "refetch": true,
  "message": "Column visibility updated"
}
```

Validation/error acknowledgement:

```json
{
  "ok": false,
  "dataset": "example",
  "action": "row.save",
  "error": "validation_failed",
  "message": "Name is required",
  "fieldErrors": { "name": "Required" },
  "mutationOnly": true,
  "refetch": false
}
```

## Required routine reload/run commands

After changing table, API, WebSocket, module, or tests routines:

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSAPI"
ZLINK "MIOOSWS"
ZLINK "MIOOSMOD"
ZLINK "MIOOST"
DO INIT^MIOOS(.CONF)
DO ^MIOOST
```

If you modify the browser files, also run:

```text
node --check public/mioos/app/mioos_table.js
node --check public/mioos/app/mioos_ws.js
python3 -m json.tool examples/mioos_modules/table/module.json
```
