
## ROI 64G stabilization

This stabilization pass fixes the first validation/table UX regressions found after ROI 64G was applied:

- JSON boolean values from table mutation requests are normalized with `TRUTH^MIOOSTBL`, so `column.visibility` correctly persists `hidden=true` and `hidden=false` instead of treating JSON `true` as numeric zero.
- Existing per-user demo datasets are upgraded in-place with validation rules when missing. This prevents older seeded table globals from bypassing ROI 64G validation.
- The demo table now exposes Notes as a real `notes` schema column in the `Notes` column group. Existing rows are backfilled from `_expand("body")`, so Notes can be edited and managed through the column picker.
- Successful mutations show a non-blocking confirmation toast.
- Grouping and filtering controls open modal dialogs instead of inline `<details>` panels.
- The pager now shows the current visible range, for example `Showing 51–75 of 120 rows`, instead of only repeating filtered/total counts.

Regression commands remain:

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSAPI"
ZLINK "MIOOSWS"
ZLINK "MIOOST"
DO ^MIOOST
```

## ROI 64G stabilization follow-up

The stabilization patch addresses runtime issues found after ROI 64G:

1. `column.visibility` now accepts JSON boolean values with `TRUTH^MIOOSTBL`; hidden columns no longer reselect themselves after refresh.
2. Existing demo and patient datasets are upgraded with validation rules if they predate ROI 64G.
3. Validation failures return `fieldErrors` from both HTTP and WebSocket mutation paths.
4. The row editor keeps user input, shows field-level errors, and does not close on validation failure.
5. Successful mutations show a non-blocking table toast.
6. The demo table exposes an editable `notes` column and backfills it from older `_expand("body")` values.
7. Filter and group controls are modal dialogs. Grouping supports `groupByColumns`.
8. Pagination displays the visible row range for the current page.

Validation examples:

```mumps
SET @ROOT@("validation","fields","name","required")=1
SET @ROOT@("validation","fields","name","message")="Name is required"
SET @ROOT@("validation","fields","status","enum",1)="Open"
SET @ROOT@("validation","fields","status","enum",2)="Done"
SET @ROOT@("validation","fields","updated","date")=1
```

Mutation error shape:

```json
{
  "ok": false,
  "error": "table_mutate_failed",
  "detail": "validation_failed",
  "message": "Name is required",
  "fieldErrors": {
    "name": "Name is required"
  }
}
```
