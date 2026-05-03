# ROI 69 — Patient Registration Validation, Intake Workflow, and Production UX

ROI 69 upgrades the synthetic Patient Registration module from a table-backed foundation into a guided intake workflow. It remains a developer sample and a HIPAA-ready architecture pattern only; it is not a compliance guarantee and must not be used with real PHI until deployment-specific safeguards are implemented.

## Runtime contract

- Dataset: `patient-registration`
- Schema and patient-specific rules: `MIOOSPAT`
- Query/mutation engine: `MIOOSTBL`
- Module registry: `MIOOSMOD`
- Browser surface: `mioos-surface-table` / `mioos-full-table`
- Transport: WebSocket-first table query/mutate with authenticated HTTP fallback.

`MIOOSPAT` now advertises `mioos-patient-registration-v2` in the query payload under `patientRegistration.contract`.

## Intake sections

The row editor groups editable fields by their server-authored column `group` metadata:

1. Identity and demographics
2. Contact information
3. Emergency contact
4. Consent/status
5. Notes
6. Audit fields, shown read-only where applicable

The browser does not own patient workflow logic. It renders the grouped editor, validation summary, field-level errors, toasts, empty/loading states, and the patient workflow banner from server-authored metadata.

## Server-side validation

Patient row and cell mutations are validated server-side through `VALPAT^MIOOSPAT` and related helpers:

- MRN is required and limited to letters, numbers, and hyphens.
- MRN uniqueness is enforced when an existing record attempts to change to another record's MRN.
- First name, last name, DOB, phone, email, state, ZIP, provider, status, and consent are required by the table validation contract.
- DOB must be a real `YYYY-MM-DD` date and cannot be in the future.
- Email, phone, emergency phone, ZIP, and state are format-checked.
- Status must be one of `Draft`, `Pending Review`, `Active`, or `Inactive`.
- Consent must be `Yes`, `No`, or `Unknown`.
- `Active` status requires consent to be `Yes`.
- `Yes` consent requires a consent date.

Failures return deterministic table mutation JSON with `ok:false`, `error`, `message`, and `fieldErrors` so the editor preserves user input and highlights the failing fields.

## Status transitions

Allowed transitions are intentionally conservative:

- New rows can start in any valid status.
- `Draft` can move to `Pending Review` or `Inactive`.
- `Pending Review` can move to `Draft`, `Active`, or `Inactive`.
- `Active` can move to `Pending Review` or `Inactive`.
- `Inactive` can move back to `Active`.

Invalid row-save and cell-save status transitions are rejected server-side.

## Duplicate detection

`MIOOSPAT` performs duplicate detection in two layers:

- Blocking duplicate: conflicting MRN when a row tries to change to an existing MRN.
- Non-blocking warnings: same first name + last name + DOB, same email, or same phone.

Successful mutations may return `warnings.duplicateCandidates` for review. Query payload metadata also includes `patientRegistration.duplicateCandidateCount`.

## Audit and status metadata

Successful patient row and cell mutations update server-side audit/status fields where applicable:

- `createdAt`
- `createdBy`
- `updatedAt`
- `updatedBy`

`AUDPAT^MIOOSPAT` records mutation success/failure details under the patient audit sample global and routes a corresponding event through the MIOOS audit helper.

## UX hardening

The row editor is rendered as a system-style grouped intake modal. Toasts and modal surfaces were made opaque/high-contrast so overlay text does not blend with content below it. Table success/error feedback stays in an absolute feedback rail and does not affect table layout.

## Validation commands

```mumps
ZLINK "MIOOSPAT"
ZLINK "MIOOSTBL"
ZLINK "MIOOSMOD"
ZLINK "MIOOSTBLC"
ZLINK "MIOOST"
DO ^MIOOST
```

Browser checks:

```bash
node --check public/mioos/app/mioos_table.js
node --check public/mioos/app/mioos_modules.js
python3 -m json.tool examples/mioos_modules/patient_registration/module.json
```
