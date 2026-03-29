# MIOMOS ROI52 — Admin role center

## Summary

This ROI turns the MIOMOS admin surface into a role-aware control center instead of a read-only admin summary.

It adds:

- a role catalog authored in MUMPS
- a role assignment editor in the admin desktop surface
- effective permission preview for the selected role set
- runtime control for guest quick-login
- bootstrap-auth status visibility for seeded `admin`, `user`, and `guest` identities

The implementation stays aligned with MIOMOS design rules:

- MUMPS remains the source of truth
- SSR remains the primary rendering model
- Vue stays a thin interaction layer
- auth/session handling is not rewritten
- the admin surface uses existing MIOMOS auth and permission patterns

## Why this ROI matters

MIOMOS already had:

- local identities
- seeded bootstrap users
- role-aware auth
- guest workflow controls

But the shell still lacked a production-grade way for an administrator to:

- inspect current role posture
- change a user’s roles safely
- preview what a role set actually grants
- confirm the current guest access workflow
- verify seeded identity/bootstrap posture without reading globals directly

This ROI closes that gap.

## Backend changes

### `MIOMOSPERM`

Added role-center helpers:

- `ROLECAT(.OUT)` — canonical role catalog for admin, developer, operator, auditor, support, security, and guest
- `VALIDROLE(ROLE)` — validates role keys against the catalog
- `NORMALIZE(ROLES,.OUTCSV)` — dedupes and canonicalizes role order
- `PREVIEW(ROLES,.OUT)` — produces effective permission preview from a role set

Also tightened `PRIMARYROLE(ROLES)` so a multi-role user resolves to the first non-admin role in canonical order instead of drifting to the last CSV entry.

### `MIOMOSADMIN`

Added admin control-center helpers:

- `GUESTLOGIN(.CONF)` — returns the effective guest quick-login state using runtime override first, config second
- `SETGUESTLOGIN(VALUE,.OUT)` — persists runtime guest quick-login override
- `BOOTSTATUS(.CONF,.OUT)` — exposes local-auth/bootstrap posture plus seeded user runtime state
- `SETROLES(USER,ROLECSV,.OUT,.ERR)` — updates a user’s role set using normalized catalog order
- `SYNCAUTH(USER,ROLES)` — refreshes live auth/session role posture after role changes
- `USERSTATE(USER,ENABLED,LOCKED)` — consistent status labeling

Enhanced `USERLIST` output so the admin surface can show:

- display name
- primary role
- role label
- updated timestamp
- source
- bootstrap persona
- user state/status

### `MIOMOSAPI`

Added new admin endpoints:

- `POST /api/miomos/admin/users/roles` → `ADMINUSERROLES^MIOMOSAPI`
- `POST /api/miomos/admin/config/guest-login` → `ADMINGUESTTOGGLE^MIOMOSAPI`

These endpoints:

- require an authenticated admin session through existing MIOMOS auth/session checks
- enforce `admin.users.manage`
- emit JSON results suitable for the thin Vue client
- record audit/access events

### `MIOMOS`

Added route defaults and registrations for:

- `adminUserRoles`
- `adminGuestToggle`

These were wired into the same route metadata model used by the rest of MIOMOS.

### `MIOMOSST`

Extended the desktop state and boot contract with:

- `adminUserRolesPath`
- `adminGuestTogglePath`
- effective `guestLoginEnabled`

### `MIOMOSVM`

The admin view model now includes:

- `roleCatalog`
- per-role permission preview
- `bootstrapStatus`
- default permission preview payload

### `MIOMOSUI`

The admin SSR context now includes:

- role catalog
- bootstrap-auth status
- guest toggle state
- admin role update route
- admin guest-toggle route

## UI changes

The desktop admin window now includes:

### Role assignment editor

- choose a user
- toggle one or more roles
- save the normalized role set

### Effective permission preview

- shows the resolved permissions for the currently selected role set
- makes RBAC consequences visible before and after save

### Access workflow controls

- shows guest quick-login state
- allows admin to enable or disable the guest entry workflow from the admin surface

### Bootstrap-auth status

- shows whether local auth is enabled
- shows whether guest quick login is configured and effectively enabled
- shows bootstrap controls like `seedIfMissing`, `syncOnBoot`, and `showSeededCredentials`
- lists seeded `admin`, `user`, and `guest` identities with configured/runtime posture

## Testing

`MIOMOST` coverage was extended for:

- route registration metadata for the new admin endpoints
- role catalog presence in the view model
- bootstrap-auth status presence in the view model
- effective permission preview for auditor/operator combinations
- admin role update helper behavior
- guest toggle runtime override behavior
- SSR tokens for the new admin control-center UI

## Production effect

After this ROI, MIOMOS administrators can manage role posture from inside the shell instead of relying on direct global edits or ad hoc support routines.

This is a major production-readiness step because it makes:

- RBAC inspection
- RBAC modification
- guest workflow control
- bootstrap-auth verification

available in the actual product surface.

## Next recommended ROI

**ROI53 — admin reports and workflow analytics**

Focus next on:

- active user/session counts
- guest usage analytics
- failed login and lockout trends
- invite/reset activity summaries
- permission and session posture summaries
- exportable admin operational reports
