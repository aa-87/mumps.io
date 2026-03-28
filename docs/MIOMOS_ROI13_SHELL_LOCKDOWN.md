
# MIOMOS ROI 13 — Shell cleanup, semantic desktop entries, and production UX lock

This ROI removes the extra top bar, simplifies the shell to a single taskbar + single menu model, and makes desktop entries semantic.

## Goals
- remove the top bar regression entirely
- keep one taskbar and one menu only
- make desktop/menu entries clearly represent applications, settings, directories, and future planned surfaces
- preserve the MUMPS-first contract while keeping Vue a thin render layer
- keep the current passing test surface intact and add targeted render checks for semantic entry kinds

## Changed files
- `routines/MIOMOSST.m`
- `routines/MIOMOST.m`
- `templates/layouts/miomos_shell.html`
- `templates/pages/miomos_desktop.html`

## Highlights
- top bar removed from rendered desktop markup
- taskbar remains the sole persistent shell control strip
- menu is grouped into Applications, Directories, System, and Future
- desktop entries now advertise `data-entry-kind` values such as `app`, `settings`, `directory`, and `future`
- directory entries route into existing production windows instead of inventing untested new windows
- future entries render as disabled planned placeholders instead of looking broken
- motion polish added through CSS transitions keyed off the existing motion profile contract

## Contract notes
- MUMPS still authors desktop apps metadata in `BOOTARY^MIOMOSST`
- Vue only reads the boot/view model and performs window/menu interaction locally
- the existing terminal contract and security/admin routes remain unchanged

## Test intent
- preserve the existing ROI 12 passing tests
- add render checks for directory and future desktop entry kinds
- keep the terminal app index unchanged so older tests continue to pass
