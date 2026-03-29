# MIOMOS ROI51 — seeded password rotation and policy hardening

## What changed

- Seeded `admin` and `user` bootstrap accounts now default to `forcePasswordChange=1`.
- Seeded `guest` stays exempt from forced password rotation.
- The access flow now supports a password-rotation gate on successful sign-in for seeded accounts.
- The sign-in API can return `requiresPasswordChange=1` plus a one-time reset token instead of issuing a browser cookie immediately.
- The access screen now exposes a dedicated password-change form and uses the existing reset-apply route to complete the rotation.
- Password policy settings are now configurable under `CONF("miomos","localAuth","passwordPolicy",...)`.
- Bootstrap sync now preserves manually rotated passwords when `preservePasswordChanges=1`.
- In `prod`, guest quick login now defaults to off unless explicitly enabled.

## New config

```mumps
SET CONF("miomos","localAuth","passwordPolicy","minLength")=8
SET CONF("miomos","localAuth","passwordPolicy","requireUpper")=0
SET CONF("miomos","localAuth","passwordPolicy","requireLower")=0
SET CONF("miomos","localAuth","passwordPolicy","requireDigit")=0
SET CONF("miomos","localAuth","passwordPolicy","requireSymbol")=0

SET CONF("miomos","bootstrapAuth","preservePasswordChanges")=1
SET CONF("miomos","bootstrapAuth","admin","forcePasswordChange")=1
SET CONF("miomos","bootstrapAuth","user","forcePasswordChange")=1
SET CONF("miomos","bootstrapAuth","guest","forcePasswordChange")=0
```

## Behavioral notes

- Operators can still keep the current guest workflow by explicitly setting:

```mumps
SET CONF("miomos","localAuth","guestLoginEnabled")=1
```

- When a seeded admin or user signs in with a bootstrap password, the browser receives a password-rotation response instead of a session cookie. The cookie is only issued after the password is changed and the follow-up sign-in succeeds.
- Bootstrap password sync no longer overwrites a rotated password by default, which closes the biggest production-hardening gap in the seeded-auth workflow.
