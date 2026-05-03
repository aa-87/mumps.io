# Patient Registration Module Sample

This sample demonstrates a MIOOS module backed by `MIOOSTBL` with WebSocket-first table data and mutation commands with authenticated HTTP fallback routes.

Dataset: `patient-registration`

Implemented capabilities:

- Server-side query through `/api/mioos/table/query`
- Server-side mutations through `/api/mioos/table/mutate`
- Patient row add/edit/delete
- Column add/edit/delete/resize
- Select all visible rows
- Bulk delete selected rows
- Grouping, search, pagination, and sorting

The sample is intentionally table-backed so future developers can copy the module manifest and replace the dataset or backend routine while preserving the shell integration contract.

## ROI 63 patient registration target

ROI 68 will turn this into a full end-to-end patient registration sample using the redesigned App Catalogue, table, and form systems. Required capabilities include authenticated module launch, backend CRUD persistence, row create/edit/delete, search/filter/sort, validation for required demographics and contact fields, audit-friendly status messages, and no PHI leakage before authentication.

This remains a developer sample. It may demonstrate a HIPAA-ready architecture pattern, but deployment and operations controls are still required before handling real PHI.


## ROI 68 patient registration foundation

ROI 68 promotes this from a table-only sample into a MUMPS-driven patient registration foundation. The module still uses synthetic sample data. Do not use it with real PHI until deployment, policy, encryption, audit operations, backup, retention, and risk controls are completed.

### Routines

```mumps
ZLINK "MIOOSPAT"
ZLINK "MIOOSTBL"
ZLINK "MIOOSMOD"
ZLINK "MIOOST"
```

### Dataset initialization

```mumps
NEW STATE,ROOT
SET STATE("principal")="demo-user"
SET ROOT=$NAME(^MIO("MIOOS","TABLE","demo-user","patient-registration"))
DO INIT^MIOOSPAT(ROOT)
```

### Patient validation hook

```mumps
SET @ROOT@("validation","routine")="VALPAT^MIOOSPAT"
```

`VALPAT^MIOOSPAT` validates MRN, name, DOB, phone, email, state, ZIP, status, and consent. Field-level errors are returned in `fieldErrors` and rendered by the Advanced Table editor.

### Audit/status marker

Patient table mutations call:

```mumps
DO AUDPAT^MIOOSPAT(.STATE,.CONF,ACTION,.IN,.OUT,OK,.ERR)
```

Audit samples are stored under:

```mumps
^MIO("MIOOS","PATIENT","AUDIT",USER,N,...)
```

## ROI 69 intake workflow

ROI 69 upgrades this sample to the `mioos-patient-registration-v2` contract.

### What changed

- The row editor groups fields into intake sections using column `group` metadata from MUMPS.
- Server-side validation rejects future DOB values, invalid email/phone/ZIP/state values, invalid status transitions, and activation without consent.
- Duplicate MRN changes are blocking validation errors.
- Same name + DOB, same email, and same phone return non-blocking duplicate warnings for review.
- Successful patient row/cell mutations stamp `createdAt`, `createdBy`, `updatedAt`, and `updatedBy` where applicable.

### Try it from MUMPS

```mumps
ZLINK "MIOOSPAT"
ZLINK "MIOOSTBL"
ZLINK "MIOOSMOD"
ZLINK "MIOOSTBLC"
ZLINK "MIOOST"
DO ^MIOOST
```

### Important safety note

This sample uses synthetic data and demonstrates a HIPAA-ready architecture pattern only. Do not use it with real PHI until operational, security, deployment, and compliance controls have been implemented and validated.
