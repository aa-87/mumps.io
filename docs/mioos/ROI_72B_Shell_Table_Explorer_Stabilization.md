# ROI 72B — Shell, Table Editing, Explorer Menu, and Task Manager Stabilization

ROI 72B is a regression-hardening pass before the deeper Terminal rewrite sequence.

## Implemented scope

- Rebuilt the Start Menu around a dense table-like menu surface so it can handle large launcher sets.
- Restored explicit Start Menu entry points for Folder Explorer, My Computer, Documents, Theme Studio, Language shortcuts, themes, App Catalogue, and system tools.
- Added shell-modal input/confirmation dialogs so Explorer and Desktop operations no longer use native JavaScript prompts for New Folder, Rename, Delete, and similar actions.
- Added common Explorer window menus for File, Edit, View, Tools, and Help with shared action dispatch.
- Updated Explorer Details view to share the simple table visual controller used by table-like shell views.
- Added VFS item drag payloads so desktop icons and Explorer icons/details rows can move files/folders between folders and the desktop.
- Kept minimized windows mounted off-screen so media viewers do not stop playback when minimized.
- Added taskbar hover previews for open windows.
- Added a first-pass internal Task Manager shell surface for open windows, desktop VFS count, and browser heap snapshot. Backend/session/error charts are planned as dedicated follow-up ROIs.
- Added a cell-edit context menu with Cut, Copy, and Paste so right-clicking an active cell editor no longer opens the desktop context menu.
- Added automatic selection of newly added select/multiselect options in table cell/row editors.
- Locked Patient Registration `status` editing to row actions by making the status column non-editable; users must use Mark active/inactive/review actions.

## Follow-up ROI plan: Terminal rewrite

### Terminal ROI T1 — Transport and process foundation

Rewrite terminal session transport around a dedicated server-side terminal broker with immediate socket/pipe behavior, session lifecycle tracking, reconnect support, backpressure, and deterministic errors.

### Terminal ROI T2 — Profiles and customization

Add terminal profiles for font family, font size, background, text color, cursor, scrollback, startup folder, and runtime shell/routine selection.

### Terminal ROI T3 — Startup automation sequences

Allow terminal shortcuts to define a profile plus startup routine and timed input sequence for automating MUMPS terminal programs.

### Terminal ROI T4 — Hardening and multi-session operations

Add multi-terminal launch, session cloning, detach/reattach, auditing, permissions, and regression tests.

## Follow-up ROI plan: Task Manager

### Task Manager ROI M1 — Server metrics contract

Add MUMPS endpoints for VFS size, session counts, server errors, user sessions, and per-window/session activity.

### Task Manager ROI M2 — Charts and monitoring UI

Add compact charts for memory, VFS size, transfer activity, socket health, server errors, and active sessions.

### Task Manager ROI M3 — Admin session visibility

Show all sessions for admins while preserving user-only visibility for normal users.

## Validation

Run:

```bash
node --check public/mioos/app/mioos_core.js
node --check public/mioos/app/mioos_shell_ui.js
node --check public/mioos/app/mioos_explorer.js
node --check public/mioos/app/mioos_table.js
node --check public/mioos/app/mioos_wm.js
```

In YottaDB / GT.M:

```mumps
ZLINK "MIOOST"
ZLINK "MIOOSPAT"
D ^MIOOST
```
