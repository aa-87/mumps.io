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

## Relationship to ROI 64B UI examples

The `UI + Form Elements` example is no longer implemented as a table dataset. Table modules should still use `mioos-surface-table`, but UI/form examples now use `mioos-surface-ui-elements` so form reference behavior remains stable while the advanced table component is rewritten in ROI 64C.


## ROI 64C standalone configuration

The table example now targets `mioos-advanced-table-v4`. Use `window.MIOOSTable.createConfig()` from internal UI code, or place equivalent safe JSON in a module manifest. Prefer feature gates over custom table forks so internal and user-created modules share the same query/mutation behavior.

## DataTables-style server-side integration

The example now targets `mioos-advanced-table-v4`. The native MIOOS table request includes `draw`, `start`, `length`, `order`, and `columns` fields so developers familiar with DataTables can reason about server-side paging and ordering without adopting jQuery/DataTables as a dependency.

Do not load DataTables in MIOOS modules. Use the built-in `mioos-full-table` / `mioos-surface-table` component and configure it with safe JSON or `window.MIOOSTable.createConfig()`.
