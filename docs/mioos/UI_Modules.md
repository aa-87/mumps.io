# MIOOS UI Modules

The module registry is installed but disabled by default in boot state. The App Catalogue fetches the registry after sign-in through `/api/mioos/modules/catalog`.

Built-in catalogue entries include:

- App Catalogue
- Table Samples
- Massive Dataset Table
- Permissions UI
- UI + Form Elements
- Patient Registration

The module catalogue can launch table-backed surfaces by setting:

```json
{
  "componentKey": "table",
  "surface": "mioos-surface-table",
  "tableState": { "dataset": "patient-registration" }
}
```

Permissions UI uses `mioos-surface-permissions` and demonstrates tabbed permission panels, role matrix toggles, and an audit sample.

## ROI 64B UI elements example rewrite

`UI + Form Elements` is no longer table-backed. It now launches as a standalone component gallery:

```json
{
  "componentKey": "ui-elements",
  "surface": "mioos-surface-ui-elements"
}
```

The gallery is interactive and stateful. It demonstrates text inputs, textareas, selects, radio groups, checkbox groups, switches, date and number inputs, file-picker metadata capture, validation, required/optional indicators, disabled/read-only states, saving/loading states, inline help, tabbed form sections, modal forms, confirmation dialogs, toasts, empty states, and error states.

The example intentionally avoids backend table coupling. Production modules should copy the interaction and accessibility patterns, then submit sanitized payloads through authenticated backend routes for persistence and audit.


## ROI 64C table modules

Table-backed modules should use `mioos-surface-table` with the `mioos-advanced-table-v8` contract. Provide a dataset and optional `config` object instead of writing custom table state logic. The table owns WebSocket-first query/mutation state with HTTP fallback, server filtering, selection, grouping, column visibility, resizing, and row/column CRUD.

## ROI 64C redo table module guidance

Table modules should now target `mioos-advanced-table-v8`. The contract is DataTables-inspired but remains a MIOOS-native Vue Options API component. Module authors should configure datasets, columns, and feature gates; they should not fork table rendering or implement custom client-side pagination for large datasets.

## Table Samples showcase

`table-samples` now opens `mioos-surface-table-showcase` instead of a single static table. The showcase demonstrates simple, dense, editable, patient-registration, and massive read-only table variations. Each card includes MUMPS `SET MOD(...)` contract snippets needed to register that table from the backend catalog or a user-created module.

The table component itself remains `mioos-full-table`; the showcase is a developer reference surface for choosing the right configuration.

## ROI 64E table module guidance

For table modules, prefer backend `MOD(...)` and dataset globals over frontend snippets. `mioos-surface-table` reads `MOD("tableState",...)`, so a MUMPS developer should define the dataset under `^MIO("MIOOS","TABLE",user,dataset,...)` and then set `MOD("componentKey")="table"`, `MOD("surface")="mioos-surface-table"`, and `MOD("tableState","dataset")=<dataset>`.

The table UI now separates row details from actions. Details are an expand arrow in the control column. Row actions remain in the Actions column and only render when row CRUD/action features are enabled. Column selection is modal-only, and column editing is exposed only when column CRUD is enabled.

## Advanced table stabilization notes

Table modules now target `mioos-advanced-table-v8`. Use schema `type` and validation enum metadata to drive typed row editors and typed filter controls. Table modals should use the bounded table-window dialog helpers, not fixed viewport overlays.

The next planned table module sequence is ROI 64I through ROI 64K:

- ROI 64I: editable cells with typed controls and optional MUMPS cell callbacks. Implemented through `cell.save` and documented in `ROI_64I_Editable_Cells.md`.
- ROI 64J: column reorder on boot and as a user option.
- ROI 64K: fixed columns on boot and as a user option.

See `ROI_64I_64K_Table_DataTables_Parity.md` for the MUMPS contracts.


## ROI 64I editable-cell module behavior

Table-backed modules can enable cell editing with:

```mumps
SET MOD("tableState","config","features","cellEditing")=1
SET MOD("tableState","config","mutateTransport")="websocket"
```

The module author controls each cell from MUMPS schema metadata. Non-ID columns default to editable unless `editable=0`; ID columns remain read-only. Optional column `cellCallback` entries let a MUMPS routine validate or normalize a single cell before persistence without frontend code.

## ROI 64J column reorder UI

The Advanced Table Columns modal now supports column reorder when `features.columnReorder` is enabled. Users move a column up or down; each move saves through `column.reorder`, returns an acknowledgement, and refetches the server-authored schema. Native browser prompts/confirms are avoided in favor of MIOOS table dialogs.



## ROI 68 patient registration module

The Patient Registration catalogue entry launches `mioos-surface-table` with dataset `patient-registration`. The browser displays the standard Advanced Table with a compact patient-status banner supplied by the backend. MUMPS developers should extend patient fields and validation in `MIOOSPAT` rather than adding frontend code.

## ROI 64L table module polish

The Advanced Table module now treats editable cells, validation, column visibility, column reorder, fixed columns, grouping, filtering, and selected-row CSV export as one composed server-side surface. User-created table modules should enable table features through `MOD("tableState","config","features",...)` and persist fixed-column defaults through `MOD("tableState","config","fixedColumns",...)`.


## Start Menu launcher contract

The Start Menu is a shell component, not a standalone SPA. Its component markup is in `public/mioos/app/mioos_shell_ui.js`, and its source entries are normalized through `startMenuAppCatalogItems()`, `startMenuFilesystemItems()`, and `startMenuGroups()` in `public/mioos/app/mioos_core.js`.

ROI 72C rewrites the visual presentation only. New modules should continue to appear through the module/App Catalogue path, while language shortcuts, theme shortcuts, Folder Explorer, Desktop VFS items, search, and keyboard navigation remain part of the contract.

## Start Menu and Theme Login follow-up

The Start Menu component is a modern mobile-friendly launcher with expandable groups and recursively expandable VFS folders. The popup style can be repositioned by dragging the header. Folder expansion uses the existing `fs.list` command and does not preload every folder on boot.

The login modal is driven by Theme Studio login configuration: wallpaper, avatar, warning image/title, and disclaimer. Protected `/api/mioos/theme-asset` and `/api/mioos/fs/blob` URLs are sanitized before authentication so authenticated assets are not emitted pre-login.

## ROI 72C2 shell viewer and Start Menu behavior

The shell now registers a shared `mioos-surface-viewer` for text, image, PDF, audio, video, and structured file windows. Start Menu VFS folders expand in-place and lazy-load children with `fs.list`; clicking a folder toggles expansion rather than closing the menu.

## ROI 68A table-backed module contract lock

Table-backed modules should use the built-in `mioos-surface-table` and the backend-owned `MIOOSTBL` contract. A MUMPS module author does not need JavaScript to create a table module:

```mumps
SET MOD("componentKey")="table"
SET MOD("surface")="mioos-surface-table"
SET MOD("tableState","dataset")="sample-readonly"
SET MOD("tableState","config","contract")="mioos-advanced-table-v8"
SET MOD("tableState","config","features","cellEditing")=1
SET MOD("tableState","config","features","columnReorder")=1
SET MOD("tableState","config","features","fixedColumns")=1
```

The table backend owns query, mutation, validation, export, column metadata, fixed-column metadata, and selected-row CSV generation. HTTP and WebSocket table mutations must continue to call `MUTATE^MIOOSTBL`; frontend module code should not fork mutation handling.

Expanded MUMPS-first samples are under `examples/mioos_modules/table/samples/`. Start with `basic_readonly.m`, then add `editable_cells.m`, `validation_rules.m`, `advanced_filters.m`, `grouping_reorder_fixed.m`, `server_csv_export.m`, and `table_module_registration.m` as needed.

## Shell toolbar and viewer regression contract

All shell windows should prefer the common `mioos-window-toolbar` for File/Edit/module/Help actions. Module-local command rows should be avoided when the same action belongs in the common toolbar. Explorer-specific actions are folded into the common toolbar as icon-only controls after File/Edit/View/Tools and before Help.

Text viewers are special-purpose text-media windows. They render chunked text from `fs.text.chunk`, map scrollbar position to byte offsets, and save normal-size editable text through `fs.text.save`. Viewer status/errors should surface through the shell toast API instead of persistent footer panels.

Help -> About should open the reusable `about-mioos` window surface so modules can provide context without blocking the user with alert-style notifications.

## Final regression stabilization notes

The New table module flow remains MUMPS-first. A generated table module must provide `componentKey="table"`, `surface="mioos-surface-table"`, and `tableState.config.contract="mioos-advanced-table-v8"`. No frontend framework, build step, or TypeScript is required. Modal styling is shared by `.mioos-table-module-editor` and is dark-theme aware.

Application shortcuts shown in Explorer must include launch metadata (`targetAppKey` / `launchKey`) and icon metadata. Explorer opens those shortcuts through the normal app launcher so Start menu, desktop, and VFS views stay consistent.

## Login/theme/start-menu/text-viewer regression ROI

UI modules should assume unauthenticated boot exposes only the login overlay. Do not mount module windows, desktop shortcuts, Start Menu popups, shell controls, or authenticated asset URLs before `boot.user.authenticated` is true.

Theme Studio now separates **Save** from **Save As / New Theme**. Save updates an active user theme; Save As creates a new user theme; Delete Theme removes only user-created themes. Module examples that reference theming should keep dark-mode CSS variables compatible with titlebar/window-control variables and should not override the dark variant with light-only selectors.

Start Menu groups are collapsible and accessible through the group header button. Module-provided launcher groups should remain safe when hidden by `is-collapsed`; item launch logic must continue to run only from expanded child rows.

## New Table Module flow (ROI 91)

The App Catalogue / UI Modules screen includes **New Table Module** for creating a backend table-backed module without frontend code. The modal keeps required fields visible, validates the draft before preview/save/import, and reports both success and backend validation errors through inline status plus shell toasts.

Saved table modules are normalized by `MIOOSMTBL` before registration:

```mumps
SET DEF("componentKey")="table"
SET DEF("surface")="mioos-surface-table"
SET DEF("tableState","config","contract")="mioos-advanced-table-v8"
```

`SAVE^MIOOSMTBL` stores the definition, installs the generated module manifest under the user module registry, and creates the backend dataset under the table contract. `CATALOG^MIOOSMOD` returns both the generated module entry and `tableDefinitions`, so the module can appear in the catalogue/start menu and launch directly into the table surface.

Required MUMPS-first workflow:

1. Open **Programs → App Catalogue + UI Modules → New Table Module**.
2. Enter a stable key, title, dataset, and columns.
3. Use **Preview** to validate and inspect the generated table query shape.
4. Use **Save and register** to install the module and dataset.
5. Launch the generated module from the catalogue/start menu; no Vue component or frontend file is required.

## ROI 92 shell UI regression contract

UI modules should rely on the shared window toolbar and taskbar contracts instead of creating duplicate action panels. Toolbar/dropdown command clicks, including keyboard activation, dismiss the open menu. Custom module menu items should be ordinary toolbar commands so they inherit dark contrast and dismissal behavior.

Notifications and module toasts should inherit the global `--font-size-ui` variable. Do not add fixed notification font-size overrides that bypass Theme Studio global font scaling.

Module windows automatically participate in the taskbar open/focused/minimized class model. File viewer windows and generated table windows should continue to launch through the normal window manager so pinned-only apps, inactive open windows, and active windows remain visually distinct. On mobile, keep scrollable content inside `.mioos-window-content-vue` or the existing surface scroll containers so titlebar touch drag does not hijack content scrolling.

## ROI 95/96 text editor module note

Text/structured file windows now prefer the local CodeMirror helper for small and medium documents while preserving the same MIOOS toolbar contract. Modules should not add CDN CodeMirror URLs, npm packages, build steps, or custom unsupported modes. Use the existing text viewer actions for Edit, Save, Zoom, Toggle Line Wrap, and Refresh; large text files remain chunked read-only unless a future ROI adds backend-tested partial-edit semantics.

## ROI 97 viewer and login-theme module notes

File modules should treat Markdown, HTML, PDF, and large text as viewer capabilities rather than direct blob reads. `.md` files default to a local Marked rendered preview and use CodeMirror only when the user enters edit mode and the file is below the full edit-on-demand limit. `.html` and `.htm` files render in sandboxed iframe preview mode without scripts; `.pdf` files use the browser-native PDF renderer via the authenticated local blob route. Large text-like files open in HTTP chunked view mode and must not request `/api/mioos/fs/blob` for full-file content; choosing Edit stitches chunks into the editor.

The theme editor separates common pre-login theme settings from login-specific settings. Common settings are safe before username entry; login-specific avatar/warning/CSS loads only after the username stage and is cleared when the username changes.


## ROI 98 UI notes

Dark-mode Theme Studio clear/neutral buttons now use scoped `data-theme-editor-secondary` selectors and keep `#004cff` text with accessible hover/focus-visible states. Read-only table presentations receive dark header/body/hover/selected styling without changing the module author contract or the Advanced Table editable CRUD controls. Markdown and HTML preview panes fill the viewer client area and use the existing viewer Zoom In/Zoom Out controls.


## ROI 99 UI notes

Table-like modules must rely on the shared `mioos-full-table` / `mioos-surface-table` surfaces instead of hardcoded light row backgrounds. Dark Theme readability now covers simple read-only examples, dense operational examples, editable CRUD tables, Patient Registration, and advanced filter/modal inputs through scoped `.theme-dark-mode` table selectors. Do not add global `* { color: white }` rules; use the table variables and classes already present in `public/mioos/mioos.css`.

Login-screen modules and theme examples should keep common pre-login visuals separate from username-stage visuals. Avatar and warning image uploads are persisted as theme assets and exposed pre-auth only through the staged public asset route after the username-stage request.

Text viewer integrations should treat files above the virtualization threshold as HTTP-chunked virtual text until the user chooses Edit. The shared Edit action stitches chunks into the editor on demand; use the existing status/retry affordances rather than background auto-load or retry loops.


## ROI 100 text viewer integration note

Text modules should treat all text-like files as editable. Large files should open first in HTTP chunked view mode, then use the shared **Edit** action to stitch safe chunks into the editor on demand. Do not add module-level full-blob reads or WebSocket-only large-text loaders; use the shell's `/api/mioos/fs/text-chunk` viewer path and chunked HTTP save/upload path.

## ROI 101 UI notes

Table modules should continue to use `mioos-full-table`, `mioos-surface-table`, Advanced Table, and permissions/patient surfaces rather than inline light backgrounds. The shared table variables (`--mioos-table-cell-bg`, `--mioos-table-text-color`, `--mioos-table-input-bg`, `--mioos-table-selected-bg`, and related state variables) now supply Dark Theme readability for cells, headers, hover/selected rows, filter rows, modal controls, editable cells, and validation messages without requiring module-specific CSS.

Text viewer integrations should no longer depend on visible-range or scrollbar-driven loading. The shell opens text files as explicit HTTP chunk load sessions, then shows an editable CodeMirror/plain-text editor when the full buffer has been stitched together safely. Save should use the shared chunked HTTP upload path for non-trivial text and keep the stale modified/size conflict check; do not add DataURL, full-blob, or WebSocket-only text transfer paths.
