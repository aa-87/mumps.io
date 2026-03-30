# MIOMOS ROI 169 — XP Shell Drag/Drop Semantics

This ROI advances the Windows XP replica track without touching auth or the restored multi-window terminal behavior.

## Goals
- make desktop and Explorer drags feel XP-like
- establish server-authored drag/drop rules before the websocket filesystem bridge
- keep all persistence inside the existing layout save path

## Delivered
- server-authored drag/drop contract in boot JSON and shell view model
- drag cue overlay with XP-style move/copy/shortcut semantics
- desktop folder icons and Explorer directories act as drop targets
- Ctrl => Copy here
- Alt => Create shortcut here
- default => Move here
- VFS item moves are persisted in layout preview state
- shortcut/copy links are staged in layout preview state for folder windows

## Notes
- this ROI deliberately does **not** send real filesystem mutations over websocket yet
- the next ROI should move these staged semantics into a permission-aware websocket VFS bridge
- terminal multi-window launch behavior is unchanged
