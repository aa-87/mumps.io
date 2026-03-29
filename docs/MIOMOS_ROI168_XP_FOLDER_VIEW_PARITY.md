# MIOMOS ROI 168 — XP Folder View Parity

## Goal

Push MIOMOS Explorer windows much closer to the Windows XP folder experience while preserving the current websocket shell, auth flow, and restored multi-window terminal behavior.

This ROI focuses on the **folder-view shell layer**:

- XP-like Explorer framing
- large-icon default view
- view switching
- sortable file/folder presentation
- manual drag placement in icon views
- persisted explorer view/layout preferences through the existing layout save path

## What changed

### Server-authored desktop contract

`MIOMOSST` now publishes Explorer defaults as part of boot metadata:

- `explorerStyle = winxp-shell-folder`
- `explorerDefaultView = large-icons`
- `explorerViewModes = thumbnails,tiles,large-icons,icons,list,details`
- `explorerDefaultSort = name`
- `explorerSortModel = name-size-type-modified`
- `explorerLayoutBehavior = manual-drag-with-arrange-icons`
- `explorerReplicaTarget = windows-xp-folder-view`

`MIOMOSVM` now exposes matching shell metadata and copy so future Explorer/tooling ROIs can stay server-authored rather than drifting into browser-only behavior.

### XP-style folder windows

Directory windows now render as an XP-style Explorer surface with:

- toolbar row
- address bar row
- left Common Tasks / Other Places / Details pane
- icon canvas for icon-style views
- list/details alternatives
- bottom status bar

### View switching

Folder windows now support:

- Thumbnails
- Tiles
- Large Icons
- Icons
- List
- Details

The default is **Large Icons** to better match the XP familiarity goal.

### Sorting and arrangement

Folder windows can now sort and arrange by:

- Name
- Size
- Type
- Modified

Icon-style views also support **Arrange Icons** to snap items back to a sorted grid.

### Draggable icon placement

In icon-style views, folder items can now be dragged to manual positions inside the Explorer surface.

This is persisted through the existing layout save path by extending the saved layout object with:

- `explorerPrefs`
- `explorerIconPositions`

## Explicit non-goals for this ROI

This ROI does **not** yet implement:

- real browser file upload/drop into the VFS
- browser download / drag-out bridge
- rename/delete/cut/copy/paste parity inside Explorer lists
- true filesystem mutation over websocket
- full XP shell services like My Computer task panes, file associations, or a Run-aware file execution model

Those belong to the next wave.

## Next ROI sequence

### ROI 169 — Shell drag/drop semantics

- drag selection polish inside folder views
- desktop ↔ folder drag semantics
- hover targets and insertion cues
- no real file transfer yet

### ROI 170 — Filesystem bridge over websocket

- websocket commands for VFS enumeration/mutation
- create, rename, delete, move
- upload-intent handshake and permission checks

### ROI 171 — XP shell services

- common file verbs
- association-aware open actions
- richer My Computer / My Documents / Recycle Bin behavior
- shell copy aligned with XP familiarity

### ROI 172 — MUMPS development-platform essence under the XP shell

- Routine Explorer
- Globals Browser
- drag/drop development artifacts inside the VFS
- terminal / routine / globals workflows that feel native to MIOMOS

## Notes

- Terminal multi-window launch behavior remains unchanged.
- Auth/sign-in/sign-out workflows remain untouched.
- Websocket ownership remains untouched.
- Layout persistence continues to use the existing `layout.save` contract.
