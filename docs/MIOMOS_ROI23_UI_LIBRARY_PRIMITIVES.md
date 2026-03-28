# MIOMOS ROI 23 — UI Library Primitives

## Goal
Turn the ROI 22 UI Library from a showcase into a reusable component foundation shaped by **7.css chrome** and a more modern **MIOMOS production aesthetic**.

## What changed
- expanded the server-authored `view.uiLibrary` model with:
  - toolbar actions
  - breadcrumbs
  - segmented tabs
  - richer form states
  - selects and textareas
  - toggles, checks, and radios
  - dense data grid metadata
  - empty-state guidance
  - cards/panels
  - drawers, dialogs, and toasts
  - stepper and tree patterns
  - menu groups
  - token extensions
- extended the theme catalog with additional shell/UI variables:
  - `surfaceSoft`
  - `toolbar`
  - `panelInset`
  - `inputBg`
  - `shadowSoft`
  - `focusRing`
  - `radiusMd` / `radiusLg` / `radiusXl`
- added the **Graphite Clinic** theme pack
- made the browser shell apply those new theme variables as CSS custom properties
- updated the UI Library window to render the new primitives with stronger data attributes for test coverage
- expanded `MIOMOST` smoke coverage for the UI Library render contract

## Design intent
The UI library should feel:
- dense but readable
- 7.css-informed, not nostalgic
- fit for healthcare/operations work
- calm in default state
- high-signal under focus, validation, and status changes

## Result
MIOMOS now has a clearer design-system baseline that can be reused in:
- the desktop shell
- future MIOMOS apps
- ordinary SSR pages outside the desktop
