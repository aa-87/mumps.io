# MIOMIDE ROI 5 — VS Code-like workbench revamp

This ROI hardens the browser IDE shell so it behaves much closer to VS Code during day-to-day routine work.

## Focus areas

1. **Editor tabs closer to VS Code**
   - drag and drop tab reordering
   - active/inactive tab styling closer to a professional IDE
   - right-click tab context menu
   - close, close others, close to the right, close saved, close all

2. **Terminal stabilization**
   - browser-stable `terminalClientId`
   - reconnect flow that reuses or re-establishes the terminal session cleanly
   - bounded websocket drain reads
   - explicit close/reconnect lifecycle actions in the panel toolbar

3. **Workbench layout fix**
   - replaces the fragile collapsed-grid approach with a cleaner split-view workbench
   - sidebar hide/show no longer leaves the editor area in a broken intermediate state
   - sidebar and panel resizers remain consistent with the visible layout

## Backend changes

- `MIOMIDEST` boot payload updated to `roi5-vscode-workbench`
- new layout metadata for tab sizing
- new capability flags for tab reorder and tab context menu
- command palette entries aligned to the new tab and terminal actions
- `MIOMIDETM` terminal bridge updated to use:
  - `readLimit`
  - `readPolls`
  - `drainPause`

## Frontend changes

- VS Code-like workbench shell and chrome
- drag/drop tab strip
- tab context menu overlay
- persistent sidebar/panel/theme/workspace state
- terminal toolbar and session status UI
- command palette and quick open overlays integrated into the workbench flow

## Test coverage

Smoke coverage validates:

- SSR render tokens for the updated workbench
- tab strip and tab context menu markers
- terminal reconnect markers
- boot payload version, layout, capabilities, and commands
- routine workspace save/compile round-trip
- terminal metadata helpers
