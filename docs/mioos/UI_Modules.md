# MIOOS UI Modules

The module registry is installed but disabled by default in boot state. The App Catalogue fetches the registry after sign-in through `/api/mioos/modules/catalog`.

Built-in catalogue entries include:

- App Catalogue
- Table Samples
- Massive Dataset Table
- Permissions UI
- UI + Form Elements
- Patient Registration

The module catalogue can launch table-backed surfaces by setting:

```json
{
  "componentKey": "table",
  "surface": "mioos-surface-table",
  "tableState": { "dataset": "patient-registration" }
}
```

Permissions UI uses `mioos-surface-permissions` and demonstrates tabbed permission panels, role matrix toggles, and an audit sample.

## ROI 64B UI elements example rewrite

`UI + Form Elements` is no longer table-backed. It now launches as a standalone component gallery:

```json
{
  "componentKey": "ui-elements",
  "surface": "mioos-surface-ui-elements"
}
```

The gallery is interactive and stateful. It demonstrates text inputs, textareas, selects, radio groups, checkbox groups, switches, date and number inputs, file-picker metadata capture, validation, required/optional indicators, disabled/read-only states, saving/loading states, inline help, tabbed form sections, modal forms, confirmation dialogs, toasts, empty states, and error states.

The example intentionally avoids backend table coupling. Production modules should copy the interaction and accessibility patterns, then submit sanitized payloads through authenticated backend routes for persistence and audit.
