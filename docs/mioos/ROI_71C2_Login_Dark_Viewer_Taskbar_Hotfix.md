# ROI 71C2 — Login public assets, dark contrast, viewer chrome, and taskbar placement hotfix

## Goal

Fix the remaining login-screen image 401s and the focused visual regressions reported in the dark theme, file viewers, titlebar gradients, and taskbar placement controls without changing the wider MIOOS architecture.

## Scope

This ROI keeps the existing MUMPS/YottaDB + MIOTPL + Vue 3 Options API UMD architecture. It does not introduce a build step, a new frontend framework, or DataURL-based persisted images.

Implemented fixes:

- Publish only active login-screen images through a dedicated public-login asset endpoint.
- Keep normal theme assets protected behind authenticated routes.
- Hydrate the unauthenticated login theme profile from the public login profile so the login page can show the configured background, avatar, and banner before sign-in.
- Calculate public theme asset `Content-Length` from actual stored chunks.
- Remove duplicate filenames from File/Edit/Help viewer menu strips because the window titlebar already shows the filename.
- Add media loop controls for audio/video viewers.
- Make active/inactive titlebar gradient variables affect live windows and preview windows.
- Add `right` taskbar position support.
- Prevent top/left/right taskbar placement from covering desktop icons by padding the desktop surface.
- Harden dark-theme contrast in Theme Studio, Explorer icon/details surfaces, Explorer panels/toolbars, transfer summary surfaces, and table/patient modal titlebars.

## Public login asset behavior

`/api/mioos/theme-public-asset?id=<asset-id>` is intentionally limited to login-screen assets from the active published theme profile. The route does not expose arbitrary theme assets or VFS blobs. Saving or loading an authenticated active theme profile republishes the safe login asset references.

If an existing deployment has an active theme profile that was saved before this ROI, sign in once and save/apply the theme again to refresh the public-login registry.

## Validation

Regression test `T076` checks for the public-login asset route, public URL rewrite, boot route advertisement, viewer loop control, right taskbar option, desktop surface taskbar padding, ROI CSS marker, right-position CSS, and documentation.

Run:

```mumps
ZLINK "MIOOS"
ZLINK "MIOOSAPI"
ZLINK "MIOOSST"
ZLINK "MIOOSTHEME"
ZLINK "MIOOST"
DO ^MIOOST
```

Also run JavaScript syntax checks for touched browser files:

```bash
node --check public/mioos/app/mioos_core.js
node --check public/mioos/app/mioos_shell_ui.js
```
