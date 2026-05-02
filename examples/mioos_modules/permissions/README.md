# Permissions UI Module

This example documents the built-in `permissions` component registered by `public/mioos/app/mioos_permissions.js`.

The component is intentionally HTTP-first and reuses the existing VFS metadata routes:

- `POST /api/mioos/fs/meta`
- `POST /api/mioos/fs/setmeta`

It does not introduce a separate permissions architecture. The UI edits the same owner-role flag metadata already enforced by `MIOOSFS`.

## ROI 63 note

The permissions sample remains a separate reference surface. It should continue to reuse existing VFS metadata and authorization rules rather than introducing a parallel permissions architecture during the App Catalogue, table, form, and patient registration redesign sequence.
