# MIOMOS ROI 14 — Window Manager Polish, Motion System, and Production UI Pass

This ROI builds on the passing ROI 13 shell baseline and focuses on production-quality desktop behavior and UI polish rather than adding major new surfaces.

## Goals
- lock down one menu + one taskbar + one shell interaction model
- improve window-manager ergonomics without changing the MUMPS-first contract
- add higher-quality motion and UI rhythm while preserving reduced/off modes
- improve semantic icon treatment for apps, settings, directories, and future placeholders
- keep Vue thin: it renders server-authored metadata and performs client-only layout interactions

## Backend changes
- `MIOMOSWM.m`
  - adds an `operations` window preset
  - expands snap modes to include `grid`
  - adds `polished` motion profile
  - adds `contrast` titlebar style
  - publishes server-authored shell/window actions for the launcher menu
- `MIOMOSST.m`
  - enriches app metadata with more semantic icon defaults and clearer badges
  - includes window-manager actions in the boot payload

## Frontend changes
- launcher menu now includes a **Window tools** section
- new shell actions:
  - Tile windows
  - Cascade windows
  - Minimize all
  - Restore all
  - Focus terminal
- keyboard shortcuts:
  - `Alt+M` menu
  - `Alt+G` tile windows
  - `Alt+C` cascade windows
  - `Alt+N` minimize all
  - `Alt+R` restore all
  - `Alt+T` focus terminal
  - `Alt+1..9` taskbar/window access
  - `Esc` close menu
- quadrant snap preview and commit behavior
- improved titlebar polish and taskbar/menu transitions
- semantic icon styling by entry kind

## UX direction
The desktop now reads more like a real shell:
- directories look distinct from applications
- settings surfaces look distinct from system tools
- planned items are visibly planned/disabled
- window layout tools are first-class and discoverable

## Compatibility
This ROI is designed to preserve the passing ROI 13 smoke-test surface.
