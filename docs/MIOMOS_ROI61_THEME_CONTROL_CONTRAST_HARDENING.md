# MIOMOS ROI61 — Theme Control Contrast Hardening

This ROI continues the shell CSS hardening work with a narrow focus on theme control legibility.

## Changes
- Dark theme form controls now render as dark surfaces with light text.
- Dark theme placeholders and select options are brightened for readability.
- Light theme gray button text is forced to near-black across taskbar, menu, dialog, quick launch, and shell action buttons.
- Muted supporting text in the light theme is darkened further so it remains legible on bright surfaces.
- Runtime theme application now also binds `data-theme-key` to the root shell node, allowing theme-specific CSS targeting.

## Scope
Template/CSS-first hardening only. No changes to websocket, auth, or terminal ownership behavior.
