# Table UI Module Example

This example demonstrates the first reusable MIOOS UI module component: the backend table.

## Files

- `module.json` — user-module manifest.
- `table_module.mjs` — optional browser-side registration shim for custom bundles.

## How it works

The manifest launches a window with:

```text
componentKey = table
surface      = mioos-surface-table
backend      = MIOOSTBL
route        = /api/mioos/table/query
```

The shell resolves the surface and renders `mioos-full-table`. Data remains backend-owned.

## Next steps for a real module

1. Copy `module.json`.
2. Change `id`, `key`, `appKey`, `title`, and `description`.
3. Point `config.dataset` at a backend dataset supported by your query routine.
4. Register the manifest in the user module global or add it as an internal module in `MIOOSMOD`.
