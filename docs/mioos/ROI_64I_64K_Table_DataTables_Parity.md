# ROI 64I–64K — Advanced Table DataTables Parity Track

This document designates the next ROI sequence after the current table stabilization pass. The goal is not to add jQuery DataTables as a dependency. The goal is to mirror selected server-side capabilities in native MIOOS/MUMPS form: editable cells, column reorder, and fixed columns.

## Design principles

- Backend remains authoritative.
- Browser remains Vue 3 Options API UMD only.
- No build step and no new frontend dependency.
- WebSocket is the default transport for fast acknowledgements.
- HTTP remains the fallback transport.
- Both transports call the same MUMPS backend routine.
- Every feature must include a full MUMPS-driven example under the Advanced Table API examples.

## ROI 64I — Editable Cells and Cell Callback Contract

Status: implemented in this pass. See `ROI_64I_Editable_Cells.md` for final contract details.

### Goal

Make individual cells editable in-place. Each editable cell should render the correct controller from schema metadata and show minimal Save/Cancel actions.

### Server contract

Schema metadata should support:

```mumps
SET @ROOT@("schema","columns",3,"key")="status"
SET @ROOT@("schema","columns",3,"label")="Status"
SET @ROOT@("schema","columns",3,"type")="select"
SET @ROOT@("schema","columns",3,"editable")=1
SET @ROOT@("schema","columns",3,"cellCallback")="STATUS^MYTABCB"
SET @ROOT@("validation","fields","status","enum",1)="Active"
SET @ROOT@("validation","fields","status","enum",2)="Pending"
```

Cell save request:

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

Acknowledgement:

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

If a column has `cellCallback`, `MIOOSTBL` should call that MUMPS entry point before direct persistence. If the callback returns a validation error, the browser keeps the cell editor open and displays the field/cell error.

### MUMPS example to add

```mumps
MYTABINIT ; Example editable-cell table
 NEW USER,ROOT
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
 SET @ROOT@("validation","fields","status","enum",1)="Active"
 SET @ROOT@("validation","fields","status","enum",2)="Pending"
 SET @ROOT@("rows",1,"id")="ed-1"
 SET @ROOT@("rows",1,"name")="Editable row"
 SET @ROOT@("rows",1,"status")="Pending"
 QUIT
```

```mumps
MYTABCB ; Cell callback examples
STATUS(STATE,DATASET,ROWID,COLUMN,VALUE,OUT,ERR)
 IF VALUE'="Active",VALUE'="Pending" SET ERR("error")="validation_failed",ERR("field")=COLUMN,ERR("message")="Unknown status" QUIT 0
 SET OUT("value")=VALUE
 QUIT 1
```

## ROI 64J — Column Reorder

Status: implemented in this pass. See `ROI_64J_Column_Reorder.md` for final contract details.

### Goal

Allow column order to be configured on boot and optionally changed by a user.

### Server contract

```mumps
SET @ROOT@("schema","columnOrder",1)="name"
SET @ROOT@("schema","columnOrder",2)="status"
SET @ROOT@("schema","columnOrder",3)="updated"
SET @ROOT@("features","columnReorder")=1
```

Mutation request:

```json
{
  "dataset": "demo",
  "action": "column.reorder",
  "columns": [{ "key": "name", "order": 1 }, { "key": "status", "order": 2 }, { "key": "updated", "order": 3 }],
  "mutationOnly": true
}
```

Backend acceptance criteria:

- Validate every key exists.
- Reject duplicates.
- Preserve unlisted columns at the end unless explicitly hidden/deleted.
- Store user-specific overrides separately from base schema when the table is user-customizable.

## ROI 64K — Fixed Columns

Status: implemented. See `docs/mioos/ROI_64K_Fixed_Columns.md` for the final mutation contract and MUMPS example.

### Goal

Allow fixed left/right columns at boot and optionally as a user preference.

### Server contract

```mumps
SET @ROOT@("features","fixedColumns")=1
SET @ROOT@("schema","fixedColumns","start")=1
SET @ROOT@("schema","fixedColumns","end")=1
```

or per-column:

```mumps
SET @ROOT@("schema","columns",1,"key")="id"
SET @ROOT@("schema","columns",1,"fixed")="start"
SET @ROOT@("schema","columns",9,"key")="status"
SET @ROOT@("schema","columns",9,"fixed")="end"
```

Frontend acceptance criteria:

- Sticky positioning must work with horizontal scrolling.
- Fixed cells must not overlap resizers, detail controls, or selection controls.
- Fixed-column state must be visible in the column designer.
- Fixed columns must remain keyboard navigable.

## Documentation updates required for each ROI

Each ROI must update:

- `docs/mioos/Backend_Table.md`
- `docs/mioos/UI_Modules.md`
- `examples/mioos_modules/table/README.md`
- `examples/mioos_modules/table/module.json` if the manifest behavior changes
- `mioos_llm.md`
- `routines/MIOOST.m`

## Required validation commands

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSAPI"
ZLINK "MIOOSWS"
ZLINK "MIOOST"
DO ^MIOOST
```

```bash
node --check public/mioos/app/mioos_table.js
python3 -m json.tool examples/mioos_modules/table/module.json
```
