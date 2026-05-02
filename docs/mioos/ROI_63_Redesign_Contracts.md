# ROI 63 — Redesign Contracts for App Catalogue, Modules, Tables, Forms, and Patient Registration

ROI 63 is a baseline and contract-locking pass. It intentionally does not rewrite runtime UI yet. Its purpose is to document the production redesign target and pin the non-regression rules that ROI 64 through ROI 69 must follow.

## Baseline verified from source inspection

The current source keeps MIOOS as a stateful, server-authored shell. Boot state is still owned by `MIOOSST`; UI module manifests are owned by `MIOOSMOD`; table data and mutations are owned by `MIOOSTBL`; HTTP routes are registered through `MIOOS` and handled by `MIOOSAPI`; shell control and realtime commands remain websocket-capable through `MIOOSWS`; browser code remains split under `public/mioos/app/` and uses Vue 3 Options API UMD.

The module registry is installed in source, but the launchable module system is disabled by default in boot state. The source contract is:

- default boot: `desktop.moduleSystem.enabled=0`
- default boot: `desktop.moduleSystem.appCatalogEnabled=0`
- default boot: no UI Modules launcher app is injected
- opt-in boot: set both `CONF("mioos","modules","enabled")=1` and `CONF("mioos","modules","appCatalogEnabled")=1`
- opt-in boot: `MIOOSMOD` emits the `mioos-ui-module-v1` catalog and `MIOOSST` injects launchable module state

Do not confuse the installed registry/API with an enabled launcher. The default disabled behavior is a regression gate.

## Cross-cutting redesign rules

1. Preserve the MUMPS-first architecture. Do not introduce a frontend framework, TypeScript, a build step, Node/Express, or a SPA-owned application model.
2. Keep browser code in Vue 3 Options API UMD files under `public/mioos/app/`.
3. Use WebSocket-first communication for table query/mutation and shell/module control, with protected HTTP fallback routes where needed. Performance-critical VFS uploads/downloads may continue using the configured HTTP/WS transfer path.
4. Do not use DataURLs for persisted uploads or images. Assets must be stored server-side and referenced through authenticated internal URLs after login.
5. Do not emit protected asset URLs into pre-login first paint.
6. Tests stay quiet on success and explicit on failure.
7. Each ROI must update docs, tests, and `mioos_llm.md` when behavior changes.
8. Rewrite rough surfaces cleanly instead of patching individual UI symptoms, but keep public contracts stable unless an ROI explicitly updates tests and docs.

## App Catalogue contract — target for ROI 64

The App Catalogue becomes a production launcher and developer hub, not a raw module dump.

Required behavior:

- Preserve the disabled-by-default boot contract.
- Render only when the module system and app catalog are enabled in boot state.
- Provide search across title, key, category, description, and source.
- Provide category filters and source filters for internal, user, and built-in modules.
- Display clear built-in/user/source/status badges.
- Support cards and list mode without raw unstyled fallback markup.
- Make module cards keyboard reachable and launchable with Enter/Space.
- Show loading, empty, and error states.
- Use robust host error handling when a module cannot resolve its component or surface.
- Launch table-backed modules through `mioos-surface-table` and their declared `tableState`.
- Launch permissions and future custom modules through declared `surface` and `componentKey` values.

## Module creation contract — target for ROI 65

Module creation is a developer workflow inside the App Catalogue or a related developer surface. It should let a developer create metadata-backed module entries without editing source files.

Allowed metadata fields:

- `key`
- `title`
- `category`
- `icon`
- `description`
- `componentKey`
- `surface`
- `dataset`
- `route` or route hints
- capability hints such as `requiresAuth`, `table`, `forms`, or `audit`

Validation requirements:

- Validate keys/names on the client for immediate feedback.
- Validate keys/names on the server before persistence.
- Reject blank keys, duplicate keys for the same owner, control characters, and keys outside the documented safe identifier grammar.
- Persist user-created module metadata under existing MIOOS-owned globals/routines.
- Provide preview before save.
- Support edit/delete for user-created definitions only.
- Built-in module definitions remain source-owned.

## Advanced table contract — target for ROI 66

The table component must be rewritten around a stable internal state model and a deterministic WebSocket-first backend contract with authenticated HTTP fallback.

### Query route

`POST /api/mioos/table/query`

```json
{
  "dataset": "patient-registration",
  "page": 1,
  "pageSize": 25,
  "search": "smith",
  "filters": {
    "status": ["Active"]
  },
  "sort": {
    "column": "lastName",
    "direction": "ascending"
  },
  "groupBy": "status",
  "columns": [
    { "key": "lastName", "hidden": false, "width": 180 }
  ]
}
```

### Query response

```json
{
  "ok": true,
  "dataset": "patient-registration",
  "schema": { "columns": [] },
  "rows": [],
  "groups": [],
  "pagination": {
    "page": 1,
    "pageSize": 25,
    "totalRows": 0,
    "filteredRows": 0,
    "pageRows": 0,
    "pageCount": 1
  },
  "rowActions": [],
  "bulkActions": [],
  "features": {}
}
```

### Mutation route

`POST /api/mioos/table/mutate`

```json
{
  "dataset": "patient-registration",
  "action": "row.save",
  "row": {
    "id": "optional-existing-id",
    "firstName": "Ada",
    "lastName": "Lovelace"
  }
}
```

Required mutation actions:

- `row.save`
- `row.delete`
- `rows.delete`
- `column.save`
- `column.delete`
- `column.resize`
- `column.visibility`

Every mutation should return a fresh query-shaped table payload, or a documented mutation result with a refetch directive. Prefer a fresh query-shaped payload for client consistency.

Required table UX behavior:

- reliable sorting, pagination, filtering, and search
- select all visible rows
- selected-row count/status
- multi-row actions and bulk actions with confirmation
- row create/edit/delete with validation
- column create/edit/delete/resize/visibility
- grouping only when grouping is active
- working group expand/collapse
- no row expand arrow unless row details or grouping require it
- strong loading, empty, and error states
- keyboard and screen-reader friendly controls
- predictable developer integration API for module authors

## UI/form sample contract — target for ROI 67

The UI/form sample must become a polished developer reference module rather than demo rows or raw HTML.

It must include production patterns for:

- text input
- textarea
- select
- radio group
- checkbox group
- toggle/switch
- date input
- number input
- file picker/upload pattern using HTTP
- validation messages
- required/optional indicators
- disabled and read-only states
- loading and saving states
- inline help
- form sections
- tabbed forms
- modal forms
- confirmation dialogs
- toast/status feedback
- accessible labels and ARIA hints

## Patient registration contract — target for ROI 68

Patient registration must be a full end-to-end module that combines the redesigned App Catalogue, table, and form systems.

Required behavior:

- App Catalogue entry
- authenticated module host surface
- backend CRUD persistence
- patient list/table
- create/edit patient form
- row create/edit/delete
- search/filter/sort by relevant demographic and status fields
- validation for required demographics and contact fields
- sample audit/status messages
- no PHI leakage before authentication
- documentation that says MIOOS is HIPAA-ready in architecture only and still requires deployment and operations controls

## Hardening contract — target for ROI 69

The final hardening pass must review:

- error boundaries
- loading states
- empty states
- keyboard navigation
- screen-reader labeling
- mobile/responsive behavior
- stale/dead code introduced during rewrites
- docs consistency
- regression tests for the entire redesigned flow
