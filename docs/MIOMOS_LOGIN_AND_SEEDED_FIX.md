# MIOMOS login-screen and seeded-credential fix

## What this fixes

1. In `prod` with `localAuth.enabled=1`, a stale `dev.authDisabled=1` no longer forces an automatic dev login.
2. The access page now renders seeded admin/user/guest credential cards again.
3. The access page now emits stable seeded password tokens for tests and fill buttons.
4. Visiting `/miomos?signedOut=1` or `/miomos?switchUser=1` now suppresses cookie-based auto-login for that request so the access page can render reliably.
5. Desktop sign-out now redirects back to `/miomos?signedOut=1`.

## Config reminders

```mumps
SET CONF("miomos","profile")="prod"
SET CONF("miomos","localAuth","enabled")=1
SET CONF("miomos","dev","authDisabled")=0
SET CONF("miomos","bootstrapAuth","showSeededCredentials")=1
```

## Default seeded credentials

- admin / `admin123!`
- user / `user123!`
- guest / `guest123!`

All three remain configurable under `CONF("miomos","bootstrapAuth",...)`.
