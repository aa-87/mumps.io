# MIOMIDE Routine Workspace ROI 3

This ROI turns the shell into a more credible routine workspace.

## Delivered

- routine load responses now include `sourceLines`, `lineCount`, `byteCount`, and `checksum`
- save flow now prefers line-array payloads rather than one large source string
- compile flow now supports compile-after-save in a single request
- structured compile diagnostics now flow into the Problems panel
- search results now include line numbers
- percent routines map to underscore-backed source files on disk
- reload and revert actions were added to the editor toolbar and command palette
- dirty-tab protection now warns before browser unload

## Backend changes

### `MIOMIDEAPI`
- parses request bodies into line arrays
- save endpoint writes routines from `sourceLines`
- compile endpoint can auto-save before compile
- compile failures return structured problem payloads

### `MIOMIDERT`
- load returns line-oriented metadata
- save writes line arrays safely
- compile parses `$ZSTATUS` into Problems-panel diagnostics
- search is line-aware
- path resolution supports `%ROUTINE` → `_ROUTINE.m`

## Front-end changes

- editor opens from `sourceLines`
- save sends `sourceLines`
- compile auto-saves current content before linking
- compile failures populate the Problems panel with code and line metadata
- search opens routines and jumps to the matched line
- reload and revert support routine recovery workflows

## Test focus

- route and render smoke coverage remains intact
- boot contract updated to ROI 3
- routine load/save/compile helper coverage added
- compile diagnostic parsing is validated from a representative `$ZSTATUS`
