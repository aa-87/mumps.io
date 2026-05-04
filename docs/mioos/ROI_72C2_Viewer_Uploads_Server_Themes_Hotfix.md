# ROI 72C2 — Viewer, Uploads, Start Menu Folders, and Server Theme Hotfix

## Goal

Stabilize the Start Menu follow-up work without changing unrelated patient, terminal, or table behavior.

## Fixes

- Registered a real `mioos-surface-viewer` shell component so text, image, PDF, audio, and video file windows render a working surface instead of an empty/broken window.
- Kept text file windows on the command path first, then fell back to `/api/mioos/fs/blob` when socket reads return an empty or variant payload.
- Hardened Theme Studio uploads for background, banner/login background, warning image, and avatar assets.
- Added a raw binary upload fallback for theme assets in addition to multipart form uploads.
- Kept uploaded image URLs server-backed through `/api/mioos/theme-asset`; no DataURLs are used for persisted assets.
- Removed active/custom theme localStorage hydration/persistence. Theme profiles and active theme selection are server-authored.
- Preserved pre-auth sanitization so protected asset URLs are not emitted before authentication.
- Made Start Menu VFS folders expand without closing the menu and gave recursive rows enough vertical room to remain visible and clickable.
- Fixed desktop icon placement so new icons use the next open grid slot instead of stacking at the top-left.
- Seeded a Desktop `Programs` folder containing shortcuts for core app/program launchers.

## Validation

Browser syntax checks should include:

```bash
node --check public/mioos/app/mioos_core.js
node --check public/mioos/app/mioos_shell_ui.js
node --check public/mioos/app/mioos_explorer.js
```

MUMPS validation should include:

```mumps
ZLINK "MIOOSAPI"
ZLINK "MIOOSFS"
ZLINK "MIOOSST"
ZLINK "MIOOS"
ZLINK "MIOOST"
D ^MIOOST
```

If YottaDB / GT.M is unavailable, use the static checks in `MIOOST` and run the full test suite in a real MUMPS environment before release.
