# ROI 64K — Fixed Columns

## Goal

Add DataTables-style fixed start/end columns to the MIOOS Advanced Table without adding a frontend dependency. The feature remains server-authored and MUMPS-first: the backend declares how many visible columns should stay fixed at the left or right edge, and the browser renders those cells as sticky while the center columns scroll horizontally.

## MUMPS contract

Enable the feature and set default fixed counts on the dataset root:

```mumps
NEW USER,ROOT
SET USER=$GET(STATE("principal"),"admin")
SET ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"demo"))
SET @ROOT@("features","fixedColumns")=1
SET @ROOT@("schema","fixedColumns","start")=1
SET @ROOT@("schema","fixedColumns","end")=0
```

A table-backed module can also include boot-time config defaults:

```mumps
SET MOD("tableState","config","features","fixedColumns")=1
SET MOD("tableState","config","fixedColumns","start")=1
SET MOD("tableState","config","fixedColumns","end")=1
```

The query response includes the fixed-column contract:

```json
{
  "schema": {
    "fixedColumns": { "start": 1, "end": 0 }
  },
  "features": {
    "fixedColumns": 1,
    "fixedStart": 1,
    "fixedEnd": 0
  }
}
```

## User preference mutation

The Columns modal exposes fixed start/end controls. Saving sends the normal WebSocket-first / HTTP-fallback table mutation:

```json
{
  "dataset": "demo",
  "action": "column.fixed",
  "fixedColumns": {
    "start": 1,
    "end": 1
  },
  "mutationOnly": true
}
```

`MUTATE^MIOOSTBL` validates the counts with `VALFIXED`, clamps them to the schema column count, persists them under `schema("fixedColumns")`, and returns a small acknowledgement:

```json
{
  "ok": true,
  "dataset": "demo",
  "action": "column.fixed",
  "mutationOnly": true,
  "refetch": true,
  "message": "Fixed columns saved"
}
```

## Rendering rules

- Fixed start columns use sticky `left` offsets.
- Fixed end columns use sticky `right` offsets.
- If the table has a selection/detail control column and `start > 0`, the control column is also fixed to prevent overlap.
- If the table has an Actions column and `end > 0`, the Actions column is also fixed to prevent overlap.
- Fixed counts are applied after column visibility and column reorder.
- Massive/read-only datasets disable fixed columns by returning `features.fixedColumns=0`.

## Validation commands

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOST"
DO ^MIOOST
```

Browser syntax checks:

```bash
node --check public/mioos/app/mioos_table.js
python3 -m json.tool examples/mioos_modules/table/module.json
```
