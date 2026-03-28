# MIOMOS ROI24 — UI correctness, motion, and context menus

This ROI hardens the MIOMOS shell itself rather than adding new app surfaces.

## Focus
- improve light-theme correctness and text contrast
- add **High Contrast Light** theme
- smooth window dragging and resizing
- add shell and window context menus
- make window open/close/minimize feel calmer and more intentional
- lock the render contract with smoke tests

## Key changes
- Theme catalog now includes brighter, higher-contrast light chrome and a daylight-oriented accessibility theme.
- Window-manager motion profiles now include **Silky** and **Snappy**.
- The UI Library includes a **Desktop** tab covering context menus, motion, and light-theme correctness.
- The shell exposes explicit tokens for context-menu rendering and ROI24 contract assertions.
- Drag/resize logic is requestAnimationFrame-backed for smoother movement and less visual jitter.

## Production intent
This ROI is aimed at UI polish and usability correctness while keeping MUMPS as the source of truth for shell state, theme metadata, and renderable component contracts.
