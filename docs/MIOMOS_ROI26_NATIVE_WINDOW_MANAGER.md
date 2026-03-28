# MIOMOS ROI26 — Native Window Manager Foundation

## Goal

Replace the remaining OS.js bridge posture with a first-class **MIOMOS-native Vue/CSS window manager foundation** while keeping MUMPS and SSR as the source of truth.

This ROI does not attempt to redesign every surface. It formalizes the shell contract so future ROIs can keep improving UI correctness, mobile behavior, menus, dialogs, and accessibility without carrying an OS.js dependency that MIOMOS is no longer meaningfully using.

## What changed

### Boot contract

`MIOMOSST` now emits a native shell contract:

- `desktop.engine = miomos-native-vue-css`
- `desktop.nativeShell = 1`
- `desktop.osjsEnabled = 0`
- `desktop.uiState.*` values are included in boot data for initial restore

The product version advances to:

- `roi26-native-window-manager-foundation`

### Window manager catalog

`MIOMOSWM` now describes the shell as a native window manager with metadata for:

- platform
- drag model
- resize model
- stack model
- restore policy
- mobile strategy
- native capabilities catalog

It also adds keyboard-focus actions:

- `focusNext`
- `focusPrev`

### View-model contract

`MIOMOSVM` now explicitly describes the shell as native and server-backed.

The UI Library view-model includes a new native window manager section covering:

- native Vue/CSS shell
- server-backed UI state
- mobile-friendly windowing

### Browser shell

The desktop page now:

- emits explicit native-shell SSR tokens
- removes the remaining OS.js dependency assumption
- initializes menu/window state from server boot data
- persists UI state locally and queues server-backed `session.ui.save` updates
- keeps the terminal and layout flows intact

### Layout shell

The shell layout no longer loads the OS.js client script.

This keeps the browser runtime focused on:

- Vue 3 UMD
- CSS window chrome
- xterm.js
- MIOMOS command + websocket transport

## Why this ROI matters

MIOMOS was already functionally operating as a native shell. The OS.js bridge label had become misleading and added mental overhead without delivering real product value.

This ROI makes the architecture honest:

- MUMPS owns the contract
- Vue renders and coordinates interaction
- CSS provides windowing and chrome
- websocket/HTTP remain transport layers
- no external desktop runtime is pretending to be the platform

## Deferred to later ROIs

This ROI intentionally does **not** finish everything.

Still to come:

- richer context menus and menu bars
- keyboard accessibility expansion
- better mobile task switching
- dialog/toast unification
- snap presets and docking refinement
- smoother drag/resize polish
- deeper server persistence of per-window state

## Testing posture

Updated smoke tests now assert:

- native shell SSR tokens render
- OS.js script is absent
- native boot engine values are present
- native window-manager catalog entries exist
- native window-manager view-model values are emitted
