# MIOUI Detailed Data Table Plan

## Goal

Create a high-density SSR-first data table system for billing and operator applications.

This layer is not a browser-side spreadsheet. It is a server-owned review surface.

The table must stay:

- fast on the server
- predictable in HTML output
- friendly to audit and trace workflows
- usable on wide billing screens
- safe for large datasets through pagination and explicit server state

## ROI 8 delivered now

The current ROI adds the first-pass detailed table layer:

- `MIOUIDTG.m` builder routine
- `MIOUIDTGD.m` standalone demo page and route
- `mioui_table_insights.html`
- `mioui_selection_summary.html`
- `mioui_grid_header_cell.html`
- `mioui_grid_row_meta.html`
- `mioui_data_grid.html`

### Current capabilities

- row metadata in the first column
- sortable-header contract display
- explicit selection summary
- combined table insights panel
- row-level actions
- dense SSR markup for billing review queues

## Contract direction

The detailed table contract should keep state on the server.

Recommended top-level shape:

- `grid.<key>.title`
- `grid.<key>.lead`
- `grid.<key>.insight(*)`
- `grid.<key>.pref(*)`
- `grid.<key>.selection(*)`
- `grid.<key>.col(*)`
- `grid.<key>.row(*)`
- `grid.<key>.row(n).cell(*)`
- `grid.<key>.row(n).action(*)`

## Near-term roadmap

### P1

- server sort contract refinement
- footer totals row
- table-level empty-state variants
- reusable result summary strip

### P2

- density switcher
- column pinning
- row expander
- nested evidence preview rows
- sticky header and sticky identity column support

### P3

- saved layouts per user
- keyboard-review affordances
- diff-aware row highlighting
- stronger export/review crossover surfaces

## Design rules

- keep pagination server-owned
- keep filters server-owned
- keep sorting server-owned
- avoid hiding key row identity
- prefer badges and compact metadata over large cards inside rows
- make bulk actions explicit and reversible
- keep row actions short and stable

## Billing-specific expectations

A detailed billing grid should handle:

- claim id and patient identity summary
- date of service
- CPT / HCPCS / revenue code columns
- charge and unit columns
- status badges
- diagnostics preview hooks
- trace / audit links
- export and publish state

## Testing direction

Every detailed-table layer should have:

- builder contract tests
- render smoke tests
- route registration tests for demo pages
- registry metadata coverage
- planned-roadmap metadata coverage
