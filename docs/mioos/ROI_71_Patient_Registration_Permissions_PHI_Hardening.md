# ROI 71 — Patient Registration Permissions and PHI Visibility Hardening

ROI 71 hardens the synthetic Patient Registration module so access decisions happen before patient rows are loaded or mutated. This remains a HIPAA-ready architecture pattern only; it is not a claim of HIPAA compliance.

## Server-side permission gates

`MIOOSPAT` owns patient-specific permission helpers:

- `CANLAUNCH^MIOOSPAT(.STATE)` decides whether the Patient Registration entry point appears in the shell or App Catalogue.
- `CAN^MIOOSPAT(.STATE,ACTION)` maps patient actions to permission classes.
- `ALLOW^MIOOSPAT(.STATE,ACTION,.ERR)` returns deterministic denial errors.
- `PERMACT^MIOOSPAT(ACTION)` maps table actions to `read`, `create`, `write`, `review`, `export`, or `delete`.
- `MASKOUT^MIOOSPAT(.OUT,.STATE)` masks PHI for limited read-only roles.

`MIOOSTBL` calls these helpers before patient table query and mutation paths. Denied users receive `patient_access_denied`, and rows are not materialized into the response.

## Role model used by the sample

The sample recognizes these roles:

- `admin`, `developer`, `patient-admin`: full patient module access.
- `registrar`: create, edit, and review workflow actions; export/delete denied.
- `clinician`: read and edit; export/delete denied.
- `patient-read`, `patient-reader`, `patient-readonly`, `auditor`: read with masked PHI.
- unauthenticated or `guest`: denied before patient rows load.

Deployments should replace or extend this sample role model with their own policy source.

## PHI masking

For limited read-only roles, the table response is marked with:

```json
{
  "features": { "phiMasked": 1 },
  "patientRegistration": { "phiMasked": 1 }
}
```

The row payload masks fields such as MRN, name, DOB, phone, email, address, and emergency contact details. This lets the same table UI show operational queue metadata without revealing full PHI.

## Direct entry point hardening

The Patient Registration App Catalogue entry and shell window are gated through `CANLAUNCH^MIOOSPAT`. Unauthorized users do not receive the direct Patient Registration launcher. The general UI Modules tool remains available when the module system is enabled.

## Queue-aware Add Row fix

The browser now seeds new Patient Registration rows from the active review queue:

- Pending Review: `status="Pending Review"`, `consent="No"`
- Active: `status="Active"`, `consent="Yes"`
- Needs Correction: `status="Draft"`, `consent="Unknown"`
- Drafts/default: `status="Draft"`, `consent="Unknown"`

The same defaulting is repeated on the server through `ADDDEF^MIOOSPAT` so the contract does not depend on browser behavior.

## Compact cell edit buttons

Inline cell editing now uses compact icon controls:

- `✓` saves the cell.
- `×` cancels the edit.

The controls use the `mioos-table-cell-action` CSS class to reduce footprint inside dense tables.

## Tests

`D ^MIOOST` runs ROI 71 file-level checks through `T075` and backend-contract checks through `RUN^MIOOSTBLC` / `TPAT71`, including:

- unauthenticated patient query denied before rows load
- read-only patient role receives masked PHI
- read-only mutation denied
- queue-aware add row defaults
- registrar export denied
- catalogue launch allowed for admin
