# MIOMOS ROI164 — Desktop objects, launch surfaces, and folder workflows

## Objective

Harden the MIOMOS desktop model so desktop entries behave more like first-class OS objects instead of loose client-only tiles. This ROI makes folder creation, rename, delete, and launch flows more deterministic and moves more of the contract into server-authored metadata and websocket commands.

## Scope completed

### 1. Server-authored desktop object metadata

`MIOMOSST` now enriches desktop entries with explicit object metadata, including:

- `objectId`
- `path`
- `renameable`
- `deletable`
- `windowId`
- `openAction`
- `launchSurface`
- `overflowBucket`
- action descriptors for open/rename/delete where appropriate

This makes desktop entries easier to reason about from both the SSR shell and websocket command layer.

### 2. Folder workflow commands over websocket

Added new command handlers in `MIOMOSCMD`:

- `desktop.entry.meta`
- `desktop.folder.prepare`
- `desktop.folder.rename`
- `desktop.folder.delete`

These commands provide a stable shell-facing contract for desktop object inspection and custom folder lifecycle actions.

### 3. Custom folder normalization

Custom folders are now normalized on the server before being reflected back into the shell.

Normalization includes:

- safe title cleanup
- defaulting blank names to `New Folder`
- deterministic `windowId`
- deterministic desktop/window ordering
- explicit folder capabilities

### 4. Rename and delete shell workflows

The shell now supports:

- rename dialog opened directly from desktop object actions
- confirmed delete flow for custom folders
- path display in folder windows
- directory-window actions for rename/delete when the entry supports them

### 5. Overflow and launch-surface contract tokens

SSR now exposes ROI164 contract tokens so `^MIOMOST` can verify:

- desktop object model is server-authored
- folder rename/delete workflows are enabled
- shell action routing is folder-workflow aware
- overflow button exposes an explicit count badge contract

## Key files

- `routines/MIOMOSST.m`
- `routines/MIOMOSCMD.m`
- `routines/MIOMOSVM.m`
- `templates/pages/miomos_desktop.html`
- `routines/MIOMOST.m`

## Testing intent

This ROI extends regression coverage for:

- boot JSON desktop object contract fields
- SSR tokens for folder workflows
- websocket command behavior for folder prepare/rename/delete
- view-model contract exposure for desktop object routing

## Recommended next ROI

### ROI165 — Launcher/search, explorer fidelity, and open-with routing

Suggested next step:

- richer launcher search ranking and keyboard flow
- stronger file/folder explorer fidelity inside directory windows
- open-with routing for terminal/editor/admin surfaces
- better multi-surface launch behavior driven by desktop object metadata
