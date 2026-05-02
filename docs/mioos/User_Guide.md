# MIOOS User Guide

## 2026 desktop simplification update
- MIOOS now presents one primary desktop surface.
- Home, Terminal, Transfers, Customize, and Folder Properties all open on the same desktop.
- Explorer and file-management windows use a simpler classic Windows-style layout.

## 2026 Product Reset

### Daily workflow
1. Open **Home** to browse folders, files, app launchers, and terminal launchers.
2. Use folder windows for Back, Forward, Up, and direct address navigation.
3. Open **Properties** on a folder to review attributes, sharing, and customization.
4. Use **Transfers** for active, queued, completed, and failed transfer visibility.
5. Use **Customize** to edit appearance tokens, previews, and profile presets.

### Folder properties
- **General**: type, location, size, contains, created date, and attributes.
- **Sharing**: share with specific users or everyone, based on policy.
- **Customize**: per-folder background and icon overrides.

### Start menu and taskbar
- The Start menu is now a focused launcher for runtime apps, recent work, shell controls, and search.
- The taskbar groups windows by surface type and uses overflow instead of shrinking into an unreadable strip.

### Security posture
MIOOS supports auditable sharing, folder metadata, session governance, and controlled runtime access. Compliance still depends on deployment policy and operations.

---

# MIOOS User Guide

## Signing in

Use the shell sign-in form to authenticate with a local MIOOS account.

Default bootstrap users in development-style setups are typically:

- `admin`
- `user`
- `guest`

If guest access is enabled, the shell can be entered without a full named sign-in.

## Switching languages

The shell supports:

- English
- Arabic
- Spanish

Use the language controls in the start menu side panel. Arabic switches the shell into RTL mode.

## Desktop basics

- open apps from the desktop icons or Menu
- use the taskbar to restore or minimize windows
- use the title bar buttons to minimize, maximize/restore, or close
- refresh the desktop from the Menu when needed

## Accessibility notes

- buttons and inputs are keyboard reachable
- reduced-motion preferences are respected
- shell chrome is designed to remain readable in all three supported languages

## Current limitations

- terminal is a foundation shell surface in this ROI, but reconnect durability and richer backends are still planned
- explorer/VFS, chat, rich playback apps, and debugger are planned for later ROIs

## Terminal foundation

Open **Terminal** from the desktop or Menu. Each new terminal window creates its own session and supports commands like `help`, `whoami`, `locale`, `profile`, and `date`.


## ROI 5 update
MIOOS terminals now run as real YottaDB `-direct` PIPE sessions owned by the websocket shell rather than a simulated command surface.


## Terminal behavior update
Each terminal window now opens its own websocket-backed terminal channel. The terminal should feel cleaner because typed input is no longer locally echoed into xterm before YottaDB responds.


## ROI 15 — Explorer search and VFS integrity
- Added VFS-level `fs.search` and `fs.hash` contracts over HTTP and websocket.
- Explorer now supports in-folder search, optional deep search, and a details panel with path, MIME, size, and SHA-256 for selected files.
- Boot metadata now advertises VFS search/hash capabilities so future apps can stay contract-driven.


## ROI B — Shared window manager foundation
MIOOS now uses a shared window manager contract for shell windows. Windows support drag, resize, maximize, minimize, restore, edge/corner snapping, and explorer drop-upload on supported windows. Terminal windows now inherit the same shell frame behavior rather than using a one-off interaction model.


## Customize ROI

Customize is the supported appearance editor in MIOOS. It now uses a classic display-properties-style window with desktop and mobile previews, editable theme profiles, original Meadow Classic / Glass Horizon / Graphite Dock / Ember Panel preset families, and token controls for wallpaper, color, typography, metrics, and advanced overrides.


## ROI-F — Explorer + Transfers polish
- Explorer now uses 7.css as an interior accent layer while preserving native MIOOS shell chrome.
- Added a Transfers window for upload/download queue visibility and progress tracking.
- Transfer progress is surfaced across Explorer and the dedicated Transfers center.


## ROI-G — Desktop Icons, Layouts, and Context Menus
- Desktop icons are draggable with small, medium, and large size modes.
- Desktop and icon context menus expose refresh, rearrange, sorting, sizing, personalization, and Control Panel shortcuts.
- Icon layout preferences are persisted per user through the shell transport and also cached locally for responsiveness.


- ROI-H reapply: added chunked websocket downloads plus PDF and structured file viewers without changing the existing shell/window baseline.


## Download behavior
Large downloads continue through the Transfers experience, but MIOOS now performs an integrity check before saving when the browser supports secure hashing. If a download fails verification, the save is blocked instead of silently writing a corrupted file.


## Transfer controls
The Transfers window now shows cancel controls for active uploads/downloads and retry controls for failed or cancelled transfers. Retry works within the current browser session and is intended for operational recovery after a transient socket or refresh interruption.


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

ROI 33 — HTTP binary chunk transport for resumable uploads and hardened pause/resume

## ROI 34 — Upload commit reconciliation and missing-chunk self-heal
- Hardened HTTP binary uploads so Explorer reconciles staged server state through `fs.upload.status` before commit instead of assuming every acknowledged chunk is durably complete.
- When the server reports a gap, the client now rewinds to the next missing chunk, replays the missing range, and only then retries final commit.
- This reduces false-finalize failures such as `fs_upload_commit_failed` with `missing_chunk` under concurrent or bursty upload conditions.



## Shell reset note

The current UI is being rebuilt in waves. During Wave 1, the focus is on stable window launching, sign-in movement, taskbar restore/minimize behavior, and corrected desktop icon sizing before richer visual polish lands.

ROI 52 — theme system 2.0 and unified shell surfaces
- Added boot-advertised theme system metadata, density options, and shell surface declarations.
- Added quick shell theme and density switching in the launcher plus new Glass Dark / Contrast Light / Contrast Dark presets.
- Normalized Explorer, Transfers, Customize, and Folder Properties onto shared classic shell-surface styling so the built-in runtime surfaces follow one desktop contract.
- Added batch transfer controls for pause, resume, and cancel-active flows, while keeping transfer persistence intact.


ROI 53 — shell-standard dialogs, notifications, and built-in app cleanup
- Added shell-standard toast/tray notifications and reusable confirm/input dialogs.
- Explorer create/rename/move/delete flows now use shell dialogs instead of browser prompt/confirm.
- Diagnostics, Security Center, Debug Center, Module Catalog, and module windows now mount through unified shell-surface classes instead of legacy `win7` surface markers.


## ROI 54 — shell persistence, keyboard shortcuts, and accessibility polish
- Added local shell persistence for non-terminal window frames plus sign-in dialog position.
- Added shell keyboard shortcuts for show desktop, window switching, close focused window, and opening diagnostics.
- Added reduced-motion preference handling, a taskbar Desktop control, and a shell window switcher overlay.

## ROI 54 — app actions
Transfer Center, Diagnostics, Security Center, Debug Center, App Catalog, and module windows now use shared shell confirmations and toast feedback for copy, clear, revoke, unlock, and history-cleanup actions.


## ROI 55 — websocket batch uploads and socket-pool observability
- The Diagnostics window now shows both client socket telemetry and the server-side socket registry for the current session.
- Parallel uploads can batch websocket chunks when the server advertises batching support, while still falling back safely if a worker or batch send fails.


## ROI 56 — single-desktop simplification
- The active shell now uses one desktop instead of multiple workspaces.
- Window visibility, taskbar grouping, and terminal launch now operate on one desktop surface.
- Workspace compatibility fields remain in the boot contract only where they simplify migration.


## ROI 59 — shell persistence and explorer assets
- Notifications now open the tray automatically and the tray surface is presented as **Notifications** with Clear all and Close actions.
- Home explorer now promotes **Desktop** instead of Shared Root, and the default Welcome.txt seed file is no longer created automatically.
- Explorer folder context actions now flow through the global shell context-menu surface so menus are not clipped by window bounds.
- Customize persists theme profiles through globals-backed routes and supports uploaded wallpaper assets stored in the VFS.
- Folder Properties now supports uploaded background and icon assets stored in the VFS and persisted through folder metadata.
- Transfers now show an overall progress bar plus per-file progress rows and support multi-file upload selection.

## Backend table surfaces

Application windows can use the MIOOS backend table surface for large lists. Tables support paging, sortable and resizable columns, column show/hide controls, grouping, expandable detail rows, row actions, and bulk actions. Data is queried from the MUMPS backend instead of being invented by the browser.

## UI Modules app

Open **UI Modules** from the Start menu to browse reusable MIOOS UI components, installed internal modules, user-created modules, and examples. The first component is **Backend Table**, which opens a backend-driven table window with pagination, sorting, grouping, hide/show columns, expansion rows, and actions.

User-created modules should follow the manifest format documented in `docs/mioos/UI_Modules.md` and can start from `examples/mioos_modules/table`.

## UI + Form Elements gallery

Open **App Catalogue → UI + Form Elements** to view interactive examples of common module UI patterns. The gallery shows how required fields, validation messages, switches, checkbox groups, radio groups, file pickers, modal forms, confirmations, and status toasts should behave. It is a safe reference surface and does not submit sample records to the backend.
