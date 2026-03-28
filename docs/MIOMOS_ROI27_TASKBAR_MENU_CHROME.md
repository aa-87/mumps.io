# MIOMOS ROI27 — Taskbar, Menu Button, and Menu Bar Chrome

## Goal

Refine the native Vue/CSS shell chrome so the **taskbar**, **menu button**, **menu bar**, and **button contrast ladder** feel more production-ready and more readable across both dark and light themes.

## What changed

- introduced a compact **shell menu bar** above the desktop stage
- revamped the **taskbar** into a clearer three-zone layout
  - left: strong MIOMOS menu button plus quick utilities
  - center: running window band
  - right: session/status pills and sign out
- added a stronger **menu button** treatment with clearer identity and contrast
- expanded the **button contrast ladder** in the UI Library
  - primary
  - secondary
  - quiet
  - destructive
  - menu
  - utility
- added a **shell chrome showcase** to the UI Library so the new contract is visible and testable
- extended the server boot contract with shell chrome metadata
  - `taskbarStyle=tiered`
  - `menuButtonTone=strong`
  - `menuBarEnabled=1`

## Files touched

- `routines/MIOMOSST.m`
- `routines/MIOMOSVM.m`
- `routines/MIOMOST.m`
- `templates/layouts/miomos_shell.html`
- `templates/pages/miomos_desktop.html`
- `miomos_llm.md`

## Notes

This ROI stays deliberately UI/UX-centric.

It does **not** introduce new backend app behavior. Instead it strengthens the shell chrome as a reusable contract for later desktop and mobile-oriented work.
