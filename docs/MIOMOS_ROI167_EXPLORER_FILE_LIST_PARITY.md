# MIOMOS ROI 167 — Explorer file list parity

## Goal
Bring MIOMOS directory windows materially closer to Windows XP Explorer details view while preserving the current websocket shell model and the restored multi-window terminal behavior.

## Scope
- Keep auth/session and terminal launch behavior unchanged.
- Seed and expose per-user globals-backed VFS metadata through `MIOMOSVFS`.
- Render Explorer windows with an XP-style frame:
  - toolbar
  - address bar
  - common tasks/details side pane
  - details file list
  - selection-aware status bar
- Support sortable columns: Name, Size, Type, Modified.
- Allow opening VFS-backed child directories in additional Explorer windows.

## Notes
This ROI intentionally stops short of real upload/download transfers. Those remain staged for:
- ROI 168: shell drag/drop semantics
- ROI 169: filesystem bridge over websocket

## Contract
- VFS storage is globals-only and per-user.
- Explorer details view is server-authored in boot/view metadata.
- Files are selection-first for now; browser download flows come later.
