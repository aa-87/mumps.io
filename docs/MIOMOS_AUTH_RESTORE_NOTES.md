# MIOMOS auth restore notes

This patch restores the MIOMOS local-auth contract used by `^MIOMOST` while preserving the login/access screen.

Key points:
- Restores `MIOMOSAUTH` and `MIOAUTHJWT` to the repo baseline.
- Keeps `/miomos` page-rendered and lets the page show the auth screen when no local session cookie is present.
- Changes `MIOMOSST` so local auth takes precedence over dev bypass when local auth is enabled. That makes the login screen appear even if the instance is still using the dev profile.
- Adds seeded admin/user/guest credential cards to the auth page.
- Adds `Switch User` actions in the desktop shell, implemented as sign-out back to the access screen.

This does **not** convert MIOMOS to framework JWT auth. The current test suite still depends on the existing local session/token registry. A clean MIOAUTHJWT migration should be a dedicated ROI after the MIOMOS tests are updated to that contract.
