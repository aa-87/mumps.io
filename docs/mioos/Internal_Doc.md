# MIOOS Internal Documentation

## Architecture summary

MIOOS is a server-authored shell.

- MUMPS owns the authoritative state
- SSR delivers the initial page and boot contract
- Vue 3 Options API UMD renders and interacts with that contract
- websocket is the primary realtime surface
- auth/session state is resolved on the server

## Current browser split

The browser shell is now split into:

- `public/mioos/app/mioos_state.js`
- `public/mioos/app/mioos_i18n.js`
- `public/mioos/app/mioos_auth.js`
- `public/mioos/app/mioos_ws.js`
- `public/mioos/app/mioos_wm.js`
- `public/mioos/app/mioos_core.js`
- `public/mioos/mioos_desktop.js` as the tiny mount wrapper

## Locale model

Locale resolution is server-side in `MIOOSI18N` with the following order:

1. query parameter (`lang` / `locale`)
2. locale cookie if present
3. `Accept-Language`
4. configured default (`en`)

Supported locales today:

- `en`
- `ar`
- `es`

## Accessibility baseline

The shell currently enforces a baseline of:

- keyboard focus visibility
- reduced-motion CSS support
- dialog/menu/taskbar labels where practical
- SSR `lang` and `dir`
- RTL-aware layout adjustments

## Performance baseline

The shell currently favors:

- thin client state
- server-authored catalogs and view models
- websocket-first transport
- constrained DOM structure
- no build step for the browser modules

## Near-term next step

The next implementation ROI should harden terminal durability using the same contract discipline:

- one clear transport boundary
- server-owned session policy
- multi-window support
- reconnect and reattach posture

## ROI 4 terminal foundation

Terminal windows now use xterm.js in the browser and a server-owned websocket command contract in `MIOOSTERM` / `MIOOSWS`.


## ROI 5 update
MIOOS terminals now run as real YottaDB `-direct` PIPE sessions owned by the websocket shell rather than a simulated command surface.


## Terminal transport architecture
Use the primary MIOOS websocket for desktop state and shell commands. Use `MIOOSTWS` on `/ws/mioos/terminal` for terminal-only events such as `terminal.open`, `terminal.attach`, `terminal.input`, `terminal.resize`, and `terminal.close`. After a terminal is created, the browser should bind that window to a terminal-specific websocket URL such as `/ws/mioos/terminal?terminalId=<uuid>&windowId=<id>` so terminal traffic stays isolated and no steady-state poll loop is needed for routine typing. This same pattern can later be reused by the debugger and other realtime apps that need isolation.


## Terminal transport note

The active MIOOS browser terminal path follows the proven MIOMOS pattern: terminal.open / terminal.input / terminal.poll / terminal.resize / terminal.close all travel over the core shell websocket command bus. Dedicated per-terminal websocket experimentation is deferred until the MIOMOS-equivalent behavior is stable.


## Terminal reset note
- Reset MIOOS terminal handling to mirror the working MIOMOS model: one core websocket, promise-based command bus, xterm local line editing, and MIOMOSTPIPE-style pipe session lifecycle adapted into MIOOSTPIPE.

## VFS subsystem foundation

The VFS foundation lives in `MIOOSFS`. It stores entries, child indexes, and file chunks entirely in globals and keeps root bootstrap folders available from `INIT^MIOOSFS`. The current contract supports list, read, write, mkdir, meta, rename, move, and delete. Permissions currently follow an owner plus role CSV plus read/write/delete flag model so later explorer and file-app surfaces can build on a stable backend.


## Chunked upload transport
Staging lives under `^MIO("MIOOS","UPLOAD",...)`. Commit writes directly into the existing VFS chunk store under `^MIO("MIOOS","FS","DATA",...)`, so server-side storage remains chunked even when the original upload arrives over multiple websocket frames.


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
`MIOOSFSDN` now uses `READRANGE^MIOOSFS` for chunk delivery, keeps per-download session state under `^MIO("MIOOS","DL",...)`, and advertises `sha256` plus `verifyHash` in `fs.download.begin`. `MIOOSFS` now supports range reads directly from global-backed chunk storage, which avoids reconstructing the whole file for every chunk request.


## ROI 21 — Transfer lifecycle controls
`MIOOSFSUP` now records `createdAt`/`updatedAt`, keeps raw chunk byte accounting by chunk index, exposes `STATUS^MIOOSFSUP`, and purges abandoned staged uploads through `PURGE^MIOOSFSUP`. `MIOOSFSDN` mirrors that pattern for active download sessions. The Transfers window now uses controller hooks from `mioos_core.js` so cancel and retry behavior stays in the browser shell rather than leaking transfer state into generic window code.


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



## ROI 36 — VFS storage layout acceleration and upload accounting

- Raised the default VFS storage segment size for new files from 2 KB to 32 KB, while preserving transparent read compatibility for legacy 2 KB-segment files.
- Added per-file chunk-size metadata so `READRANGE^MIOOSFS` and HTTP blob delivery can read each file using its actual stored layout instead of assuming one global segment size.
- Increased HTTP blob send chunk defaults to 512 KB to reduce server loop overhead during native browser download and preview.
- Reworked upload byte accounting in `MIOOSFSUP` to update received-byte totals incrementally instead of rescanning all chunk metadata on every chunk write.


## ROI 37 — upload finalize direct-stage promote for new binary files

- New binary uploads on the HTTP chunk path now stage directly into final VFS file nodes under a provisional file id.
- When the destination name does not already exist, commit promotes that staged file id directly instead of copying or repacking the payload again at finalize time.
- Overwrite uploads intentionally keep the older copy-on-commit behavior so existing file ids and entry metadata stay stable.
- Upload status and boot metadata now expose the active commit strategy so diagnostics can distinguish direct-stage promote from overwrite fallback.

## ROI 38 — streamed blob delivery and windowed text preview

- Reworked HTTP blob delivery so large native browser downloads and previews stream directly from stored VFS segments instead of rebuilding large intermediate range buffers first.
- Added `fs.read.range` for bounded websocket text reads so Explorer preview, text viewer, and structured viewer can open large text-like files without loading the whole file into one websocket response.
- Boot metadata now exposes direct-segment blob delivery and windowed text preview as explicit performance strategies.

