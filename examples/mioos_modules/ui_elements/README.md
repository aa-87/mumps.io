# UI + Form Elements Example

This example is a standalone, interactive component gallery for MIOOS module developers.

```text
componentKey = ui-elements
surface      = mioos-surface-ui-elements
script       = /public/mioos/app/mioos_modules.js
```

It intentionally does **not** depend on the backend table dataset. This keeps the UI examples available even when table datasets are being rewritten, and avoids example launches producing table mutation/query errors.

## What the gallery demonstrates

- text input, textarea, select, date, and number controls
- radio groups and checkbox groups
- switch/toggle controls
- required, optional, disabled, and read-only states
- validation messages and validation summary
- loading/saving state
- file-picker metadata capture with an HTTP-upload-only pattern
- inline help text
- form sections and tabbed form organization
- modal form and destructive-action confirmation dialog
- toast/status feedback
- empty and error state messaging
- accessible labels, `role="status"`, `role="dialog"`, and `role="alertdialog"`

## Copy/adapt pattern

1. Register a component with `window.MIOOSModules.registerComponent` or server-side through `MIOOSMOD`.
2. Give the module a stable `componentKey` and `surface`.
3. Keep draft form state local until the user saves.
4. Submit through authenticated HTTP routes for persistence.
5. Let the backend sanitize, authorize, validate, audit, and return user-facing status.
6. Never use DataURLs for persisted files or images.
