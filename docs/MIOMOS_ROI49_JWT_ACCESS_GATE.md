# MIOMOS ROI49 — JWT-first access gate

## Goal
Move MIOMOS browser auth toward the existing MIOAUTHJWT contract so the desktop, API, and websocket surfaces share one JWT-backed authentication story.

## Delivered
- Desktop route can render the access screen without being preempted by middleware JSON 401 responses.
- Seeded admin and user sign-in continues to work, but now issues JWT-backed browser sessions when `CONF("auth","mode")="jwt"`.
- Optional guest login remains config-driven.
- JWT validation can fall back to a configured cookie, which allows browser navigation, fetch requests, and websocket upgrades to use the same session token.
- Desktop sign-out now clears the auth cookie through the HTTP sign-out route so switch-user returns to the access screen.

## Notes
- `MIOAUTHJWT` remains the source of claim parsing and role materialization.
- MIOMOS continues to use `MIOMOSPERM` for in-app shell permissions after JWT roles are established in context.
- Development profile bypass is still available, so production-style access requires `profile="prod"` or `dev.authDisabled=0`.
