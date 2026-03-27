# MIOMOS ROI 6: identity hardening, admin surfaces, and documentation foundation

This ROI extends the passing ROI 5 baseline with the first serious account-lifecycle controls and the first real admin surface. It keeps the current stable desktop transport model intact:

- one persistent websocket
- MUMPS-owned sessions and logs
- optional local auth outside development
- auth disabled by default in the `dev` profile

## What this ROI adds

### Identity hardening
- invite-only onboarding mode for local accounts
- configurable signin lockout threshold and lock duration
- disable / enable controls for local users
- manual lock / unlock controls for local users
- reset-token issuance and reset-token application
- password change tracking via `passwordChangedAt`

### Admin surfaces
- `Admin` desktop app/window
- user directory summary
- invite token summary
- reset token summary
- admin counts for enabled / disabled / locked users

### API surface
- `GET  /api/miomos/admin/users`
- `POST /api/miomos/admin/users/disable`
- `POST /api/miomos/admin/users/enable`
- `POST /api/miomos/admin/users/lock`
- `POST /api/miomos/admin/users/unlock`
- `POST /api/miomos/admin/invites/create`
- `GET  /api/miomos/admin/invites`
- `POST /api/miomos/admin/users/reset/request`
- `POST /api/miomos/auth/reset`

### Documentation foundation
- ongoing user guide
- ongoing internal README
- updated production ROI roadmap

## Config added in this ROI

```mumps
S CONF("miomos","localAuth","inviteOnly")=1
S CONF("miomos","localAuth","inviteTokenDays")=7
S CONF("miomos","localAuth","resetTokenSeconds")=3600
S CONF("miomos","localAuth","lockThreshold")=5
S CONF("miomos","localAuth","lockMinutes")=15
```

## Development posture

Development remains frictionless:

```mumps
S CONF("miomos","profile")="dev"
S CONF("miomos","dev","authDisabled")=1
```

With that posture:
- `/miomos` remains directly accessible
- admin routes still resolve through MIOMOS state and permissions
- the default dev user continues to have `developer,admin`

## Production posture example

```mumps
S CONF("miomos","profile")="prod"
S CONF("miomos","dev","enabled")=0
S CONF("miomos","dev","authDisabled")=0
S CONF("miomos","localAuth","enabled")=1
S CONF("miomos","localAuth","allowSignup")=1
S CONF("miomos","localAuth","inviteOnly")=1
S CONF("miomos","localAuth","lockThreshold")=5
S CONF("miomos","localAuth","lockMinutes")=15
S CONF("miomos","localAuth","resetTokenSeconds")=3600
```

## Tests added in this ROI

The updated `^MIOMOST` covers:
- admin route metadata
- admin SSR surface rendering
- boot payload route/version updates
- invite-only signup
- failed-login lockout
- reset-token request and apply
- disable / enable / lock / unlock lifecycle
- admin permission checks
- admin list/count helpers

## Notes

This ROI intentionally does **not** yet implement:
- MFA
- email delivery for invites or reset tokens
- browser-side admin actions wired to live POST forms
- retention policies for invites/resets/logs
- lock screen / re-auth

Those are planned next.
