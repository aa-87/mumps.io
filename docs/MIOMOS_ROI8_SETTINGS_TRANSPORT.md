# MIOMOS ROI 8 — Settings + Transport Foundation

## Goal
Stabilize MIOMOS as a single desktop session per browser tab while introducing a real `Settings` application for per-user desktop preferences.

## What this ROI changes
- Keeps MIOMOS on a single guarded websocket per tab/session.
- Adds a server-backed settings model under `^MIO("MIOMOS","PREF",principal,...)`.
- Adds a `Settings` desktop window and launcher entry.
- Applies theme, font, font size, density, wallpaper, title accent, animation level, icon style, and custom icon overrides live in the browser.
- Keeps MUMPS authoritative for persisted settings, auth/session, audit, and routing.

## New routes
- `GET /api/miomos/settings`
- `POST /api/miomos/settings`

Both routes are registered through `REG^MIOMOS` and use the same MIOMOS session/auth model as the rest of the desktop API surface.

## New routine
- `MIOMOSSET.m`

Main entry points:
- `LOAD(.STATE,.CONF)` — hydrate state from persisted preferences
- `CURRENT(USER,.OUT)` — return current settings + catalog
- `SAVE(USER,.TREE,.OUT,.ERR)` — validate and persist settings
- `PUTBOOT(ROOT,.STATE,.CONF)` — add settings to bootstrap JSON

## Settings covered in ROI 8
- Theme key
- Font family
- Font size
- Title accent mode/color
- Icon style
- Wallpaper
- Density
- Animations
- Per-app custom icon text overrides

## Browser behavior
The desktop runtime now:
- uses one websocket per browser tab/session
- reconnects only after `close` / `error`
- resumes the same MIOMOS session using `sessionId`
- avoids reconnecting on click, drag, resize, menu actions, or settings changes

## Data model
Preferences are persisted under:
- `^MIO("MIOMOS","PREF",principal,"theme")`
- `^MIO("MIOMOS","PREF",principal,"fontFamily")`
- `^MIO("MIOMOS","PREF",principal,"fontSize")`
- `^MIO("MIOMOS","PREF",principal,"titleAccent")`
- `^MIO("MIOMOS","PREF",principal,"iconStyle")`
- `^MIO("MIOMOS","PREF",principal,"wallpaper")`
- `^MIO("MIOMOS","PREF",principal,"density")`
- `^MIO("MIOMOS","PREF",principal,"animations")`
- `^MIO("MIOMOS","PREF",principal,"icon",appKey)`

## Testing focus
`^MIOMOST` for this ROI now covers:
- route registration for settings GET/POST
- desktop render tokens for the settings surface
- single-socket marker presence
- bootstrap settings payload presence
- permission checks for `settings.self`
- save/load of a representative settings payload

## Development posture
Development remains MIOMOS-dev-profile friendly:
- auth may stay disabled during development
- settings still persist per dev principal
- the desktop route and settings routes stay aligned with the MIOMOS session model

## Notes for next ROI
This ROI deliberately stops short of terminal work.
The next terminal ROI should build on this stable desktop/session/settings foundation instead of introducing a second transport stack.
