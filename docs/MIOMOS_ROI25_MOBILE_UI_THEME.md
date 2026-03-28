# MIOMOS ROI25 — Mobile UI Foundation, Light Theme Correctness, and LLM Handoff

## Goal

Continue hardening MIOMOS as a production-minded MUMPS desktop while shifting emphasis from shell motion to UI correctness and mobile-friendly rendering preparation.

This ROI intentionally removes window fade behavior, improves light-theme readability, adds a new `high-contrast-light` theme, and introduces a stacked-shell strategy for compact viewports.

## Delivered

- Removed window fade transitions from shell windows.
- Added a new theme pack: `high-contrast-light`.
- Tightened existing light themes so body text, taskbar text, pills, and window copy render with darker contrast.
- Added boot metadata for compact/mobile rendering behavior.
- Added UI Library content for:
  - light-theme correctness
  - mobile-friendly render prep
  - touch-target guidance
- Added client-side compact viewport behavior:
  - stacked window flow
  - no drag/resize dependency on small screens
  - sticky top bar and taskbar behavior
  - launcher sized as a mobile-friendly sheet
- Added an `miomos_llm.md` document for continuation in another chat.
- Updated smoke tests for the new boot contract and UI render tokens.

## Architectural notes

### Mobile strategy

MIOMOS is still desktop-first and MUMPS-first.

This ROI does **not** turn MIOMOS into a separate mobile app. Instead, it prepares the shell to degrade gracefully on smaller screens:

- desktop metadata remains server-authored
- the browser switches layout strategy only
- windows become stacked cards under a compact breakpoint
- resize handles and desktop-drag expectations are suppressed
- touch-friendly spacing becomes the default on compact screens

### Theme strategy

The shell continues to use a server-authored theme catalog from `MIOMOSTH`.

Light themes now need to be treated as first-class production themes rather than dark-mode exceptions. The shell therefore applies explicit light-mode overrides for:

- topbar/taskbar chrome
- window bodies and title bars
- pills, tags, and badges
- hover states in tables and dense cards
- desktop icon labels and metadata text

## Test impact

`MIOMOST` now asserts:

- ROI25 boot version string
- mobile-ready render tokens
- window-fade-off token
- mobile boot metadata
- the presence of the `high-contrast-light` theme
- the mobile prep section in the UI Library view model

## Next likely ROI ideas

1. full responsive navigation patterns for auth and settings pages
2. mobile-aware task switching instead of stacked multi-window flow
3. more complete context menu system with keyboard parity
4. denser form controls and better table responsiveness under 768 px
5. theme-specific iconography polish for light themes
