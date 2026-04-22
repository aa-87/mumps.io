# MIOOS HIPAA-Aware Technical Posture

## Important limitation

This document does **not** mean MIOOS is legally certified, audited, or automatically HIPAA compliant.

HIPAA compliance depends on the full environment:

- hosting
- access control
- encryption
- logging
- retention
- operational processes
- vendor agreements / BAA posture

What MIOOS can do is maintain a technical posture that supports HIPAA-sensitive use.

## Technical principles

### 1. Server-owned policy

Sensitive policy should remain server-authored in MUMPS routines rather than delegated to the browser.

### 2. Least privilege

Use role-based and attribute-based authorization through the MIO auth stack.

### 3. Minimize client exposure

Do not send PHI to the browser unless the current desktop surface truly requires it.

### 4. Session hygiene

Use explicit sign-in/sign-out, revocable sessions, bounded JWT/session lifetimes, and auditable identity claims.

### 5. Transport security

Production deployment should require TLS and secure cookie posture.

### 6. Auditability

Security-relevant actions should be loggable and attributable to authenticated principals.

### 7. Storage discipline

Large or sensitive payloads should remain MAXSTRING-safe and should prefer server-side globals or `^TMP($J,...)` buffers where appropriate.

## Current project alignment

Current MIOOS work already aligns with this posture by emphasizing:

- SSR and server-authored boot/view contracts
- local auth/session plumbing over the MIO auth stack
- structured errors
- quiet tests and explicit contracts
- no Node runtime assumptions
- no `ZSYSTEM`

## What still needs to happen

To move closer to HIPAA-ready operation, later ROIs should add or harden:

- stronger authz boundaries per desktop app and file/action
- auditable chat and collaboration events
- session timeout and device/session management UX
- secure terminal attach and debugger authz
- PHI-aware file playback permissions and logging
- deployment guidance for encryption, cookies, logs, and backups


## Transfer integrity note
Direct authenticated HTTP blob/range delivery reduces browser-side transfer complexity for binary files, which is helpful operationally, but it does not replace audit logging, encryption, access controls, or deployment policy.


## Transfer cleanup note
Automatic cleanup of abandoned upload/download staging reduces the chance of stale transfer payloads lingering longer than necessary in server globals. This is a helpful operational hardening step, but it still needs to be paired with deployment-level retention, encryption, logging, and access-control policy.


## ROI 22 — Transport diagnostics and socket health
- Added a Diagnostics desktop app/window so the shell can inspect the advertised websocket contract, active transfer counts, terminal usage, and client-side socket telemetry without leaving the desktop.
- `transport.health` now returns session-scoped transport health including socket pool limits, heartbeat/resume settings, upload/download activity, and open terminal counts.
- The browser now records core and FS worker socket state transitions, pending request counts, last events, and recent socket errors for diagnostics.


## ROI 23 — Module catalog and built-in module host
- Landed a server-authored module registry in the boot contract with manifest versioning, launcher metadata, and built-in module descriptors.
- Added an App Catalog window plus reusable module-host windows so built-in modules can ship on the same chrome and transport contract as core MIOOS apps.
- Added built-in Notes and Ops Center modules as the first module-host examples, alongside a `module.catalog` websocket command for refresh and later extensibility work.


ROI 24 — Typed authentication, local/framework auditability, and HIPAA reportability
- Local sign-in remains the primary provider.
- Guest mode is disabled by default and unauthenticated access to protected API and websocket surfaces is blocked.
- Auth events are written to the MIOOS audit log for security review, HIPAA-oriented auditability, and export reporting.

## ROI 25 — Session governance, account lockout administration, and auditable security operations
- Extended the Security Center with active session visibility, revocation controls, account lockout visibility, and administrative unlock actions.
- Added websocket commands for `auth.sessions`, `auth.session.revoke`, `auth.accounts`, and `auth.user.unlock`.
- Kept guest mode disabled and all live shell access authenticated while adding more HIPAA-oriented operational visibility for session and account risk handling.

## ROI 26 — Password policy, rotation, and credential health

This ROI adds typed password policy defaults, forced password change support for bootstrap accounts, one-time password rotation tokens, self-service password change, and credential health reporting. The Security Center now surfaces password posture metrics such as rotation-required, expired, warning, and healthy accounts, supporting HIPAA-oriented access hygiene, auditability, and administrative review.



## ROI 27 — Debug Center and developer tools
- Added a built-in Debug Center desktop app/window for server snapshot inspection, command registry visibility, and recent websocket activity.
- Added websocket command `debug.snapshot` in `MIOOSWS` so developers can inspect shell counts, routes, transport posture, auth posture, and module manifests without relying on extra HTTP endpoints.
- Added bounded client-side websocket event history in the shell so recent command and message activity can be inspected inside MIOOS while preserving the existing websocket-first model.

## ROI 34 — Upload commit reconciliation and missing-chunk self-heal
- Hardened HTTP binary uploads so Explorer reconciles staged server state through `fs.upload.status` before commit instead of assuming every acknowledged chunk is durably complete.
- When the server reports a gap, the client now rewinds to the next missing chunk, replays the missing range, and only then retries final commit.
- This reduces false-finalize failures such as `fs_upload_commit_failed` with `missing_chunk` under concurrent or bursty upload conditions.



## UI reset note

The shell reset does not change the HIPAA-aware posture directly. Its main compliance benefit is reducing front-end fragility so auth state, audit surfaces, and security dialogs remain readable and usable under a single shell contract.

ROI 52 — theme system 2.0 and unified shell surfaces
- Added boot-advertised theme system metadata, density options, and shell surface declarations.
- Added quick shell theme and density switching in the launcher plus new Glass Dark / Contrast Light / Contrast Dark presets.
- Normalized Explorer, Transfers, and Theme Studio onto shared shell-surface styling so built-in apps follow one desktop contract.
- Added batch transfer controls for pause, resume, and cancel-active flows, while keeping transfer persistence intact.


ROI 53 — shell-standard dialogs, notifications, and built-in app cleanup
- Added shell-standard toast/tray notifications and reusable confirm/input dialogs.
- Explorer create/rename/move/delete flows now use shell dialogs instead of browser prompt/confirm.
- Diagnostics, Security Center, Debug Center, Module Catalog, and module windows now mount through unified shell-surface classes instead of legacy `win7` surface markers.

ROI 54 — shell-standard app actions and built-in surface cleanup
- Added boot-advertised app-surface metadata so built-in windows declare a shared shell-standard action model and module-window surface coverage.
- Transport Diagnostics, Security Center, Debug Center, App Catalog, Transfers, and module windows now expose consistent shell action bars for copy/export, clear, and destructive actions.
- Administrative and destructive actions now route through shell confirmations and toast feedback, and Explorer now raises success notifications for create, rename, move, and delete flows.

