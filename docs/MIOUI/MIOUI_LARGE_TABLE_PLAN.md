# MIOUI Large Table Plan

## Goal

Add a very large SSR-first table surface for billing and operator work.

This layer must show how MIOUI handles:

- server pagination
- grouped filters
- active filter chips
- explicit sort ownership
- visible column ordering
- density presets
- pinned identity column
- row expansion
- page footer totals
- saved views and selection summary

## ROI 9 delivered now

The current ROI adds:

- `MIOUILGT.m`
- `/mioui/large-table` demo route
- `mioui_large_table_toolbar.html`
- `mioui_large_table_density_switcher.html`
- `mioui_large_table_filters.html`
- `mioui_large_table_column_order.html`
- `mioui_large_table_footer_totals.html`
- `mioui_large_table_pagination.html`
- `mioui_large_table.html`
- `MIOUIT019.m`

## Current contract direction

Recommended top-level shape:

- `large.<key>.title`
- `large.<key>.lead`
- `large.<key>.query`
- `large.<key>.page / per / total / lastPage`
- `large.<key>.insight(*)`
- `large.<key>.pref(*)`
- `large.<key>.selection(*)`
- `large.<key>.density(*)`
- `large.<key>.perOption(*)`
- `large.<key>.filterGroup(*)`
- `large.<key>.activeFilter(*)`
- `large.<key>.col(*)`
- `large.<key>.order(*)`
- `large.<key>.row(*)`
- `large.<key>.row(n).cell(*)`
- `large.<key>.totalCell(*)`

## Next table-depth targets

### P2

- multi-column sort stack
- virtual window jumping
- row grouping by payer or owner
- stronger sticky-header behavior

### P3

- export current view
- facet summary bar
- keyboard-review shortcuts
- saved user layouts
