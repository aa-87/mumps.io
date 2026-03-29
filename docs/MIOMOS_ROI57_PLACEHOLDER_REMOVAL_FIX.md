MIOMOS ROI57 placeholder removal fix

This patch removes the remaining placeholder-only desktop entries and the planned surfaces section from the desktop template.

Files:
- routines/MIOMOSST.m
- templates/pages/miomos_desktop.html

Fixes:
- removes data-entry-kind="future" from the rendered desktop entry set
- removes the "Planned surfaces" SSR block
