# MIOMOS UI/UX ROI 2

This ROI shifts the MIOMOS foundation from a mostly static SSR proof-of-concept into a usable desktop shell.

## Goals completed

- SSR now renders a visible taskbar, launcher, desktop shortcuts, and windows by default.
- Core window mechanics no longer depend on Vue mounting successfully.
- Windows support:
  - focus
  - taskbar toggle
  - minimize
  - maximize / restore
  - close / reopen
  - drag via title bar
  - resize via lower-right grip
- Window geometry and state persist locally per MIOMOS session in `localStorage`.
- Websocket hello/ping flow remains connected to the shell and now feeds visible toast/status feedback.
- Vue 3 Options API UMD remains present as a progressive enhancement layer instead of a hard dependency for the desktop mechanics.

## Design direction

The shell is intentionally more professional and restrained:

- stronger contrast
- calmer gradients
- tighter spacing
- denser but readable chrome
- Windows-class desktop hierarchy
- 7.css-informed visuals without leaning into gimmicky retro styling

## Why the shell no longer freezes

The previous baseline placed the interactive desktop inside a Vue-mounted island. If Vue failed to mount, the user only saw the SSR fallback, which had static windows and no taskbar interaction.

This ROI moves the **core shell mechanics** into a framework-independent browser controller:

- SSR outputs the real taskbar and real windows
- plain browser JS activates the shell immediately
- Vue becomes optional enhancement rather than a single point of failure

That means MIOMOS remains usable even if:

- the Vue script does not load
- a Vue mount issue occurs
- OS.js is absent

## Files changed

- `routines/MIOMOSUI.m`
- `routines/MIOMOST.m`
- `templates/pages/miomos_desktop.html`
- `templates/layouts/miomos_shell.html`
- `docs/MIOMOS_UIUX_ROI2.md`

## Deferred to next ROI

- MIO-backed persisted window/workspace state on the server side
- richer MIOMOS app surfaces per app key instead of generic launch bodies
- keyboard navigation and command palette
- desktop notifications/history center backed by MIOMOS state
- OS.js adapter boot that replaces the generic runtime placeholders with real providers
- form/dialog/drawer component catalog under `MIOMOSUI*`
