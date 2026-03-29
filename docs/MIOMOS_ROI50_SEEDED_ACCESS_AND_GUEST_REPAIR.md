# MIOMOS ROI50 — Seeded access visibility and guest-account repair

## Goal

Make the access screen self-explanatory for seeded local accounts, and prevent stale bootstrap-backed guest accounts from producing avoidable 403 errors during the guest workflow.

## What changed

- Added explicit bootstrap-auth config switches:
  - `CONF("miomos","bootstrapAuth","showSeededCredentials")`
  - `CONF("miomos","bootstrapAuth","syncOnBoot")`
- The access screen now renders seeded admin, user, and guest credentials when `showSeededCredentials=1`.
- Seeded accounts remain configurable through:
  - `CONF("miomos","bootstrapAuth","admin",...)`
  - `CONF("miomos","bootstrapAuth","user",...)`
  - `CONF("miomos","bootstrapAuth","guest",...)`
- Bootstrap seeding now supports controlled resync for existing bootstrap-backed users when `syncOnBoot=1`.
- Guest sign-in now retries after reseeding the guest persona if the existing guest account is stale, disabled, or locked but still bootstrap-backed.

## Why this ROI exists

A passing clean test run can still differ from a lived browser instance that already has historical globals.

In that situation, the guest persona may already exist under `^MIO("MIOMOS","USER","guest",...)` but be disabled or locked from prior experiments. The previous behavior would then return a 403 for `Continue as guest` even though guest login was enabled in the current config.

## Expected behavior after this ROI

- `/miomos` remains the unauthenticated access page in prod/local-auth mode.
- The page can show seeded credentials directly when configured to do so.
- `Continue as guest` uses the seeded guest persona from config.
- If the seeded guest account is bootstrap-backed but stale, MIOMOS repairs it from config and retries.

## Important config knobs

```mumps
SET CONF("miomos","localAuth","enabled")=1
SET CONF("miomos","localAuth","guestLoginEnabled")=1

SET CONF("miomos","bootstrapAuth","showSeededCredentials")=1
SET CONF("miomos","bootstrapAuth","syncOnBoot")=1

SET CONF("miomos","bootstrapAuth","admin","username")="admin"
SET CONF("miomos","bootstrapAuth","admin","password")="admin123!"
SET CONF("miomos","bootstrapAuth","user","username")="user"
SET CONF("miomos","bootstrapAuth","user","password")="user123!"
SET CONF("miomos","bootstrapAuth","guest","username")="guest"
SET CONF("miomos","bootstrapAuth","guest","password")="guest123!"
```

## Notes

- Plaintext passwords are still **not** stored in `^MIO("MIOMOS","USER",...)`; only salted hashes are stored.
- The access page shows the configured seeded values directly from `CONF`, which is why the visibility of those values is now controlled by `showSeededCredentials`.
- `syncOnBoot=1` is convenient for evaluation and local installs. Operators who want to preserve manual edits to seeded bootstrap accounts can set it to `0`.
