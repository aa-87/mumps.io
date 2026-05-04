# MIOOS LLM Context

## 2026 desktop simplification update
- MIOOS now uses a **single desktop model** instead of virtual workspaces.
- The terminal is expected to launch on the same desktop as Home, Transfers, and Customize.
- Explorer, Transfers, Customize, and Folder Properties use a cleaner classic enterprise shell inspired by Windows XP / Windows 7 interaction patterns.
- The taskbar clock now shows both time and date again.

## 2026 Product Reset

MIOOS is now defined as a **secure application workspace and runtime shell for MUMPS modernization**.

### Current product definition
- Primary purpose: host modernized legacy MUMPS applications, internal tools, and controlled operational workflows.
- Primary strengths preserved: server-authored shell contract, websocket-first transport, terminal integration, VFS, SSR-first rendering, auth/session/audit foundations.
- Primary experience: Home, Terminal, Transfers, Customize, and folder properties.
- Removed from the active product experience: Notes, Ops Center, App Catalog, Control Panel, Security Center, Debug Center, Diagnostics, and Theme Studio.
- Compliance positioning: **HIPAA-ready architecture**, not automatic HIPAA compliance. Deployers must still configure policy, retention, encryption, access controls, and operating procedures correctly.

### Shell philosophy
- MIOOS is not a novelty desktop or utility bundle.
- MIOOS is a focused workspace for enterprise runtime, file operations, themed application hosting, and auditable administration.
- Home is the visible VFS root for users.
- Folder windows behave like first-class shell surfaces with back/forward/up navigation, address bars, metadata, drag/drop, and folder-specific customization.
- The taskbar groups windows so the shell remains usable at high window counts.

### Architecture notes
- Folder metadata now supports per-folder presentation, sharing scope, and attribute flags.
- The runtime uses a token-driven customization system with desktop and mobile previews.
- The active runtime no longer depends on `7.scoped.css`; `mioos_reset.css` is the focused override layer for the rewritten shell surfaces.
- Migration remains incremental: the shell contract and VFS/auth foundations stay intact while product sprawl is removed.

### Important behavioral rules
- “Home” is the main user-facing root.
- Folder properties expose General and Customize tabs.
- Sharing is explicit and auditable through persisted folder metadata.
- Customize replaces Theme Studio as the supported appearance editor and uses original theme families inspired by classic enterprise OS paradigms without copying proprietary assets.

### Supporting docs
See also:
- `docs/mioos/Architecture_Overview.md`
- `docs/mioos/Theme_System.md`
- `docs/mioos/VFS_Metadata_Model.md`
- `docs/mioos/Drag_Drop_Rules.md`
- `docs/mioos/Transfer_Manager.md`
- `docs/mioos/Migration_Notes.md`

Legacy ROI notes are preserved below for historical continuity and regression references.

---

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

ROI 54 — shell-standard app actions and built-in app polish
- Added boot-advertised app action metadata for confirm-before-destructive, admin notifications, clipboard exports, and session-local module notes.
- Standardized built-in app action bars for Transfer Center, Transport Diagnostics, Security Center, Debug Center, App Catalog, and module windows.
- Added shell copy/export/clear actions with confirmations and toast feedback across diagnostics, security, debug, catalog, transfers, and module notes.


## ROI 55 — websocket batch uploads and socket-pool observability
- Added real `fs.upload.batch` websocket command handling so Explorer upload workers can batch chunks instead of always falling back to single-chunk sends.
- Added server-side session socket registration, stale-socket purging, and transport-health reporting for active core and FS sockets.
- Boot, hello, and diagnostics metadata now advertise socket caps, core/FS socket quotas, upload batch size, and batch flush thresholds so the browser and diagnostics window share one transport contract.


## ROI 56 — single-desktop simplification
- The active shell now uses one desktop instead of multiple workspaces.
- Window visibility, taskbar grouping, and terminal launch now operate on one desktop surface.
- Workspace compatibility fields remain in the boot contract only where they simplify migration.


## ROI 57 — classic shell cleanup and VFS routing hardening
- `fs.list` now resolves explorer targets by `id`, `path`, or `parent` so Home navigation, websocket commands, and folder refreshes all use the same contract.
- Explorer now closes any open folder context menu before opening another context menu surface, which prevents the desktop menu and folder menu from stacking on top of each other.
- The active shell keeps tray-panel notifications only; stale explorer menubar/taskpane CSS and the old top-right notification-stack CSS were removed from the runtime stylesheet.
- The current shell contract remains one desktop rooted at **Home**, with Terminal, Transfers, Customize, and Folder Properties as the first-class built-in windows.



## ROI 58 — unified shell overhaul
- The active shell now uses a unified overhaul layer for Start, Taskbar, Explorer, Transfers, Customize, and Folder Properties while preserving the existing single-desktop MIOOS architecture.
- `templates/layouts/mioos_shell.html` now loads local `7.scoped.css` plus `mioos_shell_overhaul.css`; the page template keeps the real window/app structure while the new stylesheet sharpens the OS-native presentation.
- `public/mioos/app/mioos_core.js` now normalizes theme profiles around generic families (`meadow-classic`, `glass-horizon`, `graphite-dock`, `ember-panel`) and resolves shell tokens for launcher width, task sizing, sidebar width, preview width, title metrics, blur, transparency, and desktop wallpaper layers.
- `public/mioos/app/mioos_explorer.js` now exposes filtered explorer rows, breadcrumb paths, preview facts, and direct path navigation helpers used by the redesigned explorer surface.
- `routines/MIOOSST.m` now advertises the upgraded theme-system contract, including 7.css-first window grammar, Basecoat control augmentation, and boot-time preset family metadata.


## ROI 59 — shell persistence and explorer assets
- Notifications now open the tray automatically, the tray is labeled **Notifications**, and the panel includes Clear all plus Close instead of the earlier utility shortcuts.
- The shell now exposes globals-backed theme load/save routes and boot metadata for theme persistence version 4.
- Customize loads and saves profiles through globals with local fallback, and uploaded wallpaper assets are stored in the VFS and referenced through blob URLs.
- Folder Properties now supports uploaded background and icon assets stored in folder metadata through `fs.setmeta`.
- Explorer now promotes Desktop instead of Shared Root, removes the automatic Welcome.txt seed, and uses the global shell context menu for folder actions so menus are not clipped by window bounds.
- Transfers now support multi-file upload selection and render overall plus per-file progress hierarchy.

## ROI note — transfer robustness, attributes, and live theme wiring

All tests were passing at the start of this ROI. The next hardening pass addressed a real multi-file upload race where commit could happen after the UI reached 100% but before the server had a contiguous chunk set. `mioos_explorer.js` now uses a strict all-chunks-complete check, a commit guard, and `missing_chunk` reconciliation through upload status. The transfer UI now has per-file pause/resume/retry/cancel actions and compact status-colored rows. The VFS read-only attribute is enforced in `CAN^MIOOSFS` for write/delete, including owner access. Customize live preview now maps more profile fields into CSS variables so non-preset tab changes visibly affect the shell.

## ROI follow-up — MIOTPL theme first paint and transfer reconciliation

- Initial MIOOS theme paint is now server-rendered through MIOTPL via `themeInlineStyle` from `MIOOSUI`, avoiding unauthenticated `/api/mioos/theme/load` calls and visible theme lag before sign-in.
- Authenticated sessions still use the globals-backed Customize theme service for load/save after access is established.
- Multi-file uploads now wait for upload-status reconciliation before commit, and `MIOOSFSUP` recounts chunk byte totals during commit to avoid false `missing_chunk` failures after 100% client progress.
- Explorer, Start menu, and transfer surfaces received additional compact sizing and overflow hardening for native-shell behavior with long names and larger item counts.

## ROI 60 — MIOTPL theme first paint and native shell polish

- Removed automatic pre-sign-in theme fetch from the client startup path.
- Added active globals-backed theme profile to boot state and MIOTPL inline CSS variables.
- Preserved manual Reload Saved behavior inside Customize for authenticated sessions.
- Fixed wallpaper upload result handling so VFS IDs returned by write/upload responses can become blob-backed wallpaper URLs.
- Deduped Transfer Center active queue by showing completed/failed/cancelled transfers only in history.
- Added compact native-shell CSS overrides for Home Explorer, Transfer rows, Start Menu item capacity, and Customize previews.

## Backend Table Component — implementation notes

- `MIOOSTBL` owns server-side table querying and returns schema, rows, pagination metadata, grouping summaries, row actions, bulk actions, and feature flags.
- `/api/mioos/table/query` is registered through `MIOOS.m` and handled by `TABLEQUERY^MIOOSAPI`.
- `MIOOSST` exposes `boot.routes.tableQuery` and advertises the table component in `boot.desktop.components.table`.
- `public/mioos/app/mioos_table.js` provides the reusable Vue 3 Options API UMD table component and `mioos-surface-table` shell surface.
- The component supports backend pagination, per-column sorting, global filtering, column visibility, resizable columns, column grouping headers, row expansion, selection, row actions, and bulk action rows.
- Keep Explorer independent. The table component borrows the details-table interaction model but must not mutate Explorer state or replace Explorer-specific VFS behavior.

## UI Module Foundation

MIOOS now has a first-class UI Module foundation for internal and user-created modules. The foundation is installed but launch-disabled by default; keep `CONF("mioos","modules","enabled")` and `CONF("mioos","modules","appCatalogEnabled")` off unless the shell should expose the UI Modules catalog app.

- `MIOOSMOD` owns the backend module catalog and emits the `mioos-ui-module-v1` contract.
- `MIOOSST` injects the full catalog as `boot.uiModules` and keeps launchable module rows in `boot.modules` for Start menu compatibility.
- `/api/mioos/modules/catalog` is handled by `MODULECATALOG^MIOOSAPI`.
- `module.catalog` in `MIOOSWS` returns the same registry for websocket clients.
- `mioos_modules.js` owns the browser-side registry, component/module registration APIs, UI Modules catalog surface, and generic module host.
- `mioos_table.js` registers the first reusable component: `table` / `mioos-full-table` / `mioos-surface-table`.
- Examples live under `examples/mioos_modules`, with `examples/mioos_modules/table` as the first example.

Do not build new internal or user-created module screens by copying Explorer. Add a catalog entry and either reuse an existing registered component or register a new component through `window.MIOOSModules.registerComponent(...)` before `MIOOSCore.mount()`.


## ROI 57 — Safe first paint and opt-in UI Modules

Current source state: backend UI module registry, catalog API/WS support, boot manifest injection, client module/component registry, UI Modules catalog window, generic module host, and the backend table component are present. The module system is launch-disabled by default. Do not treat the presence of `MIOOSMOD`, `mioos_modules.js`, or `mioos_table.js` as permission to expose modules during default boot; `CONF("mioos","modules","enabled")` and `CONF("mioos","modules","appCatalogEnabled")` must both be enabled.

First paint must not require authenticated internal asset requests. Before sign-in, MIOTPL may render theme variables and gradients, but it must not render `/api/mioos/theme-asset` or `/api/mioos/fs/blob` URLs into CSS, data attributes, or boot JSON.

## ROI 62 — Safe theme boot, advanced table samples, permissions, and patient registration

- Do not render protected `/api/mioos/theme-asset` or `/api/mioos/fs/blob` URLs before authentication.
- Table data and CRUD mutations are WebSocket-first (`table.query`, `table.mutate`) with authenticated HTTP fallback routes (`/api/mioos/table/query`, `/api/mioos/table/mutate`).
- The reusable table supports sorting, grouping, select all visible, selected-row bulk actions, row CRUD, column CRUD, and column resizing.
- Built-in sample datasets live in `MIOOSTBL`: `demo`, `massive`, `ui-elements`, `patient-registration`, and read-only `vfs`.
- The module registry remains opt-in at boot, but the App Catalogue can fetch internal module entries after sign-in.

## ROI 64B — UI Modules examples gallery rewrite

The immediate UI Modules track now has a standalone interactive UI/form gallery. `UI + Form Elements` is registered with `componentKey="ui-elements"` and `surface="mioos-surface-ui-elements"`; it no longer launches through `mioos-surface-table`. The gallery lives in `public/mioos/app/mioos_modules.js`, uses Vue 3 Options API UMD only, and demonstrates inputs, textareas, selects, radio groups, checkbox groups, switches, date/number inputs, HTTP file-picker metadata pattern, validation, disabled/read-only states, loading/saving states, tabbed sections, modal form, confirmation dialog, toast/status feedback, and empty/error states.

Backend and compliance rule: the UI-elements example uses local sample state and simulated saving. Production modules must submit to authenticated backend routes for persistence, validation, audit, and authorization, and must never persist uploaded files or images as DataURLs.

Next planned ROI: ROI 64C should rewrite the advanced table component as a standalone configurable production table for internal and user-created modules.


## ROI 64C — Standalone Advanced Table Component Rewrite

The advanced table contract is `mioos-advanced-table-v8`. Table modules should use `mioos-full-table` / `mioos-surface-table` through backend `tableState` module nodes or equivalent manifest JSON. The backend remains server-authoritative. Query may use WebSocket; mutation defaults to WebSocket acknowledgement JSON with HTTP fallback for row CRUD, column CRUD, column visibility, column resize, grouping, and bulk deletes. Do not fork custom table implementations for module samples unless a new contract is intentionally defined with tests and docs.

### ROI 64C redo — table hardening follow-up

The advanced table contract is now `mioos-advanced-table-v8`. The redo addressed reported contrast issues, slow large-dataset sorting, mutation `ERR_EMPTY_RESPONSE`/`Failed to fetch` handling, DataTables-style API expectations, and missing server-communication indicators. The client sends `draw`, `start`, `length`, `order`, and `columns` metadata alongside native MIOOS query fields. `MIOOSTBL` responds with `draw`, `recordsTotal`, `recordsFiltered`, and `data` in addition to native `rows`. Backend sorting uses an indexed map instead of O(n²) bubble sorting. The browser shows a processing indicator and surfaces empty/invalid mutation responses as table errors without closing the editor.

## ROI 64C redo 2 — immediate table corrections

The last table ROI was redone again from the user-provided ZIP. Important current behavior:

- Contract: `mioos-advanced-table-v8`.
- Table query/mutation are WebSocket-first with HTTP fallback.
- WebSocket commands added: `table.query`, `table.mutate`.
- Massive dataset is read-only and page-materialized server-side; it must not expose mutation controls.
- The editor is a viewport-safe modal dialog and should not be inline inside the table scroll area.
- Table density defaults to compact.
- Actions column has `actionsWidth` and a resize handle.
- Column group headers are disabled by default through `features.columnGroups=false`; do not show unexplained group labels such as Timeline unless explicitly enabled.
- Visible footer must not show internal draw number or last-response timestamp.
- `table-samples` opens `mioos-surface-table-showcase`, which documents simple-to-advanced copyable MUMPS `SET MOD(...)` tableState contracts.
- VFS upload WebSocket commands already exist and should be tuned in a dedicated transport ROI, not mixed into table UI rewrites.


## ROI 64D — table performance, mutation correctness, and MUMPS-first examples

Current table contract: `mioos-advanced-table-v8`. Query may use `table.query` over WebSocket, but mutation defaults to authenticated HTTP through `/api/mioos/table/mutate` using `mutateTransport="websocket"` to avoid the reported `socket_timeout` on saves. Do not re-enable WebSocket-first mutation without a dedicated transport regression test.

The `massive` dataset has a fast server path for no-search/no-filter paging and generates only the requested page. It is read-only and disables `selection`, `bulkActions`, `rowCrud`, `columnCrud`, `rowDetails`, and `actionRows`, so it must not render an Actions column.

Table Samples are now MUMPS-first. Examples should show `SET MOD(...)` / `tableState` contracts instead of JavaScript `MIOOSTable.createConfig(...)` snippets. This project is for MUMPS developers with no frontend experience; normal table modules should be created by backend catalog/table contract nodes, not by writing Vue components.

### ROI 64E table follow-up

Current table contract: `mioos-advanced-table-v8`. Table query can use WebSocket, but mutation is WebSocket-first by default with HTTP fallback and both HTTP `/api/mioos/table/mutate` and WebSocket `table.mutate` call the same `MUTATE^MIOOSTBL` routine. `MIOOSTBL` now validates row fields, row IDs, column keys, column widths, and field lengths before update. Both transports must return deterministic JSON `{ok:false,error:"table_mutate_failed",detail:...}` on domain errors; do not allow table mutation failures to surface as socket timeouts or empty HTTP responses.

Table Samples are MUMPS-first. Samples must show dataset global definition, `MOD(...)` table registration, and the routines to `ZLINK`/run. Avoid JavaScript snippets for user-facing table examples because the target audience is MUMPS developers with no frontend experience.

UI rules: simple/read-only tables omit Actions. Row details are an expand arrow in the control/id-selection column, not a row action. Column picker is modal-only. Column editing/designer controls render only when `columnCrud` is enabled.

## Table stabilization before ROI 64I

The current advanced table contract is `mioos-advanced-table-v8`. The table stabilization pass addressed bounded draggable modals, typed filter controls, advanced include/exclude/range filters, server-side selected-row CSV export, immutable column keys during edit, select-option dictionary updates via `column.option.add`, and a low-shift loading bar. Mutations default to WebSocket acknowledgements with HTTP fallback, and both transports must continue to call `MUTATE^MIOOSTBL`.

The next planned sequence is:

- ROI 64I: editable cells with schema-driven controls and optional MUMPS cell callbacks.
- ROI 64J: column reorder, configured on boot or saved as a user option.
- ROI 64K: fixed columns, configured on boot or saved as a user option.

See `docs/mioos/ROI_64I_64K_Table_DataTables_Parity.md` before implementing the next ROI.


## ROI 64I editable cells

Current advanced table contract remains `mioos-advanced-table-v8`. Cell editing is now implemented with a `cell.save` mutation. The browser renders typed inline cell controls from schema metadata and saves over WebSocket `table.mutate` with HTTP fallback. Both transports call `MUTATE^MIOOSTBL`. The backend validates row id, column key, editable flag, field rules, and optional per-column `cellCallback` before writing. ID cells are read-only. The loading indicator is bar-only; do not reintroduce loading text that shifts table layout. Advanced Filters `Add value` now prompts/uses the drafted value and sends `column.option.add`.

ROI 64J column reorder and ROI 64K fixed columns are complete in the Advanced Table track. ROI 64L hardening stabilizes the combined table feature set before any new table module scope.

## ROI 64J column reorder

Current Advanced Table contract remains `mioos-advanced-table-v8`. ROI 64J adds server-persisted column reorder. Enable it from MUMPS with `MOD("tableState","config","features","columnReorder")=1`. The Columns modal provides up/down controls and saves through `column.reorder` over WebSocket-first mutation with HTTP fallback. `MUTATE^MIOOSTBL` validates the reorder payload with `VALORDER`, rewrites `schema("columns")`, returns an acknowledgement-only response, and the UI refetches the table. Avoid native browser `prompt()`/`confirm()` for table flows; use MIOOS table dialogs.

## ROI 64L advanced table hardening

ROI 64L is the stabilization pass after fixed columns. It hardens Advanced Table composition across editable cells, validation, column visibility, column reorder, fixed columns, grouping, filtering, selected-row CSV export, and MIOOS-owned dialogs. Fixed-column metadata is returned as `schema.fixedColumns` and `fixedColumns`, persisted through `column.fixed`, and disabled for massive/read-only datasets.


## ROI 68 patient registration foundation

Patient Registration is now a MUMPS-driven module foundation using synthetic sample data. `MIOOSPAT` owns patient-specific schema backfill (`INIT`), field validation (`VALPAT`/`VALFIELD`), query metadata (`PATMETA`), and audit/status markers (`AUDPAT`). `MIOOSTBL` remains the shared table engine and calls `MIOOSPAT` only when dataset is `patient-registration`. Do not claim HIPAA compliance; docs must say HIPAA-ready architecture only and require deployment/operations controls before real PHI.


### Table regression fix after ROI 68

The Advanced Table must not reference a free `vm` variable inside root methods. `backendTableApplyPayload` must call `this.backendTableNormalizeFixedColumns(...)` when applying fixed-column metadata. A previous free-variable reference produced `vm is not defined` above the table and broke editable-cell save refetches. Keep cell saves on the shared `cell.save` mutation path and verify payload application before proceeding to ROI 69.

## ROI 72C Start Menu Rewrite

The Start Menu was rewritten as a dedicated, isolated ROI. Preserve this separation: future Start Menu work should not mix terminal, patient, table, or explorer rewrites unless explicitly requested. The menu must continue to source entries from `startMenuGroups()` so App Catalogue modules, Desktop VFS entries, language shortcuts, theme presets, Folder Explorer, and system tools remain available. The component is `start-menu-popup` in `public/mioos/app/mioos_shell_ui.js`; helper methods are in `public/mioos/app/mioos_core.js`; CSS is marked with `ROI 72C Start Menu Rewrite` in `public/mioos/mioos.css`.

## ROI 72C follow-up — Start Menu folders, Theme Login, and text viewer stability

- Start Menu groups and VFS folders are expandable.
- Subfolders are lazy-loaded through `fs.list` and rendered recursively without preloading the whole VFS tree.
- Popup Start Menu variant is movable by dragging its header.
- Initial boot defaults to `Glow` unless a server active theme profile or explicit user-local applied theme exists.
- Runtime login uses Theme Studio login background/avatar/warning/disclaimer settings.
- Protected theme/blob URLs remain sanitized before authentication.
- Theme Studio image upload parsing is robust against empty/non-JSON error responses.
- Text file viewer falls back to `/api/mioos/fs/blob` when socket reads cannot hydrate content.

## ROI 72C2 viewer/upload/server-theme hotfix

Source-of-truth notes: the shell must register `mioos-surface-viewer` for basic file previews. Theme Studio uploads must use server-backed theme asset routes with no DataURLs and no localStorage theme persistence. Start Menu VFS folders must expand recursively without closing the menu. New desktop icons must be placed in the next open grid slot, and the Desktop should include a Programs folder with core launcher shortcuts.


## ROI 71C3 VFS blob, Explorer, Start menu, text viewer, and Theme CSS hardening

Authenticated wallpapers served through `/api/mioos/fs/blob` must compute `Content-Length` from actual VFS data chunks via `REPAIRSIZE^MIOOSFS`, not stale metadata. Multipart VFS writes must count bytes with `$ZLENGTH`/`$ZEXTRACT`.

Login-screen assets must continue to use the public-login asset route only for active login background/avatar/banner. Do not regress back to protected `/api/mioos/theme-asset` URLs before auth.

Folder opens should create distinct Explorer windows. Start menu Language, Themes, and System groups are open by default. Text viewers must always leave loading state and fall back to authenticated blob reads if command reads fail.

Theme Studio custom element CSS textareas parse declarations such as `background: radial-gradient(...)` and map them to live CSS variables for active titlebar, inactive titlebar, window body, taskbar, and Start menu.

## Source note — ROI 71C3 regression follow-up

When working from this source, preserve these regression contracts:

- Clean boot/default server theme is `glow`, not `luna-blue`.
- Desktop file entries must dispatch through `openFileViewerWindow()` and open media/image/PDF/text/structured viewers directly.
- Text-like files should use the WebSocket `fs.read.range`/`fs.read` path first. HTTP blob reads are only a fallback when socket commands are unavailable.
- Media viewer toolbar must not contain fake File/Edit/Help buttons and must not duplicate the file name; keep a functional Loop toggle.
- Theme Studio supports `desktopBackground` custom CSS mapped to desktop wallpaper/background variables.
- Login warning image is a banner, not an avatar.
- RTL locale changes apply document/shell `dir` and `is-rtl` immediately.
- VFS blob streaming must account for one-chunk files larger than the default stored chunk size to avoid `ERR_CONTENT_LENGTH_MISMATCH`.

## Uploaded desktop background streaming

Uploaded desktop background images follow a strict binary contract. Theme upload chunks under `^MIO("MIOOS","THEMEASSET",...)` may be uneven, so `PROMOTEW^MIOOSTHEME` must re-chunk them into the VFS chunk size before writing `^MIO("MIOOS","FS","DATA",ID,...)`. Do not copy upload chunk nodes directly into VFS wallpaper data.

Promoted wallpaper VFS blobs are identified by `themeWallpaper` or `sourceAsset` metadata. `/api/mioos/fs/blob` must stream those wallpaper blobs by cumulative stored-byte offsets, must not use the media warmup partial-response path, and should use no-store cache headers with cache-busted wallpaper URLs.

## Text media viewer contract

Text-based file viewing is chunk-stream only. Use `fs.text.chunk` for reads and `fs.text.save` for saves. Do not reintroduce browser blob fallback helpers such as `fetchTextBlob`, `readTextFileResilient`, or `fs_blob_unavailable`; those paths caused full-file downloads and duplicated requests for large text/markdown files. Keep the scrollbar mapped to byte offsets, keep chunk requests de-duplicated, and keep the bounded cache pruning behavior in place.
