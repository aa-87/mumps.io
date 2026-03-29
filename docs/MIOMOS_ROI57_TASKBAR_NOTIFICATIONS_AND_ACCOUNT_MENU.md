# MIOMOS ROI57 — Taskbar notification center and account menu

This ROI focuses on production shell UX polish rather than new placeholder surfaces.

## What changed

- added `MIOMOSNOTE` to build server-authored shell notifications
- added per-user shell settings for notification preview count, account label visibility, and notification badge visibility
- added a taskbar notification flyout and account menu flyout to the desktop template
- removed roadmap-only placeholder desktop entries and the Planned surfaces workspace card

## Production intent

The shell now treats the taskbar as a real operator control surface rather than a row of decorative chips. Notifications and account actions are authored in MUMPS and rendered by the thin Vue layer.
