# MIOMOS ROI 67 — Tailwind-native shell variants

## Goal
Remove the runtime shell dependency on `7.scoped.css` and the legacy `miomos_shell.css`, then replace the active shell styling path with a cleaner Tailwind-oriented foundation plus a thin MIOMOS-native chrome layer.

## Scope
This ROI does **not** change the websocket, terminal, VFS, or window-manager behavior contracts. It only replaces the loaded shell styling architecture.

## What changed
- `templates/layouts/miomos_shell.html`
  - removed `7.scoped.css`
  - removed `miomos_shell.css`
  - now loads only:
    1. `miomos_tailwind.css`
    2. `xterm.css`
    3. `miomos_chrome.css`
- `public/miomos/miomos_tailwind.css`
  - rewritten into the primary static shell foundation
  - now owns reset, spacing rhythm, layout primitives, dense cards, forms, windows, explorer, dialogs, taskbar, and shell surfaces
- `public/miomos/miomos_chrome.css`
  - rewritten into the XP-inspired chrome layer
  - now owns title bars, start menu chrome, taskbar gradients, active selection treatment, and light/dark shell polish
- `routines/MIOMOSTH.m`
  - theme family labels updated away from 7.css naming
- `routines/MIOMOSUI.m`, `routines/MIOMOSST.m`, `routines/MIOMOSVM.m`, `templates/pages/miomos_desktop.html`
  - user-facing copy updated from “7.css-influenced” to Tailwind-native / MIOMOS-native wording
- `routines/MIOMOST.m`
  - render tests updated to assert the new asset stack and confirm the removed assets are absent

## New shell asset contract
Loaded order:
1. `miomos_tailwind.css`
2. `xterm.css`
3. `miomos_chrome.css`

`xterm.css` remains separate and excluded from the migration so xterm.js keeps its required rendering path.

## Architectural result
The active MIOMOS shell styling model is now:
- **foundation**: `miomos_tailwind.css`
- **terminal vendor layer**: `xterm.css`
- **shell chrome**: `miomos_chrome.css`

No runtime dependency on 7.css remains in the shell layout.
No runtime dependency on `miomos_shell.css` remains in the shell layout.

## Follow-on ROI
Next ROI should refactor the highest-value semantic markup clusters to consume the new shell variants more deliberately, especially:
- Start menu sections
- Explorer toolbar/detail states
- Settings and UI library component showcases
- Taskbar overflow and tray surfaces
