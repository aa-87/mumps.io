# MIOOS Drag and Drop Rules

## Supported sources
- Desktop icons
- Explorer items
- Valid launcher items inside folder views

## Supported targets
- Explorer/Home folder windows
- Desktop surfaces where shortcut placement is valid
- Upload-capable window surfaces for local file drops

## Behavior
- Default drop in folder window: move
- Ctrl-drop in folder window: copy
- Alt/Meta-drop: reserved for shortcut/link behavior
- App launchers are draggable as shell items but do not yet persist as full file-system entries

## Requirements
- Drag state must remain visible
- Invalid drops must fail safely with user feedback
- Folder permissions must still be enforced on drop commands
- Audit hooks should exist for sensitive move/copy operations in regulated deployments