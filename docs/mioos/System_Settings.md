# MIOOS System Settings

ROI 63A adds a protected, server-backed settings registry for the MIOOS shell. The GUI is available from **Start → System Settings** / **Control Panel** after authentication.

## Contract

The HTTP payload contract is `mioos-system-settings-v1`.

Routes:

- `POST /api/mioos/settings/load`
- `POST /api/mioos/settings/save`

Both routes are protected by the MIOOS authentication contract. Saving settings requires an authenticated administrator role. Operators can inspect the active values, but non-admin users cannot persist changes.

## Persistence model

Settings are stored under MIOOS globals and are applied to `CONF` during MIOOS boot/state loading through `MIOOSCFG`. The browser is not authoritative; it only edits a draft and submits it to the server. The server validates every setting by registry key before persisting it.

## Safeguards and sanitization

The settings registry intentionally exposes a curated set of safe MIOOS controls instead of accepting arbitrary global paths. Each setting has:

- a stable setting key;
- a mapped `CONF` path;
- a type (`boolean`, `integer`, or `enum`);
- a default value;
- explanatory copy for the GUI;
- an apply/restart note;
- optional minimum/maximum bounds or enum options.

Boolean values are normalized to `1` or `0`. Integer values are clamped to server-defined minimum and maximum bounds. Enum values must match the allowed option list or the save is rejected. Unknown keys are rejected.

## Default App Catalogue behavior

The MIOOS module system and App Catalogue are now enabled by default:

```mumps
CONF("mioos","modules","enabled")=1
CONF("mioos","modules","appCatalogEnabled")=1
```

Administrators can disable either setting from the GUI. Disabling is persisted server-side and applied to future boot/view state. When enabled, the App Catalogue remains server-authored through `MIOOSMOD` and rendered by the thin Vue Options API browser layer.

## Current setting groups

- **Modules and App Catalogue** — module system, catalogue visibility, dynamic module windows, launcher mode.
- **Transport, uploads, and VFS** — HTTP-first file transfer transport, upload chunk size, concurrency, batch size, and inflight limits.
- **WebSocket pool** — socket pool limits, heartbeat, diagnostics.
- **Desktop shell** — density and start menu style defaults.
- **Security and audit** — audit enablement, retention, report limits, management row limits.
- **Developer diagnostics** — debug center enablement and event limit.

## Non-goals

This GUI is not a raw global editor and must not become one. Any future MIOOS setting added to the GUI must be added to the `MIOOSCFG` registry with explicit type validation, bounds or enum values, docs, and tests.
