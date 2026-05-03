# ROI 64G — Table Mutation Validation and Developer Utilities

## Goal

Make table mutation validation first-class and customizable for MUMPS developers without requiring frontend code.

## Implemented behavior

- Row mutations run backend validation before persistence.
- Built-in rule helpers support `required`, `maxLength`, `enum`, `type="date"`, `type="number"`, `min`, and `max`.
- Datasets may define an optional custom MUMPS validation hook with `@ROOT@("validation","routine")="TAG^ROUTINE"`.
- Validation failures return deterministic mutation acknowledgements with `ok:false`, `error:"validation_failed"`, `mutationOnly:true`, `refetch:false`, and `fieldErrors`.
- The Vue Options API table editor keeps the row editor open and renders field-level messages returned by the backend.
- 

Developer helper entry points are also available for setup routines:

```mumps
DO VREQ^MIOOSTBL(ROOT,"name","Name")
DO VMAX^MIOOSTBL(ROOT,"name",120)
DO VENUM^MIOOSTBL(ROOT,"status",1,"Open")
DO VENUM^MIOOSTBL(ROOT,"status",2,"Done")
DO VDATE^MIOOSTBL(ROOT,"updated","Updated")
DO VNUM^MIOOSTBL(ROOT,"score","Score")
DO VRANGE^MIOOSTBL(ROOT,"score",0,100)
DO VHOOK^MIOOSTBL(ROOT,"VALTABLE^MYTABVAL")
```

Mutation attempts are audited under `@ROOT@("audit",n,...)` with user, timestamp, dataset, action, status, error/message, and field errors.

## Dataset rule example

```mumps
NEW USER,ROOT
SET USER=$GET(STATE("principal"),"admin")
SET ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"example"))

SET @ROOT@("validation","fields","name","label")="Name"
SET @ROOT@("validation","fields","name","required")=1
SET @ROOT@("validation","fields","name","maxLength")=120

SET @ROOT@("validation","fields","status","label")="Status"
SET @ROOT@("validation","fields","status","required")=1
SET @ROOT@("validation","fields","status","enum",1)="Open"
SET @ROOT@("validation","fields","status","enum",2)="Done"
SET @ROOT@("validation","fields","status","enum",3)="Review"

SET @ROOT@("validation","fields","score","label")="Score"
SET @ROOT@("validation","fields","score","type")="number"
SET @ROOT@("validation","fields","score","min")=0
SET @ROOT@("validation","fields","score","max")=100

SET @ROOT@("validation","fields","updated","label")="Updated"
SET @ROOT@("validation","fields","updated","type")="date"
```

## Custom hook example

```mumps
SET @ROOT@("validation","routine")="VALTABLE^MYTABVAL"
```

Expected hook signature:

```mumps
VALTABLE(STATE,CONF,DATASET,ACTION,IN,ERR)
    IF ACTION'="row.save" QUIT
    IF $GET(IN("row","status"))="Done",$GET(IN("row","updated"))="" DO
    . SET ERR("error")="validation_failed"
    . SET ERR("message")="Updated date is required when status is Done"
    . SET ERR("fieldErrors","updated")="Required when status is Done"
    QUIT
```

## Error response target

```json
{
  "ok": false,
  "dataset": "example",
  "action": "row.save",
  "error": "validation_failed",
  "message": "Name is required",
  "fieldErrors": {
    "name": "Name is required"
  },
  "mutationOnly": true,
  "refetch": false
}
```

## Audit nodes

Each mutation attempt appends an audit node:

```mumps
SET @ROOT@("audit",N,"at")="2026-05-02T...Z"
SET @ROOT@("audit",N,"user")="admin"
SET @ROOT@("audit",N,"dataset")="example"
SET @ROOT@("audit",N,"action")="row.save"
SET @ROOT@("audit",N,"ok")=0
SET @ROOT@("audit",N,"stage")="validation"
SET @ROOT@("audit",N,"fieldErrors","name")="Name is required"
```

## Validation checklist

```mumps
ZLINK "MIOOSTBL"
ZLINK "MIOOSAPI"
ZLINK "MIOOSWS"
ZLINK "MIOOST"
DO ^MIOOST
```

Browser syntax checks:

```text
node --check public/mioos/app/mioos_table.js
python3 -m json.tool examples/mioos_modules/table/module.json
```
