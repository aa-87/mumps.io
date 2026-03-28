# MIOMOS ROI27 — WinXP Shell Chrome

## Goal

Redo the previous shell-chrome ROI with a clearer direction: make the **taskbar**, **Start menu**, and **context menus** feel recognizably **Windows XP inspired** while keeping MIOMOS native, SSR-first, and MUMPS-owned.

## What changed

- The bottom taskbar now uses an XP-like blue bar, green Start button, task band, quick-launch strip, and tray region.
- The launcher is re-framed as a Start menu with a blue header, white primary pane, and warm utility side rail.
- Desktop and window right-click context menus now exist in the native Vue/CSS shell.
- Hidden shell-contract tokens were added so render tests can assert the XP chrome posture directly.
- Boot metadata now exposes `desktop.shellChrome = winxp-inspired` and `desktop.contextMenuStyle = winxp`.

## UX intent

This is not a nostalgia gimmick. The point of the XP influence is to improve:

- recognizability
- button affordance
- task switching clarity
- menu scannability
- contrast around shell controls

MIOMOS still keeps its own spacing, typography, state model, permissions, and SSR/MUMPS contract.

## Deferred

- richer tray interactions
- keyboard navigation within context menus
- deeper per-window app menus
- explorer-like desktop selection states
- mobile adaptation of Start and context menus
