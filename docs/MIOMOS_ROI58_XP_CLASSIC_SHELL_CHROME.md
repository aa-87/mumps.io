# MIOMOS ROI58 — Windows XP classic shell chrome

## Goal

Make the taskbar, Start menu, and taskbar flyouts visibly render as MIOMOS-authored shell surfaces with a Windows XP classic influence, instead of relying on generic shell panel styling.

## What changed

- Added explicit CSS for `.miomos-taskbar-flyout` and related notification/account menu classes.
- Added Windows XP classic styling for the Start button, Quick Launch strip, task buttons, tray area, and Start menu panes.
- Updated flyout markup so notification and account rows render with glyphs, copy, and badges.
- Added a small helper in the desktop Vue methods to map account menu items to shell glyphs.
- Added SSR coverage to ensure XP shell CSS tokens remain present in the desktop render.

## Production intent

This ROI is a shell-chrome correctness pass. It does not change auth, websocket, or terminal ownership. It makes the authored taskbar and Start menu feel like first-class desktop surfaces instead of incidental markup.
