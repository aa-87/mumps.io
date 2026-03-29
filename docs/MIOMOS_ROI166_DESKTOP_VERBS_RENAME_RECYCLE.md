# MIOMOS ROI 166 — Desktop Verbs, Rename Parity, and Recycle Bin Routing

## Goal
Move the MIOMOS shell closer to a Windows XP desktop replica by hardening core desktop verbs while keeping the existing websocket event contract and auth/session workflow intact.

## Scope
This ROI focuses on **desktop behavior parity** more than filesystem depth.

Implemented in this ROI:
- XP-style **desktop marquee selection** on blank stage space
- **single-select and multi-select aware** desktop state on the client shell
- **inline rename** for custom desktop folders
- **F2 rename** keyboard behavior for selected custom folders
- **Delete** keyboard/context behavior for custom folders
- custom folder deletion now routes to **Recycle Bin** instead of immediate destruction
- Recycle Bin explorer surface supports:
  - **Restore**
  - **Delete Permanently**
  - **Empty Recycle Bin**
- explorer cards gain selection state and desktop-style verbs
- desktop context menu gains **Arrange Icons by Name**

## Important constraints preserved
This ROI does **not** change:
- auth routes
- sign-in/sign-out workflow
- websocket request/response ownership
- `command.exec` / `command.result` event semantics
- `session.ui.save` transport contract

## Server-authored shell contract additions
The boot/view model now advertises:
- `desktopSelectionExtension = marquee-and-multi-select`
- `renameBehavior = inline-f2-custom-folders`
- `deleteBehavior = recycle-bin-routing`
- `recycleBinModel = soft-delete-custom-folders`

These values let future ROIs build deeper filesystem behavior without guessing what the shell is supposed to do.

## Why this ROI now
Windows XP fidelity depends heavily on tiny desktop verbs:
- selection
- rename
- delete
- restore
- desktop arrangement

Without these, the shell looks XP-inspired but does not yet *feel* like XP. This ROI closes that gap while staying low-risk and mostly shell-local.

## What remains for later ROIs
This ROI is still shell-first. It does **not** yet implement:
- real filesystem persistence for shell objects
- cut/copy/paste semantics
- drag/drop move/copy prompts
- file list view modes/details columns parity
- Control Panel/My Computer drive realism
- MUMPS routine explorer as a full XP file tree analogue

## Next sequence
- **ROI 167 — Explorer file list parity**
- **ROI 168 — Shell drag/drop semantics**
- **ROI 169 — Filesystem bridge over websocket**
- **ROI 170 — XP shell services**
- **ROI 171 — Development-platform essence**
