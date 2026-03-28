# MIOMOS ROI33 — Shell navigation, start search, and taskbar overflow

This ROI continues the native MIOMOS shell and focuses on deterministic taskbar and Start-menu behavior.

## Goals

- Keep taskbar ordering stable while the focused window changes
- Prevent crowded taskbars from collapsing into unreadable buttons
- Make Start useful as a launcher with one search field
- Improve keyboard correctness without introducing heavy client dependencies

## What changed

### 1) Taskbar overflow without reorder

The shell now computes a visible task-button budget from the viewport width. Hidden task buttons are moved into a **More Windows** overflow surface instead of being re-ordered or squeezed into unreadable widths.

### 2) Start search

The Start menu now includes a single search field that filters:

- applications
- directory-style entries
- shell actions such as Tile, Cascade, Run, and Focus Terminal

Pressing `Enter` launches the first match.

### 3) Recent launches

The shell now tracks recently launched entries in local browser state so the Start menu can show a compact **Recently used** surface.

### 4) Keyboard model

The shell now advertises and implements:

- `Ctrl+Escape` opens the Start menu
- `Enter` launches the first search result when Start search is active
- `Escape` clears the current search before closing the Start menu

### 5) MUMPS-backed UI state

The session UI state now persists `startMenuQuery` alongside the existing Start section and active-window metadata.

## Files touched

- `routines/MIOMOSST.m`
- `routines/MIOMOSVM.m`
- `routines/MIOMOST.m`
- `templates/layouts/miomos_shell.html`
- `templates/pages/miomos_desktop.html`
- `miomos_llm.md`

## Notes for future ROI work

- A future ROI can add grouped taskbar buttons, but group order must still remain stable
- Start search should remain client-thin and server-compatible
- Any richer launcher model should remain test-backed with SSR-visible contract tokens
