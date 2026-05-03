# ROI 64I — Editable Cells and Cell Callback Contract

ROI 64I finalizes in-place editable cells for the advanced backend table. It does not add DataTables or any frontend dependency. The feature mirrors the editable-cell behavior expected from a production data grid while keeping the MUMPS backend authoritative.

## Goals

- Render an inline editor inside the selected cell.
- Choose the editor control from server schema metadata: `text`, `textarea`, `select`, `multiselect`, `boolean`, `date`, or `number`.
- Show minimal Save and Cancel controls in the cell.
- Save through the existing mutation transport: WebSocket `table.mutate` first, HTTP `/api/mioos/table/mutate` fallback.
- Use the same backend mutation routine for both transports: `MUTATE^MIOOSTBL`.
- Validate through the existing table validation rules before persistence.
- Allow an optional MUMPS cell callback per column.

## Server schema contract

```mumps
SET @ROOT@("schema","columns",1,"key")="id"
SET @ROOT@("schema","columns",1,"label")="ID"
SET @ROOT@("schema","columns",1,"type")="text"
SET @ROOT@("schema","columns",1,"editable")=0

SET @ROOT@("schema","columns",2,"key")="status"
SET @ROOT@("schema","columns",2,"label")="Status"
SET @ROOT@("schema","columns",2,"type")="select"
SET @ROOT@("schema","columns",2,"editable")=1
SET @ROOT@("schema","columns",2,"cellCallback")="STATUS^MYTABCB"
SET @ROOT@("validation","fields","status","enum",1)="Active"
SET @ROOT@("validation","fields","status","enum",2)="Pending"
```

If `editable` is omitted, normal non-ID columns default to editable during dataset backfill. ID cells are read-only.

## Mutation request

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

## Success acknowledgement

```json
{
  "ok": true,
  "dataset": "demo",
  "action": "cell.save",
  "mutationOnly": true,
  "refetch": true,
  "message": "Cell saved"
}
```

## Validation failure

```json
{
  "ok": false,
  "dataset": "demo",
  "action": "cell.save",
  "error": "table_mutate_failed",
  "detail": "validation_failed",
  "message": "Value is not allowed",
  "fieldErrors": {
    "status": "Value is not allowed"
  },
  "mutationOnly": true,
  "refetch": false
}
```

The browser keeps the cell editor open and shows the field error inline.

## Optional MUMPS cell callback

A callback receives state, dataset, row id, column key, the value by reference, an output array, and an error array. Return `1` to accept the cell save and `0` to reject it.

```mumps
MYTABCB ; Example cell callbacks
STATUS(STATE,DATASET,ROWID,COLUMN,VALUE,OUT,ERR)
 IF VALUE'="Active",VALUE'="Pending" DO  QUIT 0
 . SET ERR("error")="validation_failed"
 . SET ERR("field")=COLUMN
 . SET ERR("message")="Unknown status"
 . SET ERR("fieldErrors",COLUMN)="Unknown status"
 SET OUT("value")=VALUE
 QUIT 1
```

The callback is invoked by `CELLCB^MIOOSTBL` after normal schema validation and before direct persistence. If `OUT("value")` is set, the backend persists that normalized value.

## Full MUMPS-driven example

```mumps
EDITINIT ; Seed editable-cell demo table
 NEW USER,ROOT,MOD
 SET USER=$GET(STATE("principal"),"admin")
 SET ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"editable-demo"))
 KILL @ROOT
 SET @ROOT@("schema","columns",1,"key")="id"
 SET @ROOT@("schema","columns",1,"label")="ID"
 SET @ROOT@("schema","columns",1,"type")="text"
 SET @ROOT@("schema","columns",1,"editable")=0
 SET @ROOT@("schema","columns",2,"key")="name"
 SET @ROOT@("schema","columns",2,"label")="Name"
 SET @ROOT@("schema","columns",2,"type")="text"
 SET @ROOT@("schema","columns",2,"editable")=1
 SET @ROOT@("schema","columns",3,"key")="status"
 SET @ROOT@("schema","columns",3,"label")="Status"
 SET @ROOT@("schema","columns",3,"type")="select"
 SET @ROOT@("schema","columns",3,"editable")=1
 SET @ROOT@("schema","columns",3,"cellCallback")="STATUS^MYTABCB"
 SET @ROOT@("validation","fields","name","required")=1
 SET @ROOT@("validation","fields","status","enum",1)="Active"
 SET @ROOT@("validation","fields","status","enum",2)="Pending"
 SET @ROOT@("rows",1,"id")="ed-1"
 SET @ROOT@("rows",1,"name")="Editable row"
 SET @ROOT@("rows",1,"status")="Pending"
 KILL MOD
 SET MOD("componentKey")="table"
 SET MOD("surface")="mioos-surface-table"
 SET MOD("tableState","dataset")="editable-demo"
 SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
 SET MOD("tableState","config","transport")="websocket"
 SET MOD("tableState","config","mutateTransport")="websocket"
 SET MOD("tableState","config","features","cellEditing")=1
 DO REGISTER^MIOOSMOD(.MOD)
 QUIT
```

Reload and test after installing routines:

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSAPI"
ZLINK "MIOOSWS"
ZLINK "MIOOST"
DO ^MIOOST
```

## Files touched

- `routines/MIOOSTBL.m`
- `public/mioos/app/mioos_table.js`
- `public/mioos/mioos.css`
- `docs/mioos/Backend_Table.md`
- `docs/mioos/UI_Modules.md`
- `examples/mioos_modules/table/README.md`
- `examples/mioos_modules/table/module.json`
- `mioos_llm.md`
- `routines/MIOOST.m`
