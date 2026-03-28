# MIOMIDE Monaco ROI 2

This ROI keeps the now-stable render baseline and improves the editor loop only.

## Included

- Monaco model-per-tab workflow
- Monaco view-state preservation when switching tabs
- toolbar actions for find, replace, go to line, save, compile, reload, and revert
- editor command palette overlay backed by server-provided command metadata
- snippet completion provider for common MUMPS patterns
- problem markers on compile failures using Monaco model markers
- fallback textarea editing if Monaco fails to initialize

## Backend notes

- `MIOIDEST` now publishes editor commands and snippets in the bootstrap payload.
- `MIOIDERT` now returns a `problems` collection when load/save/compile fails so the frontend can surface diagnostics.
- `BOOTOBJ^MIOIDEST` continues to call `$$LIST^MIOIDERT(...)` extrinsically so the prior `NOTEXTRINSIC` issue stays fixed.

## Frontend notes

- The Monaco host remains a dedicated full-height region.
- The layout is unchanged from the working baseline to avoid reintroducing the previous render collapse.
- The output pane can switch between raw output and structured problems.
