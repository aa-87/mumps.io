# MIOMOS ROI36 — Clean xterm.js reintegration, YottaDB-only terminal contract, theme/font/cursor alignment

This pass reintroduces xterm.js as a thin browser renderer on top of the existing YottaDB PIPE terminal backend.

## Goals
- Keep the server-side terminal contract YottaDB-first and PIPE-backed.
- Remove dependence on the older MIOMOSTERM pseudo-shell behavior for active terminal sessions.
- Let xterm.js own focus, cursor rendering, and browser-side input capture.
- Make terminal font and theme settings apply to the live terminal renderer.
- Normalize cursor blink to a steady 1 second cadence instead of rapid flicker.

## Implementation summary
- `MIOMOSTERM` now acts as a terminal settings/profile facade and thin wrapper over `MIOMOSTPIPE` for open, attach, poll, input, resize, and close.
- `MIOMOST` terminal smoke coverage now validates YottaDB output (`write 123,!`) instead of the retired pseudo-shell `whoami` path.
- `miomos_desktop.html` replaces the replica terminal with a real xterm host surface.
- xterm input is forwarded as raw `data` chunks to the existing websocket command bus, preserving the YottaDB direct session behavior.
- Theme and terminal font settings are pushed into xterm options so the renderer respects MIOMOS theme selection and terminal font preferences.
- xterm cursor blink animation is constrained to a normal 1 second cadence in CSS.

## Notes
- Clear now clears the viewport only. It is no longer treated like a terminal command.
- Additional terminal font choices were added to improve legibility.
