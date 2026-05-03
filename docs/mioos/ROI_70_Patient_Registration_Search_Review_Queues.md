# ROI 70 — Patient Registration Search, Review Queues, and Duplicate Resolution

## Goal

ROI 70 makes Patient Registration operational by adding review queues, patient-specific search/filter surfaces, duplicate-resolution actions, and a direct shell entry point for the Patient Registration module.

The source remains MUMPS-first and server-authored. The browser table reads the contract returned by `MIOOSTBL` and the patient metadata returned by `MIOOSPAT`; no frontend-only patient registry is introduced.

## Clear entry point

Patient Registration can be opened directly from the shell:

- Start Menu / desktop app key: `patient-registration`
- Window id: `win-patient-registration`
- Module id: `mioos.ui.patient.registration`
- Dataset: `patient-registration`
- Component: `table`

The App Catalogue still exposes the same module under Healthcare, but users no longer have to discover the patient table only through the catalogue.

## Backend routines

- `MIOOSST` defines the direct Patient Registration app/window entry.
- `MIOOSMOD` advertises patient-search, review-queue, duplicate-resolution, and direct-entry capabilities.
- `MIOOSTBL` routes patient table queries/mutations through `MIOOSPAT`.
- `MIOOSPAT` owns patient validation, review-queue metadata, duplicate actions, audit stamping, and status transitions.

## Review queues

`MIOOSPAT` computes the `reviewQueue` field for each row. The current queue names are:

- `Drafts`
- `Pending Review`
- `Needs Correction`
- `Active`
- `Inactive`

The query response includes `patientRegistration.reviewQueues` metadata so the browser can render queue buttons without hardcoding patient workflows.

## Patient-specific search and filters

The standard Advanced Table filtering contract is used for patient data. Useful server-side filters include:

```mumps
SET IN("dataset")="patient-registration"
SET IN("filters","status","mode")="include"
SET IN("filters","status","value")="Pending Review"
DO QUERY^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR)
```

```mumps
SET IN("dataset")="patient-registration"
SET IN("filters","dob","mode")="range"
SET IN("filters","dob","from")="1970-01-01"
SET IN("filters","dob","to")="1995-12-31"
DO QUERY^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR)
```

```mumps
SET IN("dataset")="patient-registration"
SET IN("filters","duplicateStatus","mode")="include"
SET IN("filters","duplicateStatus","value")="Candidate"
DO QUERY^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR)
```

## Duplicate-resolution actions

The table exposes server-side row actions:

- `patient.duplicate.mark`
- `patient.duplicate.clear`
- `patient.review.needs-correction`
- `patient.review.pending`

Example:

```mumps
SET IN("dataset")="patient-registration"
SET IN("action")="patient.duplicate.mark"
SET IN("rowId")="PAT-1001"
DO MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR)
```

Bulk queue actions are also server-side:

```mumps
SET IN("dataset")="patient-registration"
SET IN("action")="patient.bulk.pending"
SET IN("ids",1)="PAT-1001"
SET IN("ids",2)="PAT-1003"
DO MUTATE^MIOOSTBL(.STATE,.CONF,.IN,.OUT,.ERR)
```

Successful mutations return acknowledgement-only payloads and rely on table refetch to repaint final server state.

## Audit behavior

Patient table mutations call `AUDPAT^MIOOSPAT`, which writes deterministic audit entries under:

```mumps
^MIO("MIOOS","PATIENT","AUDIT",principal,n)
```

The audit entries include action, outcome, patient id, status/value context, timestamp, and principal. This is an architectural audit trail pattern, not a HIPAA-compliance claim.

## Modal overlay behavior

ROI 70 restores the original modal backdrop behavior. Only modal/dialog bodies are forced opaque so stacked content does not become illegible. Backdrop transparency remains controlled by the original shell/table CSS.

## Tests

`D ^MIOOST` runs ROI 70 file-level checks through `T074` and backend-contract checks through `RUN^MIOOSTBLC`, including:

- patient v3 contract metadata
- review-queue query metadata
- patient duplicate row actions
- patient bulk review actions
- review queue filtering
- duplicate mark/clear mutations
- audit write checks
- direct Patient Registration window entry point
