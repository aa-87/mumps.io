# ROI 64J — Column Reorder

ROI 64J adds DataTables-style column reorder to the MIOOS Advanced Table while keeping the backend as the source of truth.

## Goal

Allow a MUMPS-authored table module to enable user-driven column ordering without writing frontend code. The browser may move columns in the Columns modal, but persistence always goes through `MUTATE^MIOOSTBL`.

## MUMPS contract

Enable reorder in the module/table config:

```mumps
SET MOD("tableState","config","features","columnReorder")=1
```

Column order is the order of the schema nodes:

```mumps
SET @ROOT@("schema","columns",1,"key")="name"
SET @ROOT@("schema","columns",2,"key")="status"
SET @ROOT@("schema","columns",3,"key")="owner"
```

After a reorder save, `MIOOSTBL` rewrites `schema("columns",n)` in the requested order while preserving each column's label, type, width, visibility, validation metadata, and editability flags.

## Mutation

The UI sends `column.reorder` through WebSocket `table.mutate` first, with HTTP `/api/mioos/table/mutate` as fallback. Both transports call the same backend routine.

```json
{
  "dataset": "demo",
  "action": "column.reorder",
  "mutationOnly": true,
  "columns": [
    { "key": "status", "order": 1 },
    { "key": "name", "order": 2 },
    { "key": "owner", "order": 3 }
  ]
}
```

Successful acknowledgement:

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

## Validation

`VALORDER^MIOOSTBL` rejects:

- missing column payloads
- invalid column keys
- duplicate column keys
- unknown column keys
- incomplete order payloads that do not include every column

## UI behavior

The Columns modal includes up/down controls when `features.columnReorder` is enabled. The controls save immediately, show a non-blocking toast, and refetch the table from the server.

The same pass also keeps Add Value and destructive confirmations inside MIOOS table dialogs instead of native browser `prompt()` or `confirm()` controls.

## Reload/test commands

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSMOD"
ZLINK "MIOOSMTBL"
ZLINK "MIOOST"
DO ^MIOOST
```
