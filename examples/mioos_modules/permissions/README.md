# Permissions UI Module

This example documents the built-in `permissions` component registered by `public/mioos/app/mioos_permissions.js`.

The component is intentionally HTTP-first and reuses the existing VFS metadata routes:

- `POST /api/mioos/fs/meta`
- `POST /api/mioos/fs/setmeta`

It does not introduce a separate permissions architecture. The UI edits the same owner-role flag metadata already enforced by `MIOOSFS`.
