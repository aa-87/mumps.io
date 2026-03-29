# MIOMOS ROI37 Terminal Palette Restore

This patch restores the terminal palette selector after the cursor-fix pass.

## What changed
- Added persisted terminal preference: `terminal.palette`
- Added catalog options: `Midnight Blue`, `Black on White`, `White on Black`
- Restored the Settings -> Terminal selector for palette choice
- Wired xterm theme colors to the selected terminal palette
- Added smoke coverage so the palette selector and catalog do not disappear again
