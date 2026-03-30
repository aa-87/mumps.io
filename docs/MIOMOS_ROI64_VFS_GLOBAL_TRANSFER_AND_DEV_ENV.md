# MIOMOS ROI64 — Globals-backed VFS transfer hardening and XP development environment roadmap

This ROI starts the next post-ROI63 track around the virtual file system and the XP-style MUMPS workstation experience.

## Immediate implementation focus

- make the per-user VFS fully globals-backed and self-contained
- expose seeded VFS entries directly in the boot contract so Explorer can render them immediately
- complete the server-side VFS mutation contract already advertised by the websocket command layer:
  - `vfs.list`
  - `vfs.mkdir`
  - `vfs.rename`
  - `vfs.delete`
  - `vfs.move`
  - `vfs.recycle.restore`
  - `vfs.recycle.empty`
- keep browser upload/download flows diskless on the server
- add progressive browser drag-out for downloadable VFS files using the authenticated VFS download route
- add detailed tests for direct VFS operations and websocket command transport

## Why this ROI comes next

The shell already looks closer to a polished XP-inspired desktop, but the development environment is only credible if files behave like a real platform surface.

The repo already had:

- per-user globals-backed VFS seeding
- authenticated upload and download routes
- websocket command names for VFS operations
- Explorer drag/drop semantics on the client

But the core VFS routine was still only partially implementing that contract. This ROI closes that gap so the shell can move from demo-like file affordances to a reliable development workstation foundation.

## Phase roadmap after ROI64

### ROI65 — MUMPS-first file type workflows

- text viewer/editor surface contract
- JSON pretty-view and validation affordances
- CSV preview/table contract
- `.m` routine-aware viewing and future edit hooks
- globals snapshot viewers for `.gbl`
- file associations authored in MUMPS

### ROI66 — XP Explorer parity for developer workflows

- richer file verbs in Explorer and desktop context menus
- selection and multi-select behavior
- copy semantics over the VFS bridge
- shortcut materialization for routine and terminal launch targets
- stronger status and progress cues for upload/download/drag-out

### ROI67 — MUMPS debugger foundation

- server-authored debugger capability contract
- breakpoints, stack, locals, watches, and transcript surfaces
- debugger transport over the existing websocket session
- permission-aware debugger commands and audit events

### ROI68 — Development workspace apps

- Routine Browser app
- Globals Browser app
- Export/Artifact staging app
- workspace links between terminal, files, and debugger

## Test posture

This phase should stay aggressively test-backed.

Add or expand tests for:

- seeded boot VFS metadata and entry counts
- upload sanitization and duplicate-name handling
- direct download from globals-backed blobs
- forbidden upload targets
- move/rename/delete/restore/empty-bin semantics
- websocket `command.exec` coverage for VFS commands
- SSR drag-out tokens for browser progressive enhancement
