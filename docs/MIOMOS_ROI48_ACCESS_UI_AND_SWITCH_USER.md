# MIOMOS ROI48 — Role-aware access UI and account switching

## Goal

Move the bootstrap-auth and guest-login work from a backend-only posture into a production-minded access workflow.

This ROI keeps the current guest quick-login path, but adds a clearer account-aware access screen and explicit desktop session actions for:

- sign out
- switch user
- seeded admin login
- seeded standard-user login

It also hides guest-inaccessible launch surfaces at the shell layer so the desktop does not advertise tools that the current role cannot use.

## What changed

### 1. Auth UI config switches

`CONFDEF^MIOMOS` now sets UI-facing auth defaults for:

- `miomos.authUi.showSeededCredentials`
- `miomos.authUi.showSwitchUser`
- `miomos.authUi.showSignout`

### 2. Seeded credential cards on the access screen

When bootstrap auth is enabled and `showSeededCredentials=1`, the access screen renders seeded login cards for:

- `admin / admin123!`
- `user / user123!`

These cards populate the standard sign-in form rather than inventing a second auth route.

### 3. Switch-user and sign-out actions in the shell

The Start menu now includes an account section that shows the current session and provides:

- `Switch user`
- `Sign out`

The browser will try websocket signout first and fall back to the HTTP signout route if needed.

### 4. Role-aware launch visibility

The boot contract now exposes role-aware metadata such as:

- `auth.workflow = role-aware-access`
- `user.primaryRole`
- `user.roleLabel`
- `user.roleTone`
- `desktop.roleAwareShell = 1`
- `desktop.launchVisibility = permission-aware`

Guest users now have restricted apps hidden at the shell layer, including:

- Terminal
- Security
- Admin

### 5. Switch-user redirect behavior

After a switch-user or sign-out action, MIOMOS redirects back to the desktop access route so the desktop route can render the login screen again under normal server control.

## Why this ROI matters

ROI46 proved that bootstrap identities and guest quick login work. ROI48 makes that workflow feel intentional and usable for a real operator desktop by:

- making seeded access discoverable
- making guest access explicit
- making account transitions visible
- preventing guest sessions from seeing tools they cannot open

## Next ROI

- **ROI49 — admin role center**
  - role editor
  - effective permission preview
  - guest login toggle management
  - bootstrap-auth status panel
