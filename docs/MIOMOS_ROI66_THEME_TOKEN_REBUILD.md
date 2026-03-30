# MIOMOS ROI 66 — Theme Token Rebuild

## Goal

Normalize the MIOMOS shell color system into a small, explicit token family so the XP-style desktop chrome can be themed cleanly without relying on large blocks of mode-specific CSS overrides.

This ROI builds directly on ROI 65.

## What changed

### 1. `MIOMOSTH.m` now authors a fuller theme contract

The theme catalog still exposes the original MIOMOS theme fields:

- `accent`
- `accentSoft`
- `accentStrong`
- `desktop`
- `surface`
- `surfaceAlt`
- `surfaceSoft`
- `border`
- `text`
- `muted`
- `titleActive`
- `titleInactive`
- `shadow`

But each theme now also publishes a normalized shell-token family for chrome and controls:

- `chromeVariant`
- `desktopHighlight`
- `desktopGlow`
- `topbarStart`, `topbarEnd`, `topbarBorder`
- `taskbarStart`, `taskbarEnd`, `taskbarBorder`
- `taskbarText`, `taskbarTextMuted`
- `taskbandFace`, `taskbandFaceActive`, `taskbandBorder`
- `startMenuStart`, `startMenuEnd`, `startMenuBorder`
- `startBannerStart`, `startBannerEnd`, `startBannerText`
- `menuText`
- `titleTextActive`, `titleTextInactive`, `titleGlow`
- `buttonFace`, `buttonFaceAlt`, `buttonBorder`, `buttonText`
- `inputFace`, `inputBorder`, `inputText`
- `selectionFill`, `selectionBorder`, `selectionText`
- `focusRing`, `focusRingInset`
- `shadowSoft`

### 2. `miomos_desktop.js` applies the token family directly to the root

The Vue shell runtime now maps the normalized theme fields onto CSS variables on `#miomosRoot`, including:

- title text tokens
- XP taskbar tokens
- start-menu banner tokens
- button and input tokens
- selection and focus tokens
- soft shadow token

It also now publishes:

- `data-theme-chrome`
- `data-theme-variant`

on the shell root for future CSS refinement.

### 3. `miomos_tailwind.css` now uses the token family

The Tailwind foundation layer now uses the normalized theme tokens for:

- focus rings
- ring inset color
- selection background
- selection text

This removes the need for the old special-cased light/dark focus styling block.

### 4. `miomos_chrome.css` now drives shell chrome from tokens

The thin chrome layer now consumes the normalized tokens for:

- topbar
- taskbar
- active/inactive title bars
- task buttons
- start menu and context surfaces
- XP banner treatment
- selection states
- shell buttons
- input fields

This reduces the amount of hardcoded palette logic in the compatibility layer and keeps XP-style chrome aligned with the theme catalog.

## Why this is safer than deleting CSS

ROI 66 keeps layout and behavior where they already live:

- layout remains in the legacy shell stylesheet and templates
- runtime behavior remains in the Vue Options API desktop app
- websocket, VFS, terminal, and window-manager behavior remain unchanged

Only the **theme contract** and **chrome consumption** were rebuilt.

## Testing posture

`MIOMOST.m` now adds focused assertions for the new theme-token contract:

- current theme in the boot object exposes new shell-token fields
- settings catalog theme entries expose the new token fields
- XP-light and accessibility themes continue to publish the expected values

## Intended next ROI

### ROI 67 — Window and Taskbar Chrome Rewrite

Now that theme data is normalized, the next step is to reduce reliance on the legacy shell stylesheet for:

- taskbar controls
- start menu framing
- title bar shells
- shell buttons
- launcher/tool surfaces

while continuing to preserve all current behavior and tests.
