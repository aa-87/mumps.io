# MIOMOS ROI59 — Theme contrast and sensible defaults

## Goal
Tighten the MIOMOS theme system so light themes are first-class, shell contrast stays readable, theme-specific fonts are respected, and defaults are sensible for a production desktop shell.

## Delivered
- Added XP Classic Blue, XP Classic Olive, and XP Classic Silver themes
- Added theme-specific font family and size metadata
- Updated settings defaults to prefer an XP-classic light shell and multi-session terminal launches
- Added a full authored shell CSS layer driven by theme variables
- Strengthened light-theme contrast for taskbar, flyouts, forms, windows, pills, and tables
- Made theme-backed terminal colors follow the current light/dark shell mode more closely

## Guardrails
- Keep MUMPS as the source of truth for theme catalog and defaults
- Do not reintroduce white-on-white field or tray text in light themes
- Keep theme runtime controlled through `MIOMOSTH`, `MIOMOSSET`, and the desktop shell boot/view contract
