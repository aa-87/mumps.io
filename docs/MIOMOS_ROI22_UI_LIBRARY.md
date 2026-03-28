# MIOMOS ROI 22 — UI Library Foundation

This ROI shifts the MIOMOS focus toward a reusable UI library influenced by 7.css while preserving the darker, modern MIOMOS production shell aesthetic.

## Scope
- Add a first-class **UI Library** desktop surface in the MUMPS-authored app and window catalog
- Expand the theme catalog with richer metadata for gallery rendering and future documentation
- Apply theme variables live in the browser from the MUMPS theme catalog instead of treating theme choice as label-only
- Introduce reusable showcase surfaces for buttons, pills, tabs, forms, tables, command patterns, tokens, and theme cards
- Extend smoke tests so the UI library contract is enforced by rendered tokens and boot JSON

## Files changed
- `docs/MIOMOS_ROI22_UI_LIBRARY.md`
- `routines/MIOMOSST.m`
- `routines/MIOMOSUI.m`
- `routines/MIOMOSVM.m`
- `routines/MIOMOSTH.m`
- `routines/MIOMOST.m`
- `templates/layouts/miomos_shell.html`
- `templates/pages/miomos_desktop.html`

## Notes
- The UI library remains SSR-first and MUMPS-authored; Vue only renders and handles interaction state
- Theme application now uses the active theme record to drive CSS variables live at the shell root
- The UI library is designed to become a future source for shared MIOMOS page components beyond the desktop shell
