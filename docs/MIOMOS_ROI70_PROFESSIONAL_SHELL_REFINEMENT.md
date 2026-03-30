# MIOMOS ROI 70 — Professional shell refinement (layout-safe)

## Intent
Revert the aggressive ROI 69 Luna-replica pass and replace it with a safer visual refinement layer that preserves the working ROI 68 layout.

## What changed
- Rebased the shell styling on the ROI 68 CSS baseline.
- Kept the established `xpmsn-reference` shell direction.
- Added a light-touch polish layer only in:
  - `public/miomos/miomos_tailwind.css`
  - `public/miomos/miomos_chrome.css`

## Visual goals
- Cleaner and more professional shell proportions.
- Better surface contrast without over-stylizing the desktop.
- Safer taskbar, window, menu, Explorer, and dialog refinements.
- Preserve functional layout, window sizing, menu structure, and icon flow.

## Constraints preserved
- No DOM or Vue behavior changes.
- No websocket, VFS, terminal, or session behavior changes.
- `xterm.css` remains untouched.
- This ROI is styling-only.

## Follow-up recommendation
Use this as the new stable visual baseline before doing any deeper Explorer/file-type-specific polish.
