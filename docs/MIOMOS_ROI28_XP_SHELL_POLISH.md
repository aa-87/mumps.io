# MIOMOS ROI28 — WinXP shell polish and shell dialogs

## Goal
Deepen the MIOMOS native Vue/CSS shell with a more complete WinXP-inspired shell experience while keeping MUMPS as the source of truth for shell metadata and UI contract state.

## Focus
- refine taskbar chrome into a clearer Start / Quick Launch / taskband / tray composition
- add an XP-style Start menu footer
- add shell dialogs for **Run**, **About MIOMOS**, and **Turn Off Computer**
- expose shell chrome metadata through the MIOMOS view model
- extend smoke tests for taskbar, tray, and shell-dialog contract tokens

## Files changed
- `routines/MIOMOSST.m`
- `routines/MIOMOSVM.m`
- `routines/MIOMOST.m`
- `templates/layouts/miomos_shell.html`
- `templates/pages/miomos_desktop.html`
- `miomos_llm.md`

## Notes
This ROI stays deliberately UI/UX centric. It does not add new backend transport or auth scope. It focuses on shell polish, consistency, and test-backed render correctness.
