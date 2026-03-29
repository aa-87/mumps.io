# MIOMOS ROI60: Theme Legibility Hardening

This ROI hardens shell contrast at the theme-token and authored-CSS levels.

## Goals
- eliminate white-on-white and low-contrast gray-on-gray states
- improve muted copy legibility in both light and dark themes
- make shell surfaces usable before runtime theme variables are applied
- set a more sensible default theme for daytime shell use

## Changes
- inserted a full authored `miomosThemeSystem` CSS layer into `templates/pages/miomos_desktop.html`
- added explicit semantic contrast rules for muted copy, pills, badges, tables, notices, account menu items, and shell metadata
- added `data-theme-key` binding on the root shell element for theme-specific selectors
- made theme application set `--icon` and `data-theme-key`
- strengthened light-theme `muted`, `border`, and `field-border` values
- strengthened dark-theme `muted` and `border` values
- changed theme fallback default from `midnight-professional` to `clinical-blue`
- nudged runtime font fallback toward `Tahoma` for XP-classic readability

## Outcome
The shell now has a complete authored theme CSS layer even before Vue applies runtime theme variables, and gray informational text should remain readable across both light and dark shells.
