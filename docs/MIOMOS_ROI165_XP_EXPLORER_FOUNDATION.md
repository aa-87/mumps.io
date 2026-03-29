# MIOMOS ROI 165 — XP Explorer Foundation

## Goal

Advance MIOMOS toward a Windows XP replica without destabilizing auth, session ownership, or the existing websocket contract.

This ROI is intentionally shell-focused and additive. It does **not** change sign-in/sign-out, route ownership, or the existing command bus design.

## Scope

- add XP system desktop icons: **My Computer**, **My Documents**, **My Network Places**, and **Recycle Bin**
- change desktop icon behavior to XP-style **single-click select, double-click open**
- upgrade directory windows into XP-like explorer windows with:
  - toolbar
  - address bar
  - left common-tasks pane
  - status strip
- add desktop drag/drop targets so icons can be dropped onto:
  - desktop folder icons
  - open directory windows
- persist folder membership inside the existing layout-save channel

## Why this ROI first

A convincing XP replica depends on shell structure before deeper filesystem work. Users need to see and feel the right desktop affordances before copy/move/delete/upload semantics are added.

This ROI therefore focuses on:

- **shape** of the XP shell
- **interaction model** for desktop icons
- **explorer framing** for folder windows
- **safe persisted drag/drop metadata** using the already working layout-save path

## Explicit non-goals

- real filesystem copy/move/delete
- recycle-bin restore semantics
- full explorer column/list/details views
- shell file associations
- shell rename/delete verbs beyond the current folder workflows

Those are staged for later ROIs.

## Contracts added

### SSR tokens

- `data-shell-replica="windows-xp"`
- `data-xp-explorer="1"`
- `data-xp-common-tasks="1"`
- `data-xp-address-bar="1"`
- `data-drop-mode="desktop-to-folder"`

### Boot JSON metadata

Under `desktop`:

- `replicaModel=windows-xp-development-platform`
- `xpReplica=1`
- `explorerStyle=xp-classic`
- `desktopSelectionModel=single-click-select-double-click-open`
- `dragDropModel=desktop-icons-to-folders`
- `folderWindowModel=explorer-left-pane-address-status`

## ROI 166+ sequence

- ROI 166 — desktop verbs and rename parity
- ROI 167 — explorer file list parity
- ROI 168 — shell drag/drop semantics
- ROI 169 — filesystem bridge over websocket
- ROI 170 — XP shell services
- ROI 171 — development-platform essence
