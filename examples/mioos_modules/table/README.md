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

## ROI 63 table rewrite target

ROI 66 will rewrite the table component around a deterministic HTTP-first state model. Table examples should target `POST /api/mioos/table/query` and `POST /api/mioos/table/mutate`, including row CRUD, column CRUD, `column.visibility`, select-all-visible, grouping, search, pagination, sorting, loading/error/empty states, and keyboard-accessible controls.

Do not copy Explorer internals into table modules. The table component may follow Explorer-like details interactions, but table state remains owned by the table dataset and backend contract.

## ROI 64A standalone configuration example

Use the table as a standalone module component:

```html
<mioos-full-table
  table-id="module-orders"
  title="Orders"
  dataset="orders"
  :config="window.MIOOSTable.createConfig({ features: { datasetSwitcher: false, columnCrud: false } })">
</mioos-full-table>
```

The table remains HTTP-first. Module authors configure client affordances, while `/api/mioos/table/query` and `/api/mioos/table/mutate` remain the source of truth for rows, schema, pagination, actions, and persisted column visibility.
