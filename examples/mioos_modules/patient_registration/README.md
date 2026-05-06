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

## ROI 72 CSV import and reconciliation

Use the Patient Registration table toolbar:

1. Open **Patient Registration** from the Start Menu or App Catalogue.
2. Choose **Patient import**.
3. Paste CSV with headers such as:

```csv
mrn,lastName,firstName,dob,phone,email,state,zip,status,consent
P100,Doe,Jane,1980-01-01,555-0100,jane@example.invalid,NY,10001,Draft,No
```

4. Click **Preview** to validate rows without committing.
5. Click **Commit valid rows** to add valid rows.
6. Use **Reconcile** to generate duplicate-candidate reports.

All import and reconciliation operations go through MUMPS table mutations and server-side validation.

## Final regression stabilization

The Patient Registration example exercises the same table backend contract as the runtime module. `row.add`, `row.save`, `cell.save`, `column.option.add`, `column.add`, `patient.import.commit`, and `patient.reconcile.report` must route through `MUTATE^MIOOSTBL` / `MIOOSPAT` and return deterministic feedback. Keep PHI behavior server-authoritative and preserve audit hooks when extending the example.

## Quoted CSV example

The Patient Registration import path accepts quoted CSV fields through the MUMPS backend parser. Use quoted CSV when names, notes, or other values contain commas:

```csv
mrn,lastName,firstName,dob,phone,email,state,zip,status,consent
"PAT-8900","Quoted, Last","Ada","1980-01-02","555-8900","quoted.import@example.invalid","NY","10001","Draft","No"
```

Preview and commit still call the same patient table mutations, so required-field validation, status normalization, duplicate/reconcile metadata, and audit fields remain server-controlled.

## Login/theme/start-menu/text-viewer regression ROI note

Patient Registration remains a table-backed MUMPS workflow. The login shell now shows safe retry/success feedback before the desktop loads, so patient windows should only appear after authenticated boot. The Start Menu group that exposes examples/modules can be collapsed session-locally; expanding it should launch Patient Registration normally. Quoted CSV import behavior and patient mutation routing are unchanged.


## ROI 99 regression notes

Patient Registration continues to use the shared Advanced Table surface and server-side patient workflow. Dark Theme readability for patient rows, review filters, CSV import modal controls, validation messages, selected rows, and empty/error states is supplied by the scoped table CSS contract. Do not add patient-specific light backgrounds that bypass the shared table variables.

## ROI 101 patient table notes

Patient Registration remains server-authoritative through `MIOOSPAT` and the Advanced Table mutation contract. Dark Theme patient rows, import/reconcile filters, review controls, selected rows, modal inputs, empty states, and validation messages are covered by the shared table variables. Keep patient-specific customizations scoped to the patient surface and do not bypass the shared table color contract with hardcoded light backgrounds.
