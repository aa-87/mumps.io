MIOMOS auth public-route fix

This patch restores the intended contract after the JWT hotfix regressions:
- /miomos stays public and renders the access screen when no local session is present
- protected MIOMOS APIs and the websocket can require auth again in prod when auth is enabled
- local MIOMOS sessions remain the active session contract used by MIOMOST
- auth.jwt.cookieName defaults to miomos_auth for JWT-oriented route mode and cookie-based validation
- MIOAUTHJWT can read a JWT from the configured cookie when no Authorization header is present
- access UI shows seeded admin/user credentials and exposes Switch User in the shell

Changed files:
- routines/MIOMOS.m
- routines/MIOMOSST.m
- routines/MIOAUTHJWT.m
- routines/MIOMOSUI.m
- routines/MIOMOST.m
- templates/pages/miomos_auth.html
- templates/pages/miomos_desktop.html
