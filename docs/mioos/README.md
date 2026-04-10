# MIOOS README

MIOOS is a MUMPS-powered desktop shell for the MIO web stack.

## Current baseline

- SSR desktop shell via `MIOTPL`
- Vue 3 Options API UMD thin client
- local auth/session support on top of the MIO auth stack
- websocket shell channel
- English, Arabic (RTL), and Spanish locale support
- accessibility and performance metadata in the boot contract
- modular browser files under `public/mioos/app/`

## Immediate priorities

1. durable terminal reconnect/reattach behavior
2. global-backed virtual file system
3. explorer and file playback/apps
4. chat / rooms / groups / users
5. production-grade MUMPS debugger
6. shell polish, snapping, and motion details

## Key constraints

- no TypeScript
- no Vue Composition API
- no Node/Express assumptions
- no `ZSYSTEM`
- no `GOTO` in production code
- MAXSTRING-safe payload handling only

## Docs map

- `mioos_llm.md` — project handoff for future implementation work
- `docs/mioos/User_Guide.md` — operator-facing guide
- `docs/mioos/Internal_Doc.md` — architecture and subsystem notes
- `docs/mioos/HIPAA.md` — HIPAA-aware technical posture and limits

## Current terminal posture

ROI 4 lands an xterm.js terminal foundation with websocket command handling and multi-window session creation.


## ROI 5 update
MIOOS terminals now run as real YottaDB `-direct` PIPE sessions owned by the websocket shell rather than a simulated command surface.


## ROI 6 update
MIOOS now uses a split websocket posture: the core shell stays on `/ws/mioos`, while terminal windows use `/ws/mioos/terminal`. Each terminal window should re-bind to a terminal-specific websocket URL such as `/ws/mioos/terminal?terminalId=<uuid>&windowId=<id>` after open so shell actions stay responsive and the terminal path behaves more like a real terminal surface without a noisy poll loop.


Current terminal behavior follows MIOMOS: xterm.js on the client, a YottaDB PIPE-backed terminal on the server, and a core websocket command bus for terminal open/input/poll/resize/close.


## Terminal reset note
- Reset MIOOS terminal handling to mirror the working MIOMOS model: one core websocket, promise-based command bus, xterm local line editing, and MIOMOSTPIPE-style pipe session lifecycle adapted into MIOOSTPIPE.

## Latest ROI: VFS foundation

MIOOS now includes a global-backed virtual file system foundation. The current ROI focuses on contracts and durability rather than explorer UI. Files and folders live under globals, support metadata and permissions, and are available over both HTTP routes and websocket commands for later explorer integration.


## ROI 10 — Explorer upload and image viewer
- Added browser-side upload to the global-backed VFS using existing `fs.write` commands.
- Added image-aware file association handling in Explorer with preview and a dedicated image viewer window.
- Kept the backend stable by reusing existing VFS websocket commands rather than changing server storage contracts.


## ROI — Upload throughput and progress UX
- Added Explorer upload progress UI with percentage and stage text.
- Increased default chunk size for chunked uploads.
- Added a small parallel chunk pipeline on the browser for better upload throughput without sending a single oversized websocket frame.


## ROI 15 — Explorer search and VFS integrity
- Added VFS-level `fs.search` and `fs.hash` contracts over HTTP and websocket.
- Explorer now supports in-folder search, optional deep search, and a details panel with path, MIME, size, and SHA-256 for selected files.
- Boot metadata now advertises VFS search/hash capabilities so future apps can stay contract-driven.


## ROI B — Shared window manager foundation
MIOOS now uses a shared window manager contract for shell windows. Windows support drag, resize, maximize, minimize, restore, edge/corner snapping, and explorer drop-upload on supported windows. Terminal windows now inherit the same shell frame behavior rather than using a one-off interaction model.


## Theme Studio ROI

A detailed Theme Studio UI tool is available in MIOOS as a dedicated desktop app/window. It focuses on profile authoring and preview only, without changing the current native shell/taskbar/window styling baseline. The tool supports wallpaper choices, typography, sizing, color tokens, class recipes, extra CSS, import/export, local profile storage, and XP/Windows 7/Mac-inspired starter looks.


## ROI-F — Explorer + Transfers polish
- Explorer now uses 7.css as an interior accent layer while preserving native MIOOS shell chrome.
- Added a Transfers window for upload/download queue visibility and progress tracking.
- Transfer progress is surfaced across Explorer and the dedicated Transfers center.


## ROI-G — Desktop Icons, Layouts, and Context Menus
- Desktop icons are draggable with small, medium, and large size modes.
- Desktop and icon context menus expose refresh, rearrange, sorting, sizing, personalization, and Control Panel shortcuts.
- Icon layout preferences are persisted per user through the shell transport and also cached locally for responsiveness.


- ROI-H reapply: added chunked websocket downloads plus PDF and structured file viewers without changing the existing shell/window baseline.


## ROI 20 — Verified chunked downloads and VFS download hardening
MIOOS now treats download integrity as part of the VFS contract. Chunked downloads expose a verification hint and server hash, Explorer verifies the assembled payload before save where Web Crypto is available, and the server serves only the requested byte range for each chunk request.


## ROI 21 — Transfer resiliency and cleanup
MIOOS now treats transfer lifecycle cleanup as part of the production VFS contract. Active uploads and downloads can be cancelled from the Transfers window, failed or cancelled transfers can be retried in the same browser session, and stale staged transfer state is purged server-side after a configurable TTL.


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


## ROI 28 — HTTP VFS downloads and streamed preview routes
- Added protected HTTP routes for `/api/mioos/fs/download` and `/api/mioos/fs/preview` so downloads and common file previews no longer need to pull full payloads across the websocket command bus.
- Explorer now prefers browser-native HTTP downloads and HTTP preview URLs for image, audio, video, PDF, and large text/structured files, while keeping the legacy websocket download path as a compatibility fallback.
- Preview/download responses stream VFS content in bounded chunks, advertise byte-range support, and allow larger files to be downloaded or previewed without triggering websocket transport pressure.
