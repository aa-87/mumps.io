# MIOMOS ROI 170 — Filesystem bridge over websocket (reapply)

This ROI reapplies the websocket VFS bridge on top of the reverted, passing XP-shell baseline without changing the Explorer look, theme behavior, or native browser file-drop upload path.

## Scope
- Add VFS mutation commands on the existing `command.exec` websocket bus
- Keep native browser upload on the authenticated HTTP upload route
- Update the browser-side VFS catalog immediately after websocket mutations
- Preserve current Windows XP Explorer chrome and terminal multi-window behavior

## Commands
- `vfs.list`
- `vfs.mkdir`
- `vfs.rename`
- `vfs.delete`
- `vfs.move`
- `vfs.recycle.restore`
- `vfs.recycle.empty`

## Notes
- Existing drag/drop cues remain XP-oriented
- Existing upload prevention of native browser navigation remains intact
- Existing theme inheritance rules remain in force for all new UI additions
