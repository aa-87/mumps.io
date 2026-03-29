# MIOMOS ROI 166 — Desktop verbs and rename parity

## Goal
Bring MIOMOS back toward a Windows XP-faithful desktop interaction model without disturbing the restored multi-window terminal behavior.

## Scope in this ROI
- Add XP-style system desktop icons:
  - My Computer
  - My Documents
  - My Network Places
  - Recycle Bin
- Change desktop icon interaction toward XP parity:
  - single-click selects
  - double-click opens
  - marquee selection on blank desktop drag
- Add custom-folder desktop verbs:
  - Rename from context menu
  - F2 rename
  - Delete routes to Recycle Bin
  - Arrange Icons by Name
- Add Recycle Bin shell behavior:
  - Restore
  - Delete Permanently
  - Empty Recycle Bin
- Keep terminal launch and multi-window behavior unchanged.

## Design notes
- This ROI stays mostly in the shell/view layer. It does not alter auth or websocket ownership.
- Deleted desktop folders are soft-deleted into browser/server-backed layout state instead of being hard removed immediately.
- Desktop selection and rename are client-side shell behaviors layered on top of the existing MUMPS-authored entry catalog.

## Follow-on ROIs
- ROI 167 — Explorer file list parity
  - XP-style file list columns
  - icon/list/details view modes
  - sortable headers
  - richer folder metadata and counts
- ROI 168 — Shell drag/drop semantics
  - icon-to-folder moves
  - selection drag ghosts
  - desktop reorder semantics closer to XP
- ROI 169 — Filesystem bridge over websocket
  - MUMPS-authored virtual file operations over websocket commands
  - permission-aware create/move/rename/delete
- ROI 170 — XP shell services
  - My Computer shell service surfaces
  - network places/service shortcuts
  - recycle-bin and explorer service integration
- ROI 171 — MUMPS development-platform essence under the XP shell
  - routine/project folders
  - terminal + explorer + editor workflow cohesion
  - developer-friendly shell affordances over the XP replica
