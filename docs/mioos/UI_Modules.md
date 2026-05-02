# MIOOS UI Modules

The module registry is installed and enabled by default in boot state. The App Catalogue fetches the registry after sign-in through `/api/mioos/modules/catalog`, and administrators can disable or re-enable it from System Settings.

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

## ROI 63A default module visibility

The App Catalogue is no longer launch-disabled by default. `CONF("mioos","modules","enabled")` and `CONF("mioos","modules","appCatalogEnabled")` default to `1`, and administrators can change them in **System Settings → Modules and App Catalogue**. The registry is still server-authored by `MIOOSMOD`; the GUI setting only controls whether catalogue manifests are injected into boot/view state.
