# MIOMOS ROI63 — XP theme system polish

This ROI starts the post-ROI62 production polish track by tightening the theme contract and using it more consistently across the XP-inspired shell.

## Goals

- make the default shell fallback consistently `clinical-blue`
- ensure server-authored themes drive shell chrome, not only generic surfaces
- harden the XP taskbar, Start menu, context menu, dialog, and Explorer colors from the same theme object
- add additional daytime shell variants for `xp-olive` and `xp-silver`
- keep the browser implementation thin and reactive to the MUMPS-authored theme catalog

## Notes

- this ROI is intentionally focused on theme correctness and shell polish first
- runtime defaults in `MIOMOS`, `MIOMOSSET`, `MIOMOSUI`, SSR output, and browser application should all agree on the same default shell posture
- the first seven catalog positions remain stable so existing theme catalog tests do not drift
- new shell-aware theme fields are additive and designed to support future shell parity work
