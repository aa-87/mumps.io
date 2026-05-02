# ROI 64B — UI Modules examples gallery rewrite

## Goal

Rewrite the UI Modules examples so they are interactive, production-style references instead of static table rows or raw demo HTML.

## Contract

The UI + Form Elements example is now a standalone Vue 3 Options API UMD surface:

```text
componentKey = ui-elements
surface      = mioos-surface-ui-elements
script       = /public/mioos/app/mioos_modules.js
```

The surface is intentionally local-state-first. It demonstrates form behavior without requiring table query/mutation calls, which prevents example launches from producing backend table errors.

## Included examples

The gallery covers text input, textarea, select, radio group, checkbox group, toggle/switch, date input, number input, file picker metadata capture using an HTTP upload pattern, validation messages, required/optional indicators, disabled/read-only states, loading/saving state, inline help, form sections, tabbed forms, modal form, confirmation dialog, toast/status feedback, empty and error states, and accessible labels/ARIA roles.

## Backend-safety rules

- The example does not serialize files to DataURLs.
- The file picker captures metadata only and documents authenticated HTTP upload behavior.
- Sample save uses a local simulation so the reference can launch without requiring a backend dataset.
- Production modules must still use backend-owned routes for persistence, validation, audit, and authorization.

## Registry behavior

`MIOOSMOD` advertises `ui-elements` as both a component and a module. The module no longer launches through `mioos-surface-table`.

## Next ROI

ROI 64C should rewrite the advanced table component itself as a configurable, standalone, production-ready table for internal and user-created modules.
