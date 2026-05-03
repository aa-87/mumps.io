# ROI 64E — Table mutation correctness and MUMPS-first table API

ROI 64E is a corrective table ROI focused on five production blockers:

1. Table Samples must show how a dataset is defined in MUMPS, not only how a module points at a dataset.
2. Row details must be separate from row actions. Details now live in the ID/control column as an expand arrow.
3. Table mutations must return deterministic JSON over both HTTP and WebSocket paths instead of timing out or closing the connection.
4. The column selector must be modal-only so it does not push the table downward.
5. Column editing must remain a separate column-designer/editor view and only appear when `features("columnCrud")=1`.

## Contract

The table contract is now:

```text
mioos-advanced-table-v8
```

Query remains server-side and may use WebSocket for lower-latency reads. Mutation defaults to authenticated HTTP, and the WebSocket `table.mutate` command now returns a structured table error payload instead of allowing command-level failures to appear as socket timeouts.

## Mutation execution path

Browser row save:

```text
mioos_table.js
  backendTableSaveEditor()
  backendTableMutate(tableId,"row.save",{row:...})
  POST /api/mioos/table/mutate unless mutateTransport is explicitly websocket

MIOOSAPI.m
  TABLEMUTATE
  PARSEBODY
  LOAD^MIOOSST
  REQUIREAUTH
  MUTATE^MIOOSTBL

MIOOSTBL.m
  MUTATE
  VALIDATE
  VALROW / VALCOL / VALKEY
  mutate ^MIO("MIOOS","TABLE",user,dataset,...)
  QUERY returns a refreshed query-shaped payload
```

WebSocket row save follows the same `MUTATE^MIOOSTBL` path through `TABLEMUTATE^MIOOSWS`. On validation/runtime failure, both transports return:

```json
{
  "ok": false,
  "error": "table_mutate_failed",
  "detail": "invalid_row_field",
  "routine": "MIOOSTBL",
  "field": "bad field"
}
```

The UI keeps the editor open, clears the saving state, and displays the error.

## MUMPS dataset definition pattern

A MUMPS developer can define a dataset without writing frontend code:

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
```

Then register the module/window metadata:

```mumps
KILL MOD
SET MOD("componentKey")="table"
SET MOD("surface")="mioos-surface-table"
SET MOD("tableState","dataset")="orders"
SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
SET MOD("tableState","config","features","rowCrud")=1
SET MOD("tableState","config","features","columnCrud")=1
```

Routines to reload/test after table contract work:

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSAPI"
ZLINK "MIOOSWS"
ZLINK "MIOOSMOD"
ZLINK "MIOOST"
DO INIT^MIOOS(.CONF)
DO ^MIOOST
```

## UI behavior

- Simple and read-only tables omit the Actions column.
- If row details are enabled, the expand/collapse control appears in the control column beside the row selection checkbox, not in Actions.
- The Actions column contains row actions only, such as Edit, Duplicate, and Delete.
- The column selector is a modal dialog.
- Column add/edit/delete controls render only when `features("columnCrud")=1` and server features permit `crudColumns`.
