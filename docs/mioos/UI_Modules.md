# MIOOS UI Modules

MIOOS UI Modules are the supported way to add user-created or internal application screens without changing the shell architecture. A module is a small manifest plus one or more registered UI components. The shell owns window chrome, authentication, boot state, routing, and theme variables; the module owns only its screen contract and component configuration.

## Contract

Current contract: `mioos-ui-module-v1`.

A module catalog entry contains:

| Field | Required | Purpose |
| --- | --- | --- |
| `id` | yes | Stable module identifier, for example `mioos.ui.table`. |
| `key` | yes | Launch key shown to the Start menu/catalog. |
| `appKey` | yes | Window `appKey`. Use the same value as `key` unless a module exposes multiple launchers. |
| `title` | yes | Human-readable title. |
| `description` | recommended | Start menu/catalog summary. |
| `source` | yes | `internal` or `user`. |
| `category` | recommended | Catalog grouping. |
| `icon` | recommended | Short glyph used by the shell. |
| `componentKey` | yes | Registered UI component key. |
| `surface` | recommended | Vue shell surface component, for example `mioos-surface-table`. |
| `config` | optional | Module-specific configuration. |

A component catalog entry contains:

| Field | Required | Purpose |
| --- | --- | --- |
| `key` | yes | Stable component key, for example `table`. |
| `name` | yes | Vue component name, for example `mioos-full-table`. |
| `title` | yes | Human-readable name. |
| `surface` | yes | Window surface component. |
| `source` | yes | `internal` or `user`. |
| `backend` | optional | Backend routine or service used by the component. |
| `queryRoute` | optional | HTTP route used by the component. |
| `features` | optional | Feature list for docs/catalog display. |

## Availability and launch behavior

The UI Module catalog is installed but not launch-enabled by default. To expose the UI Modules app/catalog in boot state, enable both:

```mumps
SET CONF("mioos","modules","enabled")=1
SET CONF("mioos","modules","appCatalogEnabled")=1
```

When either flag is off, `boot.desktop.moduleSystem.enabled` or `boot.desktop.moduleSystem.appCatalogEnabled` remains `0`, and the legacy `folder-properties` window keeps its stable window index. The backend catalog and component registration code can exist in the source tree without changing the default shell surface.

## Backend flow

1. `MIOOSMOD` builds the catalog from internal definitions and per-user globals under `^MIO("MIOOS","MODULE","USER",principal,...)`.
2. `MIOOSST` injects the catalog into boot as `boot.uiModules` and keeps a launchable legacy list in `boot.modules` for existing Start menu logic.
3. `MIOOSAPI` exposes `/api/mioos/modules/catalog` for refresh without reloading the shell.
4. `MIOOSWS` serves the same catalog through `module.catalog` for existing websocket clients.

## Client flow

1. `mioos_modules.js` loads before component scripts.
2. Component scripts register themselves with `window.MIOOSModules.registerComponent(...)` and optionally `registerModule(...)`.
3. `mioos_core.js` mixes in module runtime methods and registers module Vue surfaces.
4. `mioos_shell_ui.js` delegates module windows to `MIOOSModules.resolveSurface(...)`.
5. The UI Modules app lists components, modules, and examples.

## First component: Backend Table

The first registered component is `table`.

- Vue component: `mioos-full-table`
- Surface: `mioos-surface-table`
- Backend: `MIOOSTBL`
- Route: `/api/mioos/table/query`
- Example folder: `examples/mioos_modules/table`

The table supports backend pagination, sorting, filtering, column visibility, column grouping, expansion rows, row actions, bulk actions, selection, and resizable columns.

## Creating a user module

Use the example manifest as a starting point:

```json
{
  "id": "user.reports.example",
  "key": "user.reports.example",
  "appKey": "user.reports.example",
  "title": "Reports",
  "description": "User-created reporting module",
  "source": "user",
  "category": "Reports",
  "icon": "▤",
  "componentKey": "table",
  "surface": "mioos-surface-table",
  "config": {
    "dataset": "demo"
  }
}
```

For DB-backed user modules, store equivalent fields under:

```text
^MIO("MIOOS","MODULE","USER",principal,moduleId,...)
```

Example:

```mumps
SET ^MIO("MIOOS","MODULE","USER","admin","user.reports.example","title")="Reports"
SET ^MIO("MIOOS","MODULE","USER","admin","user.reports.example","componentKey")="table"
SET ^MIO("MIOOS","MODULE","USER","admin","user.reports.example","surface")="mioos-surface-table"
```

## Rules

- Do not bypass shell window chrome.
- Do not create global browser state outside the module registry.
- Use boot routes instead of hard-coded API paths when possible.
- Keep user modules data-driven; add backend routines only when the component needs privileged data access.
- Register components before `MIOOSCore.mount()` by loading scripts in `templates/layouts/mioos_shell.html`.
- Keep examples runnable and small.

## Test coverage

`D ^MIOOST` includes UI module coverage for:

- backend registry routine,
- boot catalog injection,
- HTTP route and API handler,
- websocket catalog compatibility,
- client runtime registry,
- table component registration,
- UI Modules surface,
- shell surface resolution,
- docs and examples.

## WebSocket-only module communication

Module communication is now WebSocket-only from the browser. User and internal modules must use the core shell command bus instead of `fetch()` or module-specific HTTP endpoints.

Required command pattern:

```javascript
this.command('module.catalog', {})
this.command('module.table.query', { dataset: 'demo', page: 1, pageSize: 25 })
this.command('permission.upsert', { kind: 'permission', key: 'example.view', name: 'View Example' })
```

Rules for module authors:

- Do not call `/api/mioos/modules/catalog` from module UI code.
- Do not call `/api/mioos/table/query` from module UI code.
- Use `module.table.query` for the reusable table component.
- Use explicit permission commands for administrative mutations.
- Keep all privileged operations in MUMPS routines and expose them through `MIOOSWS` commands.
- Include a `requiredPermission` field in module manifests when a module performs privileged work.

## Permissions module

The internal `permissions` component is the reference module for security administration.

- Component key: `permissions`
- Vue component: `mioos-permissions-admin`
- Surface: `mioos-surface-permissions`
- Backend routine: `MIOOSPERM`
- Transport: `websocket-only`
- Example folder: `examples/mioos_modules/permissions`

The module reuses `mioos-full-table` for every administrative grid:

| Dataset | Purpose |
| --- | --- |
| `permissions` | Individual permission definitions, including PHI and sensitive flags. |
| `permission-groups` | Named collections of permissions. |
| `permission-profiles` | Assignable profiles composed from permission groups. |
| `permission-assignments` | User/role to profile assignments. |
| `permission-audit` | Non-PHI administrative audit events. |

Administration commands:

| Command | Purpose |
| --- | --- |
| `permission.upsert` | Add or edit permissions, groups, and profiles. |
| `permission.delete` | Delete permissions, groups, profiles, or assignments. |
| `permission.assign` | Assign a profile to a user or role. |
| `permission.effective` | Inspect effective access for the current principal. |

The permissions module is HIPAA-aligned: it models minimum necessary access, PHI-related permission flags, sensitive/break-glass permissions, and an administrative audit trail. It does not by itself certify a deployment as HIPAA compliant; deployment policy, hosting, encryption, retention, BAAs, and operating procedures are still required.
