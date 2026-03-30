# MIOMOS ROI 65 — Tailwind Foundation and Compatibility Shell

## Goal

Introduce a clean Tailwind-oriented styling foundation for MIOMOS **without** changing websocket behavior, VFS behavior, window-manager behavior, or xterm.js rendering.

This ROI is intentionally **non-destructive**.

## Why this ROI exists

The current shell stylesheet has grown large and difficult to reason about. The project needs a cleaner styling architecture, but a direct "delete all CSS and rewrite everything" pass would be too risky for a production-minded desktop shell.

MIOMOS also has shell-specific chrome that Tailwind utilities alone do not model well:

- XP-style taskbar and menu chrome
- title bar chrome
- window control buttons
- resize handles
- explorer/file-shell edge styling
- xterm.js integration details

So the right move is a layered architecture.

## Architecture introduced in ROI 65

MIOMOS shell styling is now split into these layers:

1. `7.scoped.css`
   - preserved as-is for now
   - still available while the shell transitions

2. `miomos_tailwind.css`
   - committed static Tailwind-style foundation
   - preflight/reset
   - theme-token bridge
   - focus treatment
   - starter utility catalog for future template migration

3. `xterm.css`
   - explicitly preserved and left outside the migration
   - must continue to control terminal rendering details

4. `miomos_shell.css`
   - existing legacy shell stylesheet
   - still authoritative for current layout behavior in ROI 65

5. `miomos_chrome.css`
   - new thin compatibility/chrome layer
   - sits after the legacy stylesheet
   - starts moving theme/chrome decisions onto server-authored theme tokens

## What changed in this ROI

- `templates/layouts/miomos_shell.html`
  - now loads the new Tailwind foundation and thin chrome layer
  - keeps `xterm.css` in the stack and does not fold it into the migration
  - advertises the style architecture with a dedicated meta tag

- `public/miomos/miomos_tailwind.css`
  - adds a preflight-style reset
  - adds focus-visible treatment
  - bridges shell theme tokens into a cleaner utility-friendly base
  - provides a starter utility catalog for future MIOMOS markup migration

- `public/miomos/miomos_chrome.css`
  - keeps the file intentionally small
  - maps server-authored theme tokens onto shell chrome
  - starts standardizing active/inactive title bar and shell surface appearance

- `routines/MIOMOST.m`
  - adds render assertions for the new style architecture and asset order

## What this ROI does **not** do

- it does **not** remove the legacy shell stylesheet yet
- it does **not** rewrite all MIOMOS templates to Tailwind classes yet
- it does **not** touch xterm.css
- it does **not** change websocket, VFS, terminal, or state contracts

## Intended next ROI chain

### ROI 66 — Theme Token Rebuild

- normalize shell color slots
- reduce duplicated light/dark theme handling
- drive active/inactive chrome from `MIOMOSTH` more directly
- harden XP taskbar/menu/titlebar contrast

### ROI 67 — Window and Taskbar Chrome Rewrite

- migrate window shell, topbar, taskbar, and launcher toward Tailwind utilities plus thin chrome CSS
- reduce large duplicated blocks in `miomos_shell.css`

### ROI 68 — Explorer and VFS Visual System

- migrate explorer/file-list/folder-view surfaces onto the new styling stack
- preserve all VFS behaviors and tests

### ROI 69 — Controls, Menus, Dialogs, Status Surfaces

- unify buttons, fields, menus, dialogs, and notifications into a compact shell design system

### ROI 70 — Legacy CSS Retirement

- shrink `miomos_shell.css` down to the pieces that still need to exist
- keep only:
  - chrome-specific rules that do not belong in utilities
  - terminal-specific overrides outside `xterm.css`
  - rare shell-edge compatibility rules

## Production posture

The migration strategy is:

- rewrite the **styling architecture** first
- keep the **behavior architecture** stable
- make each visual migration phase test-backed
- avoid destabilizing the realtime shell while modernizing its presentation
