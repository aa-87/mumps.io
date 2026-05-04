# ROI 71A / 71B — UI Regression Hardening and Shell Stability

## Purpose

This ROI begins the larger ROI 71 sequence by stabilizing regressions that block daily use before moving into larger features such as admin user management, full task manager telemetry, and the terminal transport follow-up.

The attached source remains the source of truth. This pass focuses on issues that can be corrected without changing the MIOOS architecture or introducing a build step.

## ROI 71A — Asset, Login, Theme, and Shell Readability Hotfixes

Implemented items:

- Theme assets now derive `Content-Length` from stored asset chunks when served, rather than trusting stale metadata.
- Empty or corrupt theme assets return `asset_empty` instead of emitting mismatched bytes.
- Light-mode Panel menu and context-menu text/background contrast are hardened without changing dark-mode behavior.
- Dark-mode Theme Studio, Explorer, transfer, UI sample, table modal, start menu, and media viewer readability are hardened with additional scoped CSS.
- Start menu metadata suppresses accidental markup such as `# shortcuts ready`.
- Language changes apply document direction immediately and navigate with a stable language query parameter.

## ROI 71B — Explorer, Viewer, Terminal, and Table Regression Fixes

Implemented items:

- Terminal windows now expose a `mountTerminalWindow()` bridge and avoid applying the same socket terminal payload twice when a pending command resolver already handles it.
- Explorer Details view now uses the simple table visual controls and row behavior.
- Explorer Icons view items are draggable and use capped file names.
- Media, image, PDF, text, and structured viewers use a top `File / Edit / Help` menu strip instead of the old `Reload` / `Download` button toolbar.
- Audio and video viewers expose a loop toggle from the Edit menu.
- Text-like viewers now include additional file families such as MUMPS routines, JavaScript, CSS, HTML, moustache/template files, CSV, XML, HL7, X12, and EDI.
- Transfer UI retains more than forty recent items to avoid truncating large batches.
- Patient Registration table banners are only shown when useful patient registration status metadata exists.
- Recursive VFS folder deletion is supported and returns a deterministic recursive acknowledgement.
- The Programs folder is seeded with the same major system apps exposed through the Start menu, with matching icons where possible.

## Deferred ROI 71 slices

The following items are intentionally planned as follow-up ROIs because they require backend contracts, permission checks, deeper UI flows, or new tests beyond a safe regression hotfix:

- **ROI 71C — Common Window Menu API:** shared `File / Edit / View / Tools / Help` contract across shell windows, Explorer, media viewers, tables, and future modules.
- **ROI 71D — Desktop and Explorer Multi-select / Drag-move:** drag rectangle selection, multi-item rename/move/delete, and cross-folder/desktop VFS move semantics.
- **ROI 71E — Admin User Management:** admin-only user maintenance UI for create, inactive, delete, reset initial password, and server-side auditing.
- **ROI 71F — Full Document Viewer:** richer viewer/editor for MUMPS, JavaScript, Markdown, HTML, CSS, moustache, CSV, PDF, XML, HL7, X12, and plain text. Ace Editor may be evaluated, but no dependency should be added without verifying offline/public-library constraints.
- **ROI 71G — Internal Task Manager:** open windows, sessions, transfer state, VFS size, memory estimate, server errors, and admin session visibility.
- **ROI 71H — Regression Lockdown:** broaden MIOOST coverage after the shared menu, multi-select, user-management, viewer, and task manager contracts are complete.

## Validation

Required checks after applying this ROI:

```text
node --check public/mioos/app/mioos_core.js
node --check public/mioos/app/mioos_modules.js
node --check public/mioos/app/mioos_table.js
node --check public/mioos/app/mioos_permissions.js
node --check public/mioos/app/mioos_shell_ui.js
node --check public/mioos/app/mioos_wm.js
node --check public/mioos/app/mioos_state.js
node --check public/mioos/app/mioos_ws.js
node --check public/mioos/app/mioos_explorer.js
node --check public/mioos/app/mioos_terminal.js
node --check public/mioos/app/mioos_i18n.js
python3 -m json.tool examples/mioos_modules/table/module.json
python3 -m json.tool examples/mioos_modules/patient_registration/module.json
D ^MIOOST
```

If YottaDB / GT.M is unavailable, state that `D ^MIOOST` could not be run and perform static MUMPS quote/parity checks.
