# ROI 68A — Advanced Table Backend Contract Tests and Sample Matrix

## Goal

ROI 68A locks the Advanced Table backend contract before ROI 69 patient workflow work. The table has accumulated WebSocket-first query/mutation transport, validation, typed controls, selected-row CSV export, editable cells, column reorder, fixed columns, and hardening fixes. This ROI makes those behaviors explicit in regression tests and expands the MUMPS-first table sample matrix.

## Contract version

The current table contract is:

```text
mioos-advanced-table-v8
```

`QUERY^MIOOSTBL` now returns this value in `OUT("contract")` for normal and massive dataset responses. Table module manifests should continue setting:

```mumps
SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
```

## Backend contract coverage

## Backend contract tests

`MIOOST` now calls `RUN^MIOOSTBLC`. The helper routine adds direct backend contract coverage while keeping `MIOOST` quiet on success and explicit on failure.

Covered areas:

- Query response shape: `ok`, `contract`, `dataset`, `draw`, `recordsTotal`, `recordsFiltered`, `schema.columns`, `rows`, `groups`, `pagination.*`, `features`, `rowActions`, and `bulkActions`.
- `includeDataAlias:false` omits the duplicate `data` payload; `includeDataAlias:true` includes it explicitly.
- Server-side pagination returns only requested rows.
- The `massive` dataset uses page-only materialization and avoids unnecessary browser payloads.
- Page jump inputs clamp to valid page ranges.
- Mutation acknowledgements for `column.visibility`, `row.save`, `cell.save`, `column.option.add`, `column.reorder`, `column.fixed`, and `rows.export` remain small and deterministic.
- Failed mutations return field-level validation errors through the same `MUTATE^MIOOSTBL` backend path used by HTTP and WebSocket wrappers.
- Required, max length, enum/select, multiselect, boolean, strict date, numeric, numeric range, row hook, and cell callback validation.
- Basic search, column filters, advanced filter modes, named-column sorting, and multi-column grouping.
- Read-only/massive feature composition disables row actions, selection, CRUD, and bulk actions.
- Fixed columns, hidden columns, and editable cells continue working after refetch/sort/filter composition.
- Known browser regressions: no free `vm` reference in `backendTableApplyPayload`, close controls do not start drags, no native `prompt()` or `confirm()`, and loading remains bar-only.

## Validation additions

`MIOOSTBL` now supports the table validation metadata below in addition to the existing required, max length, enum, date, numeric, and patient-specific rules:

```mumps
SET @ROOT@("validation","fields","score","numeric")=1
SET @ROOT@("validation","fields","score","min")=0
SET @ROOT@("validation","fields","score","max")=100
SET @ROOT@("validation","fields","active","boolean")=1
SET @ROOT@("validation","fields","tags","multiselect")=1
SET @ROOT@("validation","fields","tags","enum",1)="Core"
SET @ROOT@("validation","fields","tags","enum",2)="Urgent"
SET @ROOT@("validation","routine")="VALMYROW^MYTABVAL"
```

Multiselect values may be stored as a pipe-, semicolon-, or comma-delimited string. The browser inline cell editor uses the existing array-to-string pattern, and the backend validates each selected value against `enum`.

A generic row validation hook may be registered with `validation("routine")`. The hook signature is:

```mumps
VALMYROW(IN,ERR,ROOT)
 ; Return 1 to accept, 0 to reject.
 QUIT 1
```

A cell callback remains per-column:

```mumps
SET @ROOT@("schema","columns",3,"cellCallback")="STATUS^MYTABCB"
```

The callback signature remains:

```mumps
STATUS(STATE,DATASET,ROWID,COLUMN,VALUE,OUT,ERR)
 ; May set OUT("value") to normalize the saved value.
 QUIT 1
```

## Transport contract

Both authenticated transports must continue calling the same backend routine:

- HTTP: `TABLEMUTATE^MIOOSAPI` → `MUTATE^MIOOSTBL`
- WebSocket: `TABLEMUTATE^MIOOSWS` → `MUTATE^MIOOSTBL`

Domain failures should return deterministic mutation JSON rather than timing out:

```json
{
  "ok": false,
  "dataset": "demo",
  "action": "row.save",
  "error": "table_mutate_failed",
  "message": "Please fix the highlighted fields",
  "fieldErrors": { "name": "Name is required" },
  "mutationOnly": true,
  "refetch": false
}
```

Successful table mutations remain acknowledgement-only and do not return `rows` or `schema`. The browser refetches when the acknowledgement asks it to refetch.

## Validation commands

Run in a YottaDB / GT.M environment:

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

Also run browser and manifest checks from the repository root:

```bash
node --check public/mioos/app/mioos_table.js
python3 -m json.tool examples/mioos_modules/table/module.json
```

## Sample matrix

Expanded samples live in `examples/mioos_modules/table/samples/`:

- `basic_readonly.m`
- `editable_cells.m`
- `validation_rules.m`
- `advanced_filters.m`
- `grouping_reorder_fixed.m`
- `server_csv_export.m`
- `table_module_registration.m`

Each sample answers what routine/global to edit, which `MOD(...)` nodes to set, how to make the icon appear, how to open the table from the shell, and how to validate with `D ^MIOOST`.
