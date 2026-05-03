# ROI 64J — Column Reorder

## Status

Implemented in this ROI pass after fixing the modal close and native browser prompt/confirm regressions.

## Goal

Allow MUMPS-authored advanced tables to define a boot column order and allow users to reorder columns from the table UI without introducing a frontend dependency or client-side-only state.

## Contract

The table contract remains `mioos-advanced-table-v8` and adds the `columnReorder` feature flag.

```mumps
SET @ROOT@("features","columnReorder")=1
SET @ROOT@("schema","columns",1,"key")="name"
SET @ROOT@("schema","columns",1,"order")=1
SET @ROOT@("schema","columns",2,"key")="status"
SET @ROOT@("schema","columns",2,"order")=2
SET @ROOT@("schema","columns",3,"key")="updated"
SET @ROOT@("schema","columns",3,"order")=3
```

The active column order is the order of `schema("columns",n)` returned by `QUERY^MIOOSTBL`. The user-facing reorder operation persists that order back to the dataset schema.

## Mutation request

```json
{
  "dataset": "demo",
  "action": "column.reorder",
  "columns": [
    { "key": "name", "order": 1 },
    { "key": "status", "order": 2 },
    { "key": "updated", "order": 3 }
  ],
  "mutationOnly": true
}
```

## Mutation acknowledgement

```json
{
  "ok": true,
  "dataset": "demo",
  "action": "column.reorder",
  "mutationOnly": true,
  "refetch": true,
  "message": "Column order saved"
}
```

## UI behavior

- Column reorder controls live in the existing Columns modal.
- The controls use table-owned MIOOS modal/window styling, not native browser controls.
- Moving a column immediately sends `column.reorder` through the same mutation pipeline as other table mutations.
- WebSocket remains the default mutation transport and HTTP remains fallback.
- Unlisted columns are preserved at the end by the backend.

## Related stabilization fixes

This pass also fixes two regressions from the prior ROI:

1. Close buttons now stop pointer events before they reach the draggable title bar, so clicking `×` dismisses the table modal instead of starting a drag.
2. Add Value and Delete Column now use MIOOS table dialogs instead of `prompt()` and `confirm()`.

## Validation

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOST"
DO ^MIOOST
```

```bash
node --check public/mioos/app/mioos_table.js
python3 -m json.tool examples/mioos_modules/table/module.json
```
