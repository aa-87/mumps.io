# MIOUI Layout Structures Plan

## Goal

Add reusable layout structures for high-intensive data applications.

The focus is not on lower-level widgets. The focus is on where major surfaces live on the screen:

- queues
- inspectors
- metrics
- traces
- boards
- formulas
- action rails

## ROI 14 surfaces

- Layout mode switcher
- Operator command center layout
- Tri-split queue layout
- Focus inspector layout
- Board + rail layout
- Analytics canvas layout
- Data layouts demo page

## Why this matters

High-volume billing and review products need more than a good table. They need repeatable screen structures that keep context visible while users move quickly.

## Design rules

- Keep the primary data surface obvious
- Keep actions near the current decision
- Keep secondary context in rails, not floating dialogs
- Keep bulk state anchored
- Prefer server-owned navigation and state
- Use consistent inspector placement across pages

## Next layout ROI ideas

- keyboard-first pane focus
- collapsible secondary rails
- responsive density layouts
- mobile fallback shells
- persistent pane ratios
- role-specific layout presets
