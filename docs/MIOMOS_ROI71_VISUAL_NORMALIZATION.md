# MIOMOS ROI 71 — Visual normalization on the stable ROI 67 baseline

## Goal
Polish the stable ROI 67 shell without changing layout structure, DOM contracts, app wiring, websocket behavior, terminal behavior, or VFS behavior.

This ROI is intentionally **visual-only** and uses the attached ROI 67 package as the source of truth.

## Why this ROI exists
Recent shell styling passes improved ambition but introduced layout regressions. This ROI takes the opposite approach:

- keep the known-good shell structure
- avoid template churn
- avoid JavaScript churn
- avoid route / boot contract churn
- normalize colors, fonts, borders, radii, shadows, and control finish safely

## Files changed
- `public/miomos/miomos_tailwind.css`
- `public/miomos/miomos_chrome.css`
- `docs/MIOMOS_ROI71_VISUAL_NORMALIZATION.md`
- `miomos_llm.md`

## What changed
### Foundation normalization (`miomos_tailwind.css`)
- moved the shell font stack to a safer `Tahoma` / `Segoe UI`-first stack
- tightened radii slightly so the shell feels more deliberate and less inflated
- normalized shadows across windows, cards, menus, dialogs, and explorer panes
- normalized button/input radii and minimum heights
- normalized label/title weights for windows, taskbar items, desktop icons, explorer items, and menu sections
- reduced hover-motion risk by removing transform-based button hover movement on shell controls
- tightened taskbar spacing without changing taskbar behavior
- kept all DOM hooks and existing semantic classes intact

### Chrome normalization (`miomos_chrome.css`)
- reduced the strongest glossy overlays so the shell looks more controlled and less noisy
- normalized window, dialog, start menu, and context menu border/shadow treatment
- normalized card/pane/table-header/explorer surface finish around the theme tokens already emitted by MUMPS
- kept the XP-inspired direction, but made it less fragile and less exaggerated
- added dark-theme-safe finishing so dark palettes stay readable without heavy bloom/gloss

## Explicit non-goals
This ROI does **not**:
- change templates
- change Vue behavior
- change websocket command routing
- change terminal transport or xterm integration
- change VFS semantics
- change tests or render tokens

## Expected result
The shell should feel:
- cleaner
- more professional
- more consistent across windows and surfaces
- more readable in both light and dark themes

without repeating the regressions from the more aggressive restyle passes.

## Suggested follow-on ROI
The next safe visual ROI after this one should focus on **component-level refinement only**, for example:
- explorer toolbar / details polish
- settings/control density polish
- dialog/menu spacing polish

But it should continue to avoid structural layout rewrites unless a dedicated test-backed ROI is planned.
