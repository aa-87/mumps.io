# ROI 64 — UI Modules and Advanced Table Rewrite Plan

ROI 64 starts the dedicated UI Modules redesign track. The goal is to stop treating examples as static demo screens and establish production-grade, documented surfaces that internal shell tools and user-created modules can reuse.

## Product direction

The next ROIs are dedicated to UI Modules before unrelated feature work:

1. **ROI 64A — Catalogue and standalone table foundation**: rewrite the App Catalogue / UI Modules browser, define the `mioos-advanced-table-v2` client contract, add a configurable table component shell, and harden table mutation routes for column visibility.
2. **ROI 64B — Table implementation hardening**: finish server/client validation, filters, typed editors, keyboard model, cell renderers, table presets, and row/column mutation tests.
3. **ROI 64C — UI examples rewrite**: replace static UI elements with interactive forms, validation, upload pattern, modal/confirmation/toast examples, and documented copy/adapt guidance.
4. **ROI 64D — Module author workflow**: add module creation/editing metadata flow backed by server-side persistence and sanitized schema validation.
5. **ROI 64E — Patient registration module**: build the end-to-end patient registration sample on top of the rewritten table and form patterns.

## Catalogue contract

The catalogue is now a searchable launcher/developer hub, not a static list. It must provide:

- sections for Modules, Components, and Examples;
- search across key/title/description/source/category/path;
- category and source filters;
- card/list view toggle;
- empty/loading/error states;
- keyboard-friendly cards using Enter to launch;
- built-in/user/source badges;
- launch routing through the existing MIOOS window manager and module host.

## Standalone table contract

The table component advertises `mioos-advanced-table-v2` and is designed to be used from internal shell surfaces or user-created modules without custom app code.

Minimum integration:

```html
<mioos-full-table
  table-id="orders-table"
  title="Orders"
  dataset="orders"
  :config="tableConfig">
</mioos-full-table>
```

Client configuration:

```javascript
var tableConfig = window.MIOOSTable.createConfig({
  features: {
    datasetSwitcher: false,
    search: true,
    grouping: true,
    columnPicker: true,
    rowCrud: true,
    columnCrud: false,
    selection: true,
    bulkActions: true,
    pagination: true,
    rowDetails: true
  },
  emptyMessage: 'No orders match this view.'
});
```

The browser may choose UI affordances, but the backend remains authoritative for query/mutation results. Bulk data remains HTTP-first through `/api/mioos/table/query` and `/api/mioos/table/mutate`.

## Mutation safeguards introduced in ROI 64A

- `column.visibility` is a first-class mutation.
- Column keys are server-sanitized before column save/resize/visibility operations.
- Invalid actions without a dotted namespace are rejected early.
- The table client persists column visibility through the mutation route instead of only hiding columns locally.

## Non-goals for ROI 64A

ROI 64A does not finish the full final UI/forms/patient sample rewrite. It creates the foundation and locks the new direction before the larger component rebuilds.
