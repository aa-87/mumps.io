# ROI 72 — Patient Registration Import/Export and Reconciliation

## Summary

ROI 72 adds controlled Patient Registration import/export and reconciliation primitives while fixing regressions that blocked table authoring and patient row creation.

## Regression gate completed first

- Table UI dialogs can be dismissed with Escape through a global table-dialog closer.
- The Table Module Definition modal can be closed even when the close button is off-screen because Escape closes the active editor.
- Select and multiselect cell editors can add new values through the existing server-side `column.option.add` mutation.
- Table cell editors now recognize common patient-centric field types: `mrn`, `state`, `gender`, `dob`, `zip`, `phone`, `email`, plus basic `multiselect`, `url`, `time`, `datetime`, `currency`, and `percent` controls.
- Table Module Definition JSON export downloads a `.json` file and also leaves the JSON visible for copy/paste.
- Table Module Definition JSON import validates key/title/columns and duplicate column keys before calling the backend.
- Patient Registration Add Row defaults now stay in the active review queue instead of being immediately routed out by missing-consent review logic.
- The Advanced Table MUMPS API sample surface now includes additional variants from simple read-only tables through patient import/reconciliation workflows.
- Shell regressions were addressed for compact Start Menu layout, single context-menu dismissal, double-click maximize/restore behavior, viewer surfaces, titlebar contrast, desktop icon placement, and mobile-friendly transfer rows.

## Backend contract

Patient import and reconciliation run through normal table mutations against dataset `patient-registration`:

```json
{ "dataset": "patient-registration", "action": "patient.import.preview", "csv": "mrn,lastName,firstName,dob,phone,email,state,zip,status,consent\nP100,Doe,Jane,1980-01-01,555-0100,jane@example.invalid,NY,10001,Draft,No" }
```

Supported actions:

- `patient.import.preview` — validates CSV rows and returns `importPreview.valid`, `importPreview.invalid`, and counts without committing rows.
- `patient.import.commit` — validates and commits valid rows, leaving invalid rows in the report.
- `patient.reconcile.report` — scans patient rows for duplicate MRN, same name + DOB, same email, and same phone candidates.
- `patient.export.selected` — authorizes patient export intent through the Patient Registration permission gate. CSV bytes should still use the existing `rows.export` contract for selected rows.

## Permission posture

ROI 72 preserves ROI 71 behavior. Patient import requires create permission, patient export requires export permission, and reconciliation requires review permission. Unauthorized attempts return deterministic JSON through the table mutation contract.

## CSV scope

The first ROI 72 import path intentionally supports simple header-based CSV. It is suitable for controlled internal imports and copy/paste previews. Complex CSV with embedded commas or file uploads should be handled by a later file-import workflow.

## Terminal and cell-type follow-up plan

The request also identified broader table-editor and terminal needs. The implemented part covers common cell editor types now. The recommended follow-up sequence is:

- **ROI 72T1 — Table Cell Type Matrix:** productionize every table editor type with contract tests and sample columns.
- **ROI 72T2 — Patient-Centric Cell Widgets:** specialized MRN, DOB, phone, ZIP/state, consent, status, and duplicate-review editors.
- **ROI 72T3 — Table Authoring Type Validation:** complete schema validation for every type in Table Module Definition.
- **ROI 76 — Terminal Transport Rewrite Foundation:** terminal socket/pipe lifecycle, multiple sessions, and immediate I/O behavior.
- **ROI 77 — Terminal Profiles and Customization:** profile-specific fonts, size, colors, background, and launcher shortcuts.
- **ROI 78 — Terminal Automation Sequences:** timed startup input sequences and routine-specific terminal shortcuts.

