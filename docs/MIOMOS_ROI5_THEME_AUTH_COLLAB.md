# MIOMOS ROI 5: theming, optional auth, observability, collaboration

This ROI keeps the stable one-socket desktop baseline and adds the first production-facing security and personalization foundation.

## Implemented in this ROI

- Theme catalog managed on the MUMPS side (`MIOMOSTH`)
  - midnight-professional
  - slate-light
  - clinical-blue
  - high-contrast
- Per-user theme persistence under `^MIO("MIOMOS","PREF",principal,...)`
- Optional built-in local auth (`MIOMOSAUTH`)
  - sign up
  - sign in
  - sign out
  - cookie-backed session token
- Dev profile still disables auth by default
- Desktop auth gate
  - if local auth is enabled and no session exists, `/miomos` renders an auth page instead of a JSON error
- Access log ring (`MIOMOSOBS`)
- Error log ring (`MIOMOSOBS`)
- Audit trail store and tail helper (`MIOMOSAUD`)
- Permission catalog (`MIOMOSPERM`)
- Persistent room chat foundation over the existing websocket (`MIOMOSCHAT` + `MIOMOSWS`)
- UI updates
  - theme selector in the menu
  - sign out action
  - chat window
  - security window with log/audit/permission summaries

## New/updated routes

- `GET /miomos`
- `GET /api/miomos/bootstrap`
- `POST /api/miomos/theme`
- `POST /api/miomos/auth/signin`
- `POST /api/miomos/auth/signup`
- `POST /api/miomos/auth/signout`
- `WS  /ws/miomos`

## Dev posture

Default dev posture remains frictionless:

```mumps
S CONF("miomos","profile")="dev"
S CONF("miomos","dev","authDisabled")=1
```

Optional local auth can be turned on outside development:

```mumps
S CONF("miomos","profile")="prod"
S CONF("miomos","dev","enabled")=0
S CONF("miomos","dev","authDisabled")=0
S CONF("miomos","localAuth","enabled")=1
S CONF("miomos","localAuth","allowSignup")=1
```

## Production notes

This ROI intentionally stops short of:

- password reset / MFA
- websocket fan-out broadcast to all connected users
- durable file-backed or external log sink
- admin UI for user provisioning
- granular ABAC rules beyond role/permission checks

Those are planned next.
