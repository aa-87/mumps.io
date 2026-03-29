# MIOMOS ROI46 — Bootstrap identities and guest login toggle

## Goal

Add a production-minded local-auth bootstrap layer that seeds three startup personas only when missing:

- `admin`
- `user`
- `guest`

Passwords continue to use the existing salted `MIOSHA256` path through `MIOMOSAUTH`.

This ROI also restores the current guest workflow as an explicit, configurable quick-login path instead of relying on implicit no-auth behavior.

## What changed

### 1. Startup config defaults

`CONFDEF^MIOMOS` now sets default config for:

- `miomos.localAuth.guestLoginEnabled`
- `miomos.bootstrapAuth.enabled`
- `miomos.bootstrapAuth.seedIfMissing`
- `miomos.bootstrapAuth.admin.*`
- `miomos.bootstrapAuth.user.*`
- `miomos.bootstrapAuth.guest.*`

Default seeded credentials are:

- `admin / admin123!`
- `user / user123!`
- `guest / guest123!`

Default seeded roles are:

- `admin -> admin`
- `user -> operator`
- `guest -> guest`

## 2. Idempotent bootstrap seeding

`BOOTSTRAP^MIOMOSAUTH` seeds identities only when missing.

It does **not** overwrite an existing user's:

- hash
- salt
- roles
- enabled flag

Seeded users are marked with metadata such as:

- `source = bootstrap-auth`
- `bootstrapPersona`
- `bootstrapSeededAt`

## 3. Guest quick-login route

A new unauthenticated route is added:

- `POST /api/miomos/auth/guest`

It issues a normal MIOMOS local-auth token for the seeded `guest` principal when:

- local auth is enabled
- `guestLoginEnabled=1`
- the seeded guest account is enabled and not locked

## 4. Guest role permissions

A new `guest` role is recognized by `MIOMOSPERM`.

Current guest permission posture is intentionally limited:

Allowed:

- `workspace.use`
- `theme.self`
- `settings.self`
- `chat.use`

Denied by default:

- `terminal.use`
- admin permissions
- log and audit exports
- retention management
- reset/invite administration

## 5. Safe boot/auth metadata

Boot JSON now exposes:

- `routes.guestSignin`
- `auth.guestLoginEnabled`
- `auth.guestRole`
- `auth.bootstrapEnabled`
- `auth.seededUsers.*` (username/displayName/roles only)

Plain passwords are **not** exposed in boot JSON or persisted in user globals.

## 6. Auth page workflow

The access page now renders a guest button when guest quick login is enabled.

The browser posts to the guest route and reloads into the desktop on success.

## Tests added/updated

`^MIOMOST` now covers:

- guest auth route registration
- boot guest-login and bootstrap metadata
- seeded account creation for admin/user/guest
- salted hash correctness through `MIOSHA256`
- absence of stored plain-text password fields
- guest quick login token issuance
- guest role permission limits
- auth page guest button rendering

## Source-of-truth behavior after ROI46

- seeded startup identities exist by config, not by manual data entry
- local auth remains the main sign-in path
- guest access is explicit and toggleable
- the permission model remains server-authored
- this ROI does **not** yet implement full role-aware app filtering or admin role editing UI

## Next TODO ROIs

- ROI47 — guest role and role-aware login workflow
- ROI48 — admin role center for users, roles, permissions, and guest toggle
- ROI49 — admin reports and workflow analytics
- ROI50 — seeded password rotation and policy hardening
