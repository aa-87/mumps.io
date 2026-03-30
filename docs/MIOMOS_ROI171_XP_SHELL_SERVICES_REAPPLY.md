# MIOMOS ROI 171 — XP shell services (reapply)

This ROI reapplies XP shell services on top of the reverted, passing XP-shell baseline without regressing Explorer styling or the current file-drop behavior.

## Scope
- Add server-authored shell-service contract metadata
- Keep system places centered on:
  - My Computer
  - My Documents
  - My Network Places
  - Recycle Bin
- Add side-pane actions for common shell services:
  - New Folder
  - Rename
  - Delete
  - Create Shortcut
  - Restore from Recycle Bin
  - Empty Recycle Bin

## Implementation notes
- Recycle Bin is implemented as a soft-delete target inside the per-user globals-backed VFS
- Shortcut creation is materialized in the VFS as `.lnk`-style shell entries
- Terminal multi-window launch remains unchanged
- XP Explorer view switching and drag/drop styling remain unchanged
