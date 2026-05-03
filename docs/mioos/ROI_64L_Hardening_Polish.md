# ROI 64L — Advanced Table Hardening and Polish

ROI 64L is a stabilization pass for the Advanced Table work delivered across ROI 64F through ROI 64K. It does not introduce a new table surface; it tightens composition, runtime safety, and developer documentation for the existing MUMPS-authored table module.

## Goals

- Make all table dialogs predictable and closable.
- Keep loading and saving indicators non-shifting.
- Ensure stale query/mutation responses cannot corrupt the current table state.
- Confirm fixed columns, column reorder, editable cells, grouping, filtering, visibility, selected-row export, and validation compose safely.
- Remove native browser prompts/confirms from table workflows.
- Keep massive/read-only datasets free of mutation controls.

## Runtime hardening

### Fixed-column runtime completion

The table backend returns fixed-column metadata under both locations for compatibility:

```json
{
  "schema": {
    "fixedColumns": { "start": 1, "end": 0 }
  },
  "fixedColumns": { "start": 1, "end": 0 },
  "features": { "fixedColumns": 1 }
}
```

The browser normalizes these counts, clamps them to the visible column count, and applies sticky start/end styles to header, body, control, and actions cells.

### Server mutation path

Fixed-column changes use the same mutation contract as the rest of the table:

```json
{
  "dataset": "demo",
  "action": "column.fixed",
  "fixedColumns": { "start": 1, "end": 0 },
  "mutationOnly": true
}
```

The backend validates and persists this under:

```mumps
SET @ROOT@("schema","fixedColumns","start")=1
SET @ROOT@("schema","fixedColumns","end")=0
```

### Dialog and loading polish

Table dialogs remain MIOOS-owned modal windows with draggable title bars. Close buttons stop pointer events before drag begins. The table uses a thin loading bar only; no text is inserted into normal flow during loading or saving.

## MUMPS-driven example

```mumps
NEW USER,ROOT,MOD
SET USER=$GET(STATE("principal"),"admin")
SET ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"ops-table"))
KILL @ROOT
SET @ROOT@("schema","columns",1,"key")="id"
SET @ROOT@("schema","columns",1,"label")="ID"
SET @ROOT@("schema","columns",1,"type")="text"
SET @ROOT@("schema","columns",1,"width")=96
SET @ROOT@("schema","columns",1,"editable")=0
SET @ROOT@("schema","columns",2,"key")="name"
SET @ROOT@("schema","columns",2,"label")="Name"
SET @ROOT@("schema","columns",2,"type")="text"
SET @ROOT@("schema","columns",2,"width")=220
SET @ROOT@("schema","columns",3,"key")="status"
SET @ROOT@("schema","columns",3,"label")="Status"
SET @ROOT@("schema","columns",3,"type")="select"
SET @ROOT@("schema","columns",3,"width")=120
SET @ROOT@("schema","fixedColumns","start")=1
SET @ROOT@("schema","fixedColumns","end")=0
SET @ROOT@("validation","fields","status","enum",1)="Open"
SET @ROOT@("validation","fields","status","enum",2)="Done"
SET @ROOT@("rows",1,"id")="OPS-1"
SET @ROOT@("rows",1,"name")="First row"
SET @ROOT@("rows",1,"status")="Open"

KILL MOD
SET MOD("key")="ops-table"
SET MOD("title")="Operations Table"
SET MOD("category")="Operations"
SET MOD("icon")="▤"
SET MOD("componentKey")="table"
SET MOD("surface")="mioos-surface-table"
SET MOD("tableState","dataset")="ops-table"
SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
SET MOD("tableState","config","features","columnReorder")=1
SET MOD("tableState","config","features","fixedColumns")=1
SET MOD("tableState","config","fixedColumns","start")=1
SET MOD("tableState","config","fixedColumns","end")=0
DO REGISTER^MIOOSMOD(.STATE,.MOD,.OUT,.ERR)
```

## Validation checklist

Run after loading the changed routines:

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSMOD"
ZLINK "MIOOSMTBL"
ZLINK "MIOOST"
DO ^MIOOST
```

### Regression fix: table payload application scope

A post-ROI 68 regression showed `vm is not defined` above the Advanced Table and prevented successful editable-cell saves from completing the refetch path. The cause was a stale implementation detail in `backendTableApplyPayload`: it referenced `vm.backendTableNormalizeFixedColumns(...)` even though that method has no local `vm` variable. The method now calls `this.backendTableNormalizeFixedColumns(...)`, keeping fixed-column normalization bound to the Vue root/method context.

Regression checks should verify that applying a table payload after a cell-save refetch does not throw, and that `cell.save` keeps using the shared WebSocket-first / HTTP-fallback mutation path.
