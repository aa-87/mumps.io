# MIOOS LLM Development Handoff

## What MIOOS is


MIOOS is a production-minded desktop shell built inside the existing **MUMPS.IO / MIO** web stack.

https://khang-nd.github.io/7.css/#window



It is not a toy XP clone, not a Node runtime, and not a generic SPA. The project is deliberately **MUMPS-first**, **SSR-first**, **MIO-native**, and now **i18n-aware**, **accessibility-aware**, and **performance-aware** from the start.

The browser uses a thin **Vue 3 Options API UMD** layer to render and interact with state authored by MUMPS routines.

## Core stack

Use these project assumptions unless the repo proves otherwise:

- **YottaDB / GT.M compatible MUMPS**
- **MIOHTTP** for HTTP transport and response handling
- **MIOROUTE** for route registration and compilation
- **MIOMW** for middleware
- **MIOAUTH / MIOAUTHJWT / MIOAUTHZ** for auth, JWT, RBAC, ABAC
- **MIOTPL** for SSR rendering
- **MIOWS** or existing websocket support for realtime channels
- **Vue 3 Options API UMD only** in the browser
- a **Tailwind-oriented static shell foundation** with a thin MIOMOS-inspired chrome layer
- **Native Vue 3 Options API UMD + CSS window manager** in the browser

## Hard constraints

- No TypeScript
- No Vue Composition API
- No Node/Express runtime assumptions
- No `ZSYSTEM`
- No `GOTO` in production code
- Keep MAXSTRING-safe handling for large payloads
- Use `^TMP($J,...)` or globals for large buffers
- Structured errors should include at least `ERR("routine")` and `ERR("error")`
- Tests must be quiet on success
- No markup placeholder data contracts

## Project-wide standing requirements

These are now permanent expectations for every ROI:

- maintain `mioos_llm.md`
- maintain `docs/mioos/README.md`
- maintain `docs/mioos/User_Guide.md`
- maintain `docs/mioos/Internal_Doc.md`
- maintain `docs/mioos/HIPAA.md`
- support **English** (default), **Arabic** (RTL), and **Spanish** from the start
- keep accessibility and performance as release gates, not afterthoughts
- keep the browser shell split into small no-build files rather than a single growing monolith
- preserve a HIPAA-aware technical posture wherever technically possible

## Namespace expectations

Stay inside the `MIOOS*` namespace for subsystem work.

Likely routines and responsibilities:

- `MIOOS` — main route and subsystem integration
- `MIOOSAPI` — API handlers
- `MIOOSWS` — websocket lifecycle and event routing
- `MIOOSST` — session, locale, and desktop state
- `MIOOSAUTH` — local auth/session helpers on top of the MIO auth stack
- `MIOOSI18N` — locale resolution and translation catalog
- `MIOOSVM` — server-authored view-model data
- `MIOOSUI` — SSR page context helpers
- `MIOOST` — quiet tests

## Current implementation posture

As of the current ROI:

- MIOOS has a server-authored desktop boot contract emitted as JSON
- the shell supports local sign-in, sign-out, and guest access
- locale negotiation exists for `en`, `ar`, and `es`
- RTL is supported for Arabic at the shell level
- the browser shell is now split into small files under `public/mioos/app/`
- accessibility and performance metadata are present in the boot contract
- tests cover routes, auth bootstrap, websocket basics, locale boot data, docs, and modular frontend structure

## Accessibility posture

MIOOS should remain:

- keyboard-usable
- screen-reader-aware where practical in SSR and shell chrome
- respectful of reduced-motion preferences
- contrast-conscious
- localization-safe, including RTL layout behavior

Avoid shipping new shell UI that only works with a mouse.

## Performance posture

MIOOS should remain:

- thin on the client
- server-authored where possible
- websocket-first for realtime
- careful with large payloads and MAXSTRING safety
- deliberate about shell complexity and repaint cost

Avoid regressions that turn the shell into a giant browser-only state machine.

## HIPAA posture

MIOOS is not “certified by a markdown file.”

However, the project should be engineered to support HIPAA-sensitive environments through:

- least-privilege authz patterns
- audit-friendly server ownership of policy
- constrained session surfaces
- careful handling of PHI-bearing content
- minimal client exposure of sensitive state
- documented operational guidance

See `docs/mioos/HIPAA.md` for the technical posture and limitations.

## Planned ROI chain

The current recommended sequence is:

- ROI 3 — docs, i18n/RTL, accessibility/performance baseline, frontend split
- ROI 4 — xterm.js terminal foundation
- ROI 4 is the current landed baseline for terminal work. ROI 5 should harden durability, reconnect, resume, and session longevity.
- ROI 5 — dependable multi-session terminal and reconnect/reattach posture
- ROI 6 — global-backed virtual file system foundation
- ROI 7 — explorer and file associations
- ROI 8 — shell polish, motion, snapping, and “wow” details
- ROI 9 — chat / users / groups / rooms
- ROI 10 — production-ready MUMPS debugger

## Testing posture

Each ROI should extend `^MIOOST` or adjacent subsystem tests.

Keep tests:

- quiet on success
- explicit on failure
- focused on contracts and regressions
- able to validate locale, accessibility, performance, and doc presence where reasonable


## ROI 5 — YottaDB pipe terminal
- Replaced the simulated terminal foundation with a real `yottadb -direct` PIPE-backed terminal session model.
- Added `MIOOSPIPE` for websocket-owned terminal lifecycle, I/O, drain, poll, resize, close, and stale-session purge.
- Updated `MIOOSTERM` to present xterm.js profile data while delegating session work to the PIPE layer.
- Updated websocket command handling to support `terminal.poll` and to keep the browser aligned with pipe transport.
- Updated the browser terminal module to poll active terminal windows over the primary websocket.


## ROI 6 — core socket plus dedicated terminal sockets
- The desktop now treats the primary `/ws/mioos` socket as the shell/control channel.
- Terminal windows use a separate dedicated websocket at `/ws/mioos/terminal`.
- Each terminal window now re-binds to its own terminal-specific websocket URL, for example `/ws/mioos/terminal?terminalId=<uuid>&windowId=<id>`, after the terminal is created.
- The browser terminal no longer relies on a continuous `terminal.poll` loop for normal typing and command execution.
- The browser terminal sends raw `data` frames and lets the YottaDB session own visible echo/output, which reduces malformed duplicate rendering.
- Terminal writes are normalized and batched before being flushed into xterm to reduce malformed line rendering and repaint churn.
- `MIOOSTWS` resolves `terminalId` and `windowId` from either message payloads or websocket query parameters, which lays the groundwork for future debugger-specific sockets too.


- Terminal browser path realigned to the working MIOMOS model: one core websocket for shell commands/events, with xterm line handling and controlled terminal polling. Dedicated per-terminal websocket experiments should be treated as deferred until the MIOMOS-equivalent path is fully stable.


## Terminal reset note
- Reset MIOOS terminal handling to mirror the working MIOMOS model: one core websocket, promise-based command bus, xterm local line editing, and MIOMOSTPIPE-style pipe session lifecycle adapted into MIOOSTPIPE.

## ROI 7 — VFS foundation
- Added `MIOOSFS` as a global-backed virtual file system foundation with root, Desktop, Documents, metadata, permissions, and chunked file storage.
- Added HTTP routes and websocket command handlers for `fs.list`, `fs.read`, `fs.write`, `fs.mkdir`, `fs.meta`, `fs.rename`, `fs.move`, and `fs.delete`.
- Boot state now advertises the VFS contract including root id, home id, chunk size, globals-only storage, and owner/role/flag permissions.
- Added regression coverage in `^MIOOST` for VFS CRUD and command-bus integration.


## ROI 10 — Explorer upload and image viewer
- Added browser-side upload to the global-backed VFS using existing `fs.write` commands.
- Added image-aware file association handling in Explorer with preview and a dedicated image viewer window.
- Kept the backend stable by reusing existing VFS websocket commands rather than changing server storage contracts.


## ROI — Upload throughput and progress UX
- Added Explorer upload progress UI with percentage and stage text.
- Increased default chunk size for chunked uploads.
- Added a small parallel chunk pipeline on the browser for better upload throughput without sending a single oversized websocket frame.


## ROI 14B — Parallel upload sockets
- Chunk uploads now use multiple concurrent `/ws/mioos` websocket connections rather than serial chunk sends on the core shell socket.
- Default upload concurrency is server-configurable and now defaults to 7, with the browser honoring the server-provided `concurrencyDefault`.
- Chunk size remains conservative at 32768 to reduce mid-upload socket closure risk.


## ROI A implementation notes
- Added configurable websocket pool boot contract for MIOOS with max sockets per session, FS socket budget, and upload batch size.
- Added `fs.upload.batch` websocket command to reduce per-chunk round trips during explorer uploads.
- Explorer uploads now use a bounded pooled websocket worker model with batched chunk sends for faster large-file transfers.


## ROI B — shared window manager foundation
- Added a common window contract for all MIOOS windows with min size, drag, resize, snap, maximize, minimize, and restore behavior.
- Added edge and corner snap preview plus resize handles so explorer, control panel, media viewers, and terminal all share the same shell chrome behavior.
- Added drop-to-upload support for explorer-class windows so dragged files can enter the VFS from a window surface, not just the upload button.
- Added boot contract metadata for windowing: snap threshold, taskbar height, min size, animation mode, resize handle model, and drop-upload capability.


## Theme Studio ROI

A detailed Theme Studio UI tool is available in MIOOS as a dedicated desktop app/window. It focuses on authoring one editable system shell theme with light and dark modes, desktop and mobile live preview, wallpaper/avatar upload, typography, sizing, color tokens, class recipes, extra CSS, import/export, and optional user-created copies.


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
- Download begin now advertises a verification contract including a server-computed SHA-256 when available.
- Download chunks now read only the requested range from VFS storage instead of rebuilding the whole file on each chunk request.
- Explorer verifies chunked download payloads before saving when the browser exposes Web Crypto.
- Hash mismatch and stalled-offset failures now fail closed instead of silently falling back to a potentially corrupted save.
- This ROI is intended to harden large-file round trips and reduce avoidable shell instability under transfer load.


## ROI 21 — Transfer resiliency, cancellation, retry, and stale-session cleanup
- Transfers now expose cancel and retry actions in the Transfers window through a small controller registry in the Vue shell.
- Explorer upload/download flows register per-transfer control hooks so active transfers can abort cleanly and failed or cancelled transfers can be retried in-session.
- `MIOOSFSUP` now tracks upload timestamps plus per-chunk raw byte counts, exposes `fs.upload.status`, and purges abandoned staged uploads after a configurable TTL.
- `MIOOSFSDN` now timestamps active download sessions and purges stale download state after a configurable TTL.
- `MIOOSST` performs lightweight transfer cleanup during state load so abandoned transfer globals do not accumulate between refreshes.


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

## ROI 34 — Binary upload integrity, chunked download decoding, and preview hardening
- Normalized uploaded binary storage so both HTTP raw-binary uploads and websocket base64 uploads commit into the VFS as raw bytes instead of JSON-transport strings.
- Hardened `fs.download.begin`/`fs.download.chunk` to advertise and return binary-safe base64 chunks over websocket/JSON, preserving byte offsets while keeping the current high-performance upload workflow.
- Moved image/media/PDF preview loading to the chunked download path and added regression coverage in `MIOOST` for upload -> commit -> read -> chunk-download roundtrip integrity.


## ROI 35 — Direct HTTP blob/range download and large preview acceleration

- Added authenticated `GET/HEAD /api/mioos/fs/blob` for direct file delivery from the globals-backed VFS.
- Supports `Range` requests for native browser streaming of images, audio, video, and PDF content.
- Explorer preview, image viewer, media viewer, PDF viewer, and browser download handoff now use direct file URLs instead of websocket `fs.read` or serial chunk download for large binary payloads.
- Keeps websocket control paths in place for text-oriented reads while moving bulk binary transfer onto HTTP for significantly better preview and download performance.


## ROI 36 — VFS storage layout acceleration and upload accounting

- Raised the default VFS storage segment size for new files from 2 KB to 32 KB, reducing global node count and read amplification for large files.
- Added per-file chunk-size metadata so new files use the faster layout while older files remain readable without migration.
- Increased direct HTTP blob send chunk defaults to 512 KB to reduce server-side loop overhead for browser-native download and preview.
- Reworked upload received-byte tracking to update incrementally per chunk instead of rescanning the full staged upload on every write.


## ROI 37 — upload finalize direct-stage promote for new binary files

- New binary uploads on the HTTP chunk path now stage directly into final VFS file nodes under a provisional file id.
- When the destination name does not already exist, commit promotes that staged file id directly instead of copying or repacking the payload again at finalize time.
- Overwrite uploads intentionally keep the older copy-on-commit behavior so existing file ids and entry metadata stay stable.
- Upload status and boot metadata now expose the active commit strategy so diagnostics can distinguish direct-stage promote from overwrite fallback.

## ROI 38 — streamed blob delivery and windowed text preview

- Reworked HTTP blob delivery so large native browser downloads and previews stream directly from stored VFS segments instead of rebuilding large intermediate range buffers first.
- Added `fs.read.range` for bounded websocket text reads so Explorer preview, text viewer, and structured viewer can open large text-like files without loading the whole file into one websocket response.
- Boot metadata now exposes direct-segment blob delivery and windowed text preview as explicit performance strategies.



## ROI 39 — persistent transfer recovery and media-first streaming

- The transfer center now persists upload and download entries in browser local storage so activity remains visible after refresh.
- Upload entries store server-side resume metadata (`uploadId`, `nextIndex`, `contiguousBytes`, `parentId`) so a refreshed session can reattach to in-flight uploads and continue from the first missing chunk after the user re-selects the same file.
- Media preview URLs now request `stream=media`, and `FSBLOB^MIOOSAPI` answers a first non-range media GET with an initial partial-content window to reduce time-to-first-frame while keeping later browser range fetches intact.
- The next ROI should focus on worker-assisted upload scheduling, main-thread contention audits, and measurements of true end-to-end upload throughput under parallel load.
## Latest shell UI direction

The visible MIOOS desktop shell must follow the attached `mioos_ui_samples_bundle_v3.zip` markup and CSS structure directly for the Win7 light and dark variants. Do not mix legacy XP-era MIOOS chrome classes with the sample Win7 shell DOM. When in doubt, rebuild the visible shell surface from the sample HTML instead of skinning old markup.

The following surfaces are now expected to use the sample-driven structure first:

- taskbar and start menu
- desktop icon grid and rubber-band selection
- context menu
- base window chrome
- explorer shell layout
- transfer window
- theme studio / settings shell

Behavior can still come from existing `MIOOS*` routines and browser methods, but the DOM and CSS should stay aligned with the sample bundle.
- Sample-shell styling is now isolated in `/public/mioos/mioos_samples.css`, loaded after the legacy shell stylesheet so the sample HTML/CSS wins cleanly without mixed chrome or accidental overrides.


## UI reset roadmap status

Wave 1 is now the active implementation track.

Current scope:
- replace hard-coded retro shell defaults with production shell foundation keys
- remove remote shell stylesheet dependency
- stabilize the shell window manager with dynamic window fallback creation
- make the sign-in surface draggable
- tighten desktop icon sizing and transform-based positioning

Remaining waves stay the same:
- Wave 2: launcher, taskbar, menus, dialogs, transfers
- Wave 3: theme system 2.0, built-in app cleanup, persistence, accessibility polish

ROI 52 — theme system 2.0 and unified shell surfaces
- Added boot-advertised theme system metadata, density options, and shell surface declarations.
- Added quick shell theme and density switching in the launcher plus new Glass Dark / Contrast Light / Contrast Dark presets.
- Normalized Explorer, Transfers, and Theme Studio onto shared shell-surface styling so built-in apps follow one desktop contract.
- Added batch transfer controls for pause, resume, and cancel-active flows, while keeping transfer persistence intact.


ROI 53 — shell-standard dialogs, notifications, and built-in app cleanup
- Added shell-standard toast/tray notifications and reusable confirm/input dialogs.
- Explorer create/rename/move/delete flows now use shell dialogs instead of browser prompt/confirm.
- Diagnostics, Security Center, Debug Center, Module Catalog, and module windows now mount through unified shell-surface classes instead of legacy `win7` surface markers.


## ROI 54 — shell persistence, keyboard shortcuts, and accessibility polish
- Added local shell persistence for non-terminal window frames plus sign-in dialog position.
- Added shell keyboard shortcuts for show desktop, window switching, close focused window, and opening diagnostics.
- Added reduced-motion preference handling, a taskbar Desktop control, and a shell window switcher overlay.

ROI 54 — shell-standard app actions and built-in app polish
- Added boot-advertised app action metadata for confirm-before-destructive, admin notifications, clipboard exports, and session-local module notes.
- Standardized built-in app action bars for Transfer Center, Transport Diagnostics, Security Center, Debug Center, App Catalog, and module windows.
- Added shell copy/export/clear actions with confirmations and toast feedback across diagnostics, security, debug, catalog, transfers, and module notes.
