# MIOMOS ROI47 — Guest role and role-aware login workflow

This ROI builds on the seeded bootstrap identities from ROI46 and makes the shell and auth experience role-aware.

## Goals

- keep `admin`, `user`, and `guest` startup personas visible in the auth flow
- make guest access feel intentional instead of like a side door
- remove terminal, admin, and security surfaces from guest-facing UI catalogs
- surface clearer role/session copy in the shell without changing the websocket or terminal runtime contracts

## Source-of-truth rules

- do not replace the existing `MIOSHA256` local-auth path
- keep server-side permission checks authoritative
- UI filtering is additive and must mirror server permissions, not replace them
- the desktop app/window catalog should be filtered on the MUMPS side before boot JSON is emitted

## Implemented changes

### Auth page

- added role-aware persona cards for:
  - `admin`
  - `user`
  - `guest` when guest quick login is enabled
- each persona card includes:
  - display name
  - username
  - primary role label
  - workflow summary
- admin and user persona actions prefill the sign-in form username
- guest persona action uses the existing guest-signin route

### Boot/session metadata

- boot JSON now includes:
  - `user.primaryRole`
  - `user.roleLabel`
  - `auth.signinProfiles`

### Server-authored shell filtering

- app catalog entries now declare their effective permission requirement
- the boot app list is filtered by role/permission before it reaches the browser
- the boot window list is filtered by the same rule set
- guest users no longer receive terminal, admin, or security app/window entries in boot JSON

## Permission-to-app mapping

Current app visibility uses these permission checks:

- `workspace` → `workspace.use`
- `settings` → `settings.self`
- `ui-library` → `workspace.use`
- `jobs` / `exports` → `workspace.use`
- `profiles` → `settings.self`
- `terminal` → `terminal.use`
- `collaboration` → `chat.use`
- `security` → `audit.view`
- `admin` → `admin.users.view`
- `logs` → `logs.view`
- `ui-samples` → `workspace.use`

## Tests

`^MIOMOST` now covers:

- role-aware shell SSR token
- boot user role label
- boot sign-in profile metadata
- guest boot catalog hiding terminal/admin/security
- guest desktop render hiding terminal/admin launch surfaces
- auth-page persona cards and guest quick-login token

## Follow-on ROIs

- ROI48 — admin role center
- ROI49 — admin reports and workflow analytics
- ROI50 — seeded password rotation and policy hardening
