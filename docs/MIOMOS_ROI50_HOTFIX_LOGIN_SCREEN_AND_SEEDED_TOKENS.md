# MIOMOS ROI50 hotfix — login screen precedence and seeded credential tokens

## Fixes

- Prevent prod instances with `localAuth.enabled=1` from auto-bypassing into dev auth when `dev.authDisabled` was left on from an earlier configuration.
- Preserve the seeded credential values in the rendered access page so `^MIOMOST` can find the configured admin/user/guest password tokens.

## Files

- `routines/MIOMOSST.m`
- `templates/pages/miomos_auth.html`

## Behavior

In prod with local auth enabled, the desktop entry route should render the access screen unless a valid `miomos_auth` cookie is already present. If a browser is still entering the desktop directly after this patch, clear the existing `miomos_auth` cookie or use sign out once, then reload `/miomos`.
