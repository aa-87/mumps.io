# MIOMOS ROI34 — Product shell folders and desktop correctness

This ROI shifts MIOMOS further from a shell concept toward a product-grade desktop surface.

## Goals

- make shell dialogs behave more like real desktop dialogs
- add a desktop context menu with **New Folder**
- make desktop icons draggable with automatic layout persistence
- curate the root desktop so it presents a product surface instead of a UI lab
- keep the implementation inside the native Vue 3 Options API + CSS shell direction

## What changed

### 1. Draggable shell dialogs

The shell dialogs now expose a title-bar drag contract:

- **Run**
- **About MIOMOS**
- **Turn Off Computer**

Dialog positions are stored in the client layout payload and restored on reload.

### 2. Desktop context menu

The desktop context menu now includes a product-facing **New Folder** action.

The context menu also supports:

- opening the Start menu
- opening the Run dialog
- opening About MIOMOS
- refreshing the desktop
- tiling, minimizing, and restoring windows when appropriate
- power dialog access

Desktop-icon context menus now support:

- **Open**
- **Open Start Menu**
- **New Folder**
- **Delete Folder** for user-created folders

### 3. Draggable desktop icons

Desktop icons are now native MIOMOS shell elements rather than a fixed visual grid.

Behavior:

- root desktop icons can be dragged
- icon positions are saved automatically
- icon layout is restored on reload
- compact/mobile mode falls back to a simpler non-absolute layout

### 4. Curated product desktop

The root desktop is now intentionally restrained.

The root desktop should expose only:

- **UI Samples**
- **Settings**
- **Terminal**
- any folders the user explicitly creates from the desktop context menu

This keeps UI-only and showcase surfaces out of the main desktop while still making them accessible through the **UI Samples** folder.

### 5. UI Samples folder behavior

A first-class **UI Samples** directory now acts as the main curation point for shell/demo surfaces.

Initial contents include:

- UI Library
- Workspace
- Chat
- Security
- Admin

This keeps the product shell cleaner while preserving discovery and future expansion.

## State and persistence

This ROI extends shell layout persistence to include:

- desktop icon positions
- custom folders
- draggable dialog positions
- existing window layout state

The layout payload is still saved locally and sent through the existing layout-save command boundary.

## New shell contract tokens

This ROI adds or enforces the following product-shell signals:

- `data-shell-dialog-drag="1"`
- `data-desktop-folder-create="1"`
- `data-desktop-icons-draggable="1"`
- `data-desktop-curation="ui-samples-settings-terminal"`

Boot contract additions include:

- `dialogBehavior = draggable-shell-dialogs`
- `folderCreateBehavior = desktop-context-menu`
- `desktopIconBehavior = draggable-autosave`
- `desktopComposition = ui-samples-settings-terminal`
- `mutationSaveBehavior = layout-on-shell-mutation`

## Why this ROI matters

This ROI is the first product-shell curation step.

Instead of exposing every surface equally, MIOMOS now starts behaving more like a deliverable workstation product:

- cleaner desktop
- more realistic dialog behavior
- direct desktop actions
- persistent layout expectations
- a place to contain UI-only samples without making the desktop feel noisy

## Recommended next steps

- ROI35: rename/change-icon flows and stronger folder management
- ROI36: deeper product desktop curation and folder view quality
- ROI37: users, roles, permissions, and admin product surfaces
- ROI38: permission-aware launch visibility and enforcement
- ROI39: packaging, install bootstrap, and product documentation
