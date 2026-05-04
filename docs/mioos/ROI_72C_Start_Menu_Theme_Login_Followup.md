# ROI 72C Follow-up — Start Menu Folders, Theme Login, and Text Viewer Stability

## Goal

Finish the Start Menu rewrite without regressing shell behavior, restore Theme Studio upload/login behavior, and fix text-file viewer loading.

## Implemented

- Start Menu groups are explicitly expandable/collapsible.
- VFS folder items in the Start Menu can expand in place.
- Nested subfolders reuse the same `fs.list` lazy-load path and render recursively in the launcher list.
- The popup Start Menu variant can be moved like a modal by dragging its header.
- Initial boot now defaults to the server/client `Glow` theme when no server profile or explicit user-applied local theme exists.
- Theme Studio image uploads now tolerate empty or malformed backend error responses and keep the upload input reusable.
- Runtime login now uses the Theme Studio login surface: background, avatar, warning image/title, and disclaimer text.
- Pre-auth protected asset URLs remain sanitized before login.
- Text-file windows fall back to the authenticated HTTP blob endpoint if WebSocket range/full reads return an empty or variant payload.

## Validation

Run:

```bash
node --check public/mioos/app/mioos_core.js
node --check public/mioos/app/mioos_shell_ui.js
node --check public/mioos/app/mioos_explorer.js
```

When YottaDB / GT.M is available:

```mumps
ZLINK "MIOOSST"
ZLINK "MIOOST"
DO ^MIOOST
```
