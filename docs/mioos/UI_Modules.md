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
