# ROI 68 — Patient Registration Foundation

ROI 68 turns the existing Patient Registration sample into a production-shaped, MUMPS-driven module foundation. It still uses synthetic sample data and must not be represented as HIPAA compliance by itself. The goal is a HIPAA-ready architecture pattern: authenticated shell launch, server-side persistence, deterministic validation, audit/status markers, and no patient rows emitted before protected table routes are called.

## Runtime ownership

- Module catalogue entry: `MIOOSMOD`
- Dataset/query/mutation path: `MIOOSTBL`
- Patient-specific schema, validation, and audit helpers: `MIOOSPAT`
- Transport: WebSocket-first `table.query` / `table.mutate`, with authenticated HTTP fallback through `/api/mioos/table/query` and `/api/mioos/table/mutate`

The browser remains a thin renderer. It displays the Advanced Table surface and a compact patient status banner when the query payload includes `patientRegistration` metadata.

## Dataset contract

Dataset key:

```mumps
patient-registration
```

The patient dataset is still stored under the per-principal table global managed by `MIOOSTBL`:

```mumps
SET ROOT=$NAME(^MIO("MIOOS","TABLE",USER,"patient-registration"))
```

`INIT^MIOOSPAT(ROOT)` backfills the schema with patient-specific fields:

```mumps
email
address1
city
state
zip
consent
emergencyContact
notes
updatedAt
```

It also marks the dataset with:

```mumps
SET @ROOT@("meta","contract")="mioos-patient-registration-v1"
SET @ROOT@("features","patientRegistration")=1
SET @ROOT@("features","auditStatus")=1
SET @ROOT@("validation","routine")="VALPAT^MIOOSPAT"
```

## Validation

Generic table validation still runs first. ROI 68 adds patient-specific validation through `VALPAT^MIOOSPAT` and `VALFIELD^MIOOSPAT`.

Validated fields include:

- `mrn`: required, letters/numbers/hyphen only
- `firstName`: required
- `lastName`: required
- `dob`: required valid `YYYY-MM-DD`
- `phone`: required valid phone-like value
- `email`: optional but must look like email when supplied
- `state`: optional two-letter code from the table option list
- `zip`: optional `12345` or `12345-6789`
- `status`: `Active`, `Pending`, `Inactive`, or `Archived`
- `consent`: `Yes`, `No`, or `Unknown`

Validation failures return the existing deterministic mutation shape:

```json
{
  "ok": false,
  "error": "table_mutate_failed",
  "fieldErrors": {
    "email": "Enter a valid email address"
  },
  "mutationOnly": true,
  "refetch": false
}
```

## Mutation and audit

All patient creates, edits, deletes, selected-row CSV exports, column changes, and cell saves continue through `MUTATE^MIOOSTBL`. When the dataset is `patient-registration`, `MUTATE^MIOOSTBL` calls:

```mumps
DO AUDPAT^MIOOSPAT(.STATE,.CONF,ACTION,.IN,.OUT,OK,.ERR)
```

ROI 68 writes sample audit/status records under:

```mumps
^MIO("MIOOS","PATIENT","AUDIT",USER,N,...)
```

It also emits the existing auth audit event helper:

```mumps
DO EVENT^MIOOSAUD("patient.registration.table",.CTX,.STATE,DETAIL,OUTCOME,ID,"mioos")
```

## MUMPS-driven example

Reload routines:

```mumps
ZLINK "MIOOSPAT"
ZLINK "MIOOSTBL"
ZLINK "MIOOSMOD"
ZLINK "MIOOST"
```

Seed or backfill the authenticated user's patient dataset:

```mumps
NEW STATE,ROOT
SET STATE("principal")="demo-user"
SET ROOT=$NAME(^MIO("MIOOS","TABLE","demo-user","patient-registration"))
DO INIT^MIOOSPAT(ROOT)
```

Register a launchable patient module entry from MUMPS:

```mumps
KILL MOD
SET MOD("key")="patient-registration"
SET MOD("title")="Patient Registration"
SET MOD("category")="Healthcare"
SET MOD("icon")="🏥"
SET MOD("componentKey")="table"
SET MOD("surface")="mioos-surface-table"
SET MOD("tableState","id")="patient-registration-table"
SET MOD("tableState","title")="Patient Registration"
SET MOD("tableState","dataset")="patient-registration"
SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
SET MOD("tableState","config","defaultSort","column")="lastName"
SET MOD("tableState","config","defaultSort","direction")="ascending"
SET MOD("tableState","config","features","cellEditing")=1
SET MOD("tableState","config","features","columnReorder")=1
SET MOD("tableState","config","features","fixedColumns")=1
SET MOD("tableState","config","fixedColumns","start")=1
DO REGISTER^MIOOSMOD(.MOD)
```

Validate:

```mumps
DO ^MIOOST
```

## HIPAA note

This module uses synthetic sample data. MIOOS can demonstrate HIPAA-ready architecture patterns, but HIPAA compliance requires deployment controls, access policy, encryption/key management, audit operations, backups, retention policy, monitoring, staff procedures, and risk analysis outside this code ROI.
