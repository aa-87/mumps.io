# MIOMOS ROI 170 — Filesystem bridge over websocket

## Goal
Move the XP-shell virtual filesystem from layout-preview-only behavior into real-time MUMPS-owned mutation over the existing `command.exec` websocket bus.

## Scope
- Keep the current multi-window terminal behavior intact.
- Preserve the existing authenticated HTTP upload route for native browser file drops.
- Add websocket-backed VFS enumerate/mutate commands:
  - `vfs.list`
  - `vfs.mkdir`
  - `vfs.rename`
  - `vfs.delete`
  - `vfs.move`
- Surface the bridge in Explorer with XP-style task links and toolbar actions.
- Keep all new UI following active system font family and font size automatically.

## Server changes
- Added VFS command handlers in `MIOMOSCMD`.
- Expanded `MIOMOSVFS` with:
  - folder enumeration
  - mutable-folder creation
  - rename
  - delete
  - move
  - parent/root validation
  - recursive path rebuilds for nested virtual folders
- Added bridge metadata to boot/view contracts.

## Client changes
- Explorer windows now advertise the websocket VFS bridge contract in SSR.
- Explorer can now request live folder refresh over websocket.
- Explorer exposes XP-style folder tasks for:
  - New Folder
  - Rename Selection
  - Delete Selection
  - Refresh Folder
- VFS item move drag/drop now uses websocket mutation for `move` operations.
- Copy and shortcut remain progressive shell-side behavior until a later ROI expands them into full VFS duplication/link services.

## Notes
- Browser file upload remains HTTP because native `File` objects are still best handled with multipart upload; this ROI makes the folder model and folder mutations websocket-native while keeping upload stable.
- The next ROI should build XP shell services and browser download/open behavior on top of this bridge.
