# MIOOS

## 2026 desktop simplification update
- The active shell now uses **one desktop** instead of multiple workspaces.
- Explorer, Transfers, Customize, and Folder Properties use a cleaner classic Windows-style desktop UX.
- The taskbar clock shows both time and date.

## 2026 Product Reset

MIOOS is a **secure application workspace and operating shell for MUMPS modernization**. It is designed to host modernized legacy workflows, internal tools, terminal access, file operations, and controlled administrative experiences in enterprise deployments.

### What MIOOS is
- A runtime shell for serious MUMPS applications.
- A file and transfer workspace rooted in **Home**.
- A token-driven customization platform that can emulate multiple OS-style paradigms with original assets.
- A platform designed for secure, auditable, least-privilege deployments.

### What MIOOS is not
- Not a generic browser toy desktop.
- Not a bundle of unrelated demo utilities.
- Not automatically HIPAA compliant. It is a HIPAA-ready platform architecture when implemented and operated correctly.

### First-class surfaces
- Home
- Terminal
- Transfers
- Customize
- Folder Properties

### Product changes in this reset
- Home replaces My Computer/My Documents as the main user root.
- Folder windows now support back, forward, up, address navigation, view modes, sorting, properties, and per-folder customization.
- The taskbar groups windows and provides overflow handling.
- The start menu is now a focused launcher instead of a crowded demo panel.
- Theme Studio is replaced in-product by Customize.
- Notes, Ops Center, App Catalog, Control Panel, Security Center, Debug Center, and Diagnostics are removed from the active shell experience.

### Architecture highlights
- Server-authored boot contract preserved.
- Websocket-first command transport preserved.
- VFS metadata extended for attributes, sharing, folder icon/background, and view/sort persistence.
- `7.scoped.css` removed from active runtime loading.
- `mioos_reset.css` introduced as the focused visual layer for rewritten shell surfaces.

### New architecture docs
- `Architecture_Overview.md`
- `Theme_System.md`
- `VFS_Metadata_Model.md`
- `Drag_Drop_Rules.md`
- `Transfer_Manager.md`
- `Migration_Notes.md`

## ROI 57 — classic shell cleanup and VFS routing hardening
- `fs.list` now resolves explorer targets by `id`, `path`, or `parent` so Home navigation, websocket commands, and folder refreshes all use the same contract.
- Explorer now closes any open folder context menu before opening another context menu surface, which prevents the desktop menu and folder menu from stacking on top of each other.
- The active shell keeps tray-panel notifications only; stale explorer menubar/taskpane CSS and the old top-right notification-stack CSS were removed from the runtime stylesheet.
- The current shell contract remains one desktop rooted at **Home**, with Terminal, Transfers, Customize, and Folder Properties as the first-class built-in windows.

Legacy ROI notes remain below for implementation history.

---

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


## Customize ROI

Customize is the supported appearance editor in MIOOS. It now uses a classic display-properties-style window with desktop and mobile previews, editable theme profiles, original Meadow Classic / Glass Horizon / Graphite Dock / Ember Panel preset families, and token controls for wallpaper, color, typography, metrics, and advanced overrides.

Theme profiles are now loaded and saved through globals-backed theme routes with local fallback. Wallpaper, per-folder background images, and per-folder icon images can be uploaded into the virtual filesystem and referenced through blob URLs instead of base64 payloads.


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

ROI 33 — HTTP binary chunk transport for resumable uploads and hardened pause/resume

## ROI 34 — Binary upload integrity, chunked download decoding, and preview hardening
- Normalized uploaded binary storage so both HTTP raw-binary uploads and websocket base64 uploads commit into the VFS as raw bytes instead of JSON-transport strings.
- Superseded by the current direct authenticated HTTP blob/range workflow for binary download and preview.


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


## ROI 40 — resilient resumable uploads and tuned media/download transport

- Added automatic upload auto-pause on connection loss and browser offline events so interrupted HTTP chunk uploads stay resumable instead of flipping to failed immediately.
- Fixed resumed-upload transfer controls so Pause remains available after Resume, including persisted transfer recovery flows.
- Corrected `FSBLOB^MIOOSAPI` media-first partial-window behavior so `stream=media` no longer expands to the full file on the first non-range request.
- Tuned default transport values for higher throughput: VFS chunk size `860000`, upload chunk bytes `860000`, upload concurrency `6`, HTTP blob send target `860000`, media initial bytes `860000`.
- Reduced main-thread upload overhead by throttling transfer progress updates during parallel HTTP chunk uploads.
- Note: raw HTTP binary upload already sends `Blob.slice()` directly, so web workers are not the primary lever there; the next upload ROI should focus on optional dedicated upload workers for scheduling/telemetry and measuring whether they improve real throughput on the target browsers.


## ROI 51 — Transfer workflow simplification and dead-code removal

MIOOS now keeps one supported transfer workflow in the app runtime:
- uploads use HTTP binary chunk session routes only
- binary download and preview use direct authenticated HTTP blob/range only
- websocket `fs.read.range` remains only for bounded text preview and text viewers
- redundant websocket upload/download fallback plumbing and the unused upload worker file were removed


## UI reset roadmap

The current front-end work is following a three-wave shell reset.

Wave 1 focuses on the shell foundation only:
- production-oriented theme keys
- local shell asset loading only
- dynamic window creation fallback
- draggable sign-in surface
- corrected desktop icon scale and positioning

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

## ROI 54 — shell-standard app actions and built-in app polish
Built-in desktop applications now share one shell action model for confirmations, clipboard exports, destructive actions, and toast feedback.


## ROI 55 — websocket batch uploads and socket-pool observability
- Explorer worker uploads now have a first-class `fs.upload.batch` websocket path with single-chunk fallback retained for safety.
- Transport diagnostics now include a server-side socket registry summary, socket-cap telemetry, and upload batching settings.


## ROI 56 — single-desktop simplification
- The active shell now uses one desktop instead of multiple workspaces.
- Window visibility, taskbar grouping, and terminal launch now operate on one desktop surface.
- Workspace compatibility fields remain in the boot contract only where they simplify migration.


## ROI 58 — unified shell overhaul
- Added a new shell-overhaul stylesheet loaded after the legacy shell layers so the taskbar, launcher, explorer, transfers, and customize surfaces can be modernized without abandoning the native desktop window grammar.
- The shell now follows a 7.css-primary plus Basecoat-augment model: 7.css anchors the OS window posture while Basecoat-style polish is reserved for title controls, grouped actions, fields, and emphasis buttons.
- Explorer now renders with a Windows-like address path, navigation rail, detail table, and preview pane while keeping the existing MIOOS file operations and websocket flow.
- Transfers now render as a more serious transfer center with a hero progress surface, stat cards, queue rows, and direct recovery actions.
- Customize now exposes a richer multi-section theme editor with unified profile tokens for desktop, panel, launcher, window chrome, typography, effects, and export/runtime preview.


## ROI 59 — shell persistence and explorer assets
- Notifications now open the tray automatically and the tray surface is presented as **Notifications** with Clear all and Close actions.
- Home explorer now promotes **Desktop** instead of Shared Root, and the default Welcome.txt seed file is no longer created automatically.
- Explorer folder context actions now flow through the global shell context-menu surface so menus are not clipped by window bounds.
- Customize persists theme profiles through globals-backed routes and supports uploaded wallpaper assets stored in the VFS.
- Folder Properties now supports uploaded background and icon assets stored in the VFS and persisted through folder metadata.
- Transfers now show an overall progress bar plus per-file progress rows and support multi-file upload selection.

## ROI — Transfer robustness and shell wiring hardening

This pass keeps the single-desktop shell direction and hardens the remaining UI/runtime gaps after the unified shell overhaul:

- HTTP binary uploads now guard against duplicate/finalize races and reconcile `missing_chunk` commit failures by querying upload status and resending the missing tail.
- The transfer window exposes per-file Pause, Resume, Retry, and Cancel controls, with status-colored rows and compact native-dialog proportions.
- Explorer and Start Menu overflow behavior is tightened for large file lists and long names.
- Customize/theme controls now expose more runtime CSS variables directly so non-preset options visibly apply during live preview.
- Read-only file/folder attributes are enforced in the VFS permission gate for write/delete operations, including owner operations.

### ROI follow-up: server-rendered theme boot, upload reconciliation, and shell polish

This pass removes the unauthenticated boot-time `/api/mioos/theme/load` request. The initial shell theme is rendered through MIOTPL using inline shell CSS variables from `MIOOSUI`, while the Customize window can still load/save profiles after authenticated shell access. Multi-file upload commit is hardened by reconciling server upload status before finalize and by recounting received chunk bytes during commit. Explorer and transfer surfaces also receive additional compact sizing and overflow hardening for long filenames and large lists.

### ROI 60 — server-rendered theme first paint and focused shell polish

This ROI moves active theme application back into the initial MIOTPL render path so the shell no longer performs an unauthorized `/api/mioos/theme/load` request before sign-in. `MIOOSST` now exposes the active globals-backed profile in boot state, `MIOOSUI` resolves matching CSS variables for first paint, and the client only reloads saved themes from the Customize window after authentication. The pass also hardens wallpaper upload ID detection, removes completed-transfer duplication from the active queue, and adds native-shell sizing overrides for Explorer, Transfers, Start Menu, and Customize previews.

## Backend Table Component

MIOOS includes a reusable backend table component for application screens that need Explorer-like resizable details tables without copying Explorer code. The component is served by `MIOOSTBL` through `/api/mioos/table/query` and rendered by `mioos_table.js`.

See `docs/mioos/Backend_Table.md` for the query contract, feature matrix, extension rules, and regression coverage.

## UI Modules

MIOOS includes a UI Module foundation for internal and user-created modules. It is opt-in at launch time: set `CONF("mioos","modules","enabled")=1` and `CONF("mioos","modules","appCatalogEnabled")=1` to expose the catalog app. The module registry is built by `MIOOSMOD`, injected into boot as `uiModules`, exposed over `/api/mioos/modules/catalog`, and rendered by `mioos_modules.js` through the UI Modules app.

The first registered component is the backend table component (`table` / `mioos-full-table`). See `docs/mioos/UI_Modules.md` and `examples/mioos_modules/table` for the module contract and first example.

### ROI 57 — Safe first paint and opt-in UI Modules

MIOOS renders theme CSS variables through MIOTPL at boot, but authenticated internal asset URLs such as `/api/mioos/theme-asset` and `/api/mioos/fs/blob` are intentionally suppressed before sign-in. This prevents pre-login 401s while preserving backend-loaded theme tokens for first paint.

The UI Module registry, module catalog API route, WebSocket catalog command, client module registry, and table component remain installed in the source tree. They are launch-disabled by default: both `CONF("mioos","modules","enabled")=1` and `CONF("mioos","modules","appCatalogEnabled")=1` are required to inject module manifests and expose the catalog window.

## ROI 64B — UI Modules examples gallery

The `UI + Form Elements` module now uses `mioos-surface-ui-elements`, a standalone interactive component gallery for module authors. It replaces the previous static table-backed UI-elements sample and avoids backend table errors during example launches. The gallery documents inputs, selection controls, validation, saving/loading states, modal and confirmation dialogs, toasts, file-picker metadata, and module-safe HTTP persistence patterns.


## ROI 64C advanced table

The standalone advanced table now uses `mioos-advanced-table-v8` and can be embedded by internal or user-created modules through `mioos-surface-table`. See `Backend_Table.md` and `ROI_64C_Advanced_Table_Rewrite.md`.

## ROI 64C redo 2 note

The advanced backend table now uses `mioos-advanced-table-v8`, WebSocket-first query/mutation commands, compact default density, a viewport-safe editor dialog, read-only massive dataset safeguards, and a visible Table Samples showcase with copyable API variations.

### ROI 64E table correction

The advanced table contract is now `mioos-advanced-table-v8`. This update focuses on mutation correctness and MUMPS-first authoring: table samples show dataset globals, module `MOD(...)` registration, and required routine reload/test commands. Row details moved into the control column, the column selector is modal-only, and column editing appears only when column CRUD is enabled.

### Table stabilization and next ROI sequence

The advanced table stabilization pass keeps the contract at `mioos-advanced-table-v8` and adds typed filter modals, advanced include/exclude/range filtering, bounded draggable table dialogs, server-side selected-row CSV export, select-option dictionary updates through `column.option.add`, immutable column keys on edit, and a low-shift loading bar.

ROI 64I through ROI 64K are implemented: editable cells, column reorder, and fixed columns are now part of the Advanced Table contract. ROI 64L hardening is documented in `ROI_64L_Hardening_Polish.md`.


### ROI 64I editable cells

Editable cells are now server-authoritative. Schema columns may set `editable` and optional `cellCallback`; the browser renders the correct inline controller from the schema type and saves through `cell.save` over WebSocket with HTTP fallback. The network indicator is now a bar-only surface with no text block to avoid table layout jumpiness.

### ROI 64J column reorder

ROI 64J is implemented for Advanced Table modules. MUMPS modules enable it with `tableState.config.features.columnReorder=1`; users then reorder columns from the Columns modal. The UI sends `column.reorder` via WebSocket with HTTP fallback, and `MIOOSTBL` validates and persists the schema order server-side.



### ROI 68 — Patient Registration foundation

ROI 68 is implemented as a patient-registration module foundation. `MIOOSPAT` owns patient-specific schema backfill, field validation, query metadata, and audit/status markers while `MIOOSTBL` remains the shared table query/mutation engine. The module remains synthetic sample data and documents HIPAA-ready architecture only, not HIPAA compliance. See `ROI_68_Patient_Registration_Foundation.md`.

### ROI 64L — Advanced Table hardening and polish

ROI 64L is implemented as a stabilization pass for ROI 64F–64K. It completes the fixed-column runtime path, removes layout-shifting loading UI, keeps dialogs MIOOS-owned and draggable, and documents the final MUMPS-first table hardening contract in `ROI_64L_Hardening_Polish.md`.


## ROI 72C Start Menu rewrite

ROI 72C is dedicated entirely to the Start Menu component. The menu is now a modern, mobile-friendly launcher with grouped shortcuts, clear source badges, search, keyboard navigation, and a bottom-sheet layout on smaller screens. It preserves existing links from the App Catalogue, server-authored modules, language options, theme presets, shell tools, and Desktop VFS entries.

## ROI 72C Follow-up — Start Menu folders, Theme Login, and viewer stability

The Start Menu launcher now supports expandable VFS folders/subfolders through lazy `fs.list` loading, and the popup variant is movable like a modal. Initial first boot defaults to `Glow` unless a server-rendered active theme profile or explicit user-local theme exists. Runtime login uses Theme Studio login assets/disclaimer while still sanitizing protected asset URLs before authentication. Text-file viewers use the WebSocket text chunk contract for hydration; stale whole-file HTTP blob fallbacks must not return for large text files.

## ROI 72C2 viewer/upload/server-theme hotfix

ROI 72C2 fixes the file viewer surface, Theme Studio image uploads, recursive Start Menu folders, desktop icon placement, and server-only theme persistence. Theme images continue to use authenticated server asset URLs and are sanitized before login.


## ROI 71C3 — VFS blob, Explorer windows, Start menu, text viewer, and Theme CSS hardening

ROI 71C3 repairs authenticated VFS blob `Content-Length` by recalculating the byte length of stored chunks, fixes multipart upload byte accounting for future files, keeps login images on a public-login-only asset route, opens each folder in a distinct Explorer window, opens Language/Themes/System Start menu groups by default, hardens dark Start menu folder title contrast, prevents text viewers from hanging on `Loading file…`, and adds Theme Studio custom CSS entry points for active/inactive titlebars, windows, taskbar, and Start menu.

## ROI 71C3 regression follow-up

The current shell keeps the `glow` theme as the clean-install default, opens desktop files directly in their matching viewers, and reads text/structured files through WebSocket commands before falling back to HTTP. Media viewers intentionally expose only functional playback chrome: native controls plus a Loop toggle.

Theme Studio now has a Desktop background custom CSS field. MUMPS developers and administrators can paste declarations such as `background-image: radial-gradient(...);` or `background-color: #0f172a;` without writing frontend code. Login warning images render as full-width banners, and RTL locale switches apply document direction immediately.

## Uploaded background image responses

Uploaded desktop backgrounds are stored first as theme assets and may later be promoted into VFS wallpaper files. Promotion must re-chunk source asset data into the VFS chunk size instead of copying arbitrary multipart chunk boundaries directly. This prevents offset reads from serving only the first portion of an image correctly and then corrupting the rest.

Wallpaper VFS blobs are detected by `themeWallpaper` / `sourceAsset` metadata and streamed by cumulative stored-byte offsets. They bypass media-preview warmup truncation and use `Cache-Control: private, no-store, max-age=0` plus a cache-busted wallpaper URL so new uploads are not confused with stale image responses.

## Text viewer regression contract

The text media viewer must use the `fs.text.chunk` stream path for opening and previewing text-based files. The old browser blob fallback helpers (`fetchTextBlob`, `readTextFileResilient`, and `fs_blob_unavailable`) are intentionally retired so large text files do not trigger whole-file `/api/mioos/fs/blob` downloads. Regression tests in `T074`, `T076`, and `T084` lock the chunk reader, request de-duplication cache, backend WebSocket command, and editable save path.

## Text viewer toolbar and threshold contract

Text viewer editing is owned by the common window toolbar, not by an extra in-window edit panel. Use File -> Edit Text / Save Text or the Text menu actions for edit, save, refresh, zoom in, zoom out, and reset zoom.

The text viewer uses a configurable threshold before entering the virtual byte-offset chunk stream. `CONF("mioos","fs","textChunkThresholdBytes")` defaults to `2411725` bytes, approximately 2.3 MB. Text files at or below that threshold are loaded as a single text chunk so Notepad-style edit/save remains simple and smooth. Files above the threshold use `fs.text.chunk` with scrollbar-to-byte-offset synchronization and request coalescing.

Regression coverage in `T085^MIOOST` locks the toolbar-only text actions, hidden About toolbar, smooth scroll coalescing, stale chunk-cache invalidation after save, dark transfer/scrollbar surfaces, details-view filename truncation, and Patient Registration banner removal.

## ROI 86 theme/profile and patient table stabilization

This pass locks the server-backed user theme contract and related patient/table module regressions:

- Theme saves are save-as operations for user themes, so more than one custom theme can exist for a user.
- Dark mode is persisted through `mode`, `activeMode`, `defaultVariant`, and `themeConfig.darkEnabled` so reloads do not silently fall back to light mode.
- Boot state includes `desktop.userThemeProfiles`; the Start Menu Themes group can list saved user themes in addition to built-in presets.
- Locale shortcuts are guarded before generic app launching so Language → Arabic/Spanish/English changes the URL/locale instead of opening a random window.
- `ROI2Folder` is filtered from desktop rendering as a legacy test artifact.
- Patient Registration add-row uses the backend `row.add` mutation; add-option updates the local option list and selects the new value before refetch.
- New Table Module drafts default to the backend table surface and `mioos-advanced-table-v8` contract, with styled modal surfaces for light/dark themes.

## Final regression stabilization contract

This ROI locks the source-accurate shell contracts without changing the MUMPS.IO architecture. The text media viewer uses bounded `fs.text.chunk`/HTTP text windows with byte-offset scroll synchronization. It maintains an in-flight request map and bounded chunk cache, and it no longer falls back to a full `fs.read` browser payload when range/chunk reads fail. Save remains deliberate: text files enter full edit mode on demand by stitching bounded HTTP chunks, then save through HTTP chunk/upload plumbing rather than a large WebSocket payload.

Theme Studio saves `mode`, `activeMode`, `defaultVariant`, `themeConfig.darkEnabled`, and dark variant data together. Startup hydration reads the same fields from the active server profile so a saved dark custom theme loads as dark on the next boot, while multiple user theme profiles remain available in the Start menu theme group.

Explorer Details view has a dark-mode contrast rule: the selected row uses a light selected background and dark text only in details rows. The Explorer toolbar order is File, Edit, View, Tools, Help, separator, then Back, Forward, Up, Refresh, Upload, Download, New Folder, Rename, and Delete. VFS application shortcuts expose icon and target app metadata to Explorer; double-click and context Open route through the same launcher path. `ROI2Folder` is filtered from both desktop rendering and Explorer’s Desktop folder listing.

Transfers use the animated `mioos-transfer-status-panel` contract instead of the old text banner. Patient Registration and UI table modules use deterministic toast/error feedback, `MUTATE^MIOOSTBL` for HTTP and WebSocket mutation paths, and the same `mioos-advanced-table-v8` table-backed module contract.


## Checkpoint stabilization 2026-05-05

This checkpoint adds two hardening contracts on top of the final regression stabilization pass. First, the old text edit-size cap has been removed; large files load for editing by stitching HTTP text chunks. The browser no longer applies `textViewerDraftByteLength`, `FSTEXTSAVE^MIOOSWS` no longer rejects drafts solely because of an edit-size cap, and normal saves prefer bounded HTTP chunk/upload plumbing before small JSON or WebSocket compatibility paths.

Second, upload fallback behavior is binary-safe and DataURL-free. The preferred path remains HTTP binary chunk upload. If the shell must fall back to WebSocket chunks for binary content, it now declares `encoding=base64`, sends pure base64 chunk data with raw byte counts, and `MIOOSFSUP` decodes through `B64D^MIOSJWT` before committing raw VFS bytes. New uploads and persisted image assets must not be stored as DataURLs.

## Checkpoint stabilization follow-up pass

This checkpoint tightens the source-accurate baseline without changing the MUMPS.IO architecture.

- Startup dark themes now have a server first-paint marker and a Vue hydration apply step. `DESKCTX^MIOOSUI` emits `themeRootClass` from the active theme mode, the root template renders it, and `primeBootForFirstPaint()` applies the hydrated active profile before layout normalization. This prevents a saved dark user theme from booting visually as light until another theme action occurs.
- The Transfers window keeps the animated `mioos-transfer-status-panel`, removes the old banner-style status language, and can display a large active queue in one window. The browser keeps up to 250 transfer records and the visible queue request now asks for 96 active rows inside a scrollable transfer list.
- Patient Registration CSV import accepts normal quoted CSV fields, including embedded commas and escaped double quotes. Preview and commit still route through `MUTATE^MIOOSTBL`, `MIOOSPAT`, validation, and audit stamping.
- Large text viewing remains chunk-stream based. Full edit/save stays bounded by `full-edit-on-demand text loading`; oversize drafts are rejected on the client and by `FSTEXTSAVE^MIOOSWS`.

Regression coverage is extended in `T089^MIOOST` for first-paint dark boot, transfer queue capacity, quoted CSV import, and documentation markers.

## Login/theme/start-menu/text-viewer regression ROI

This ROI restores the source-accurate shell contracts for unauthenticated login, Theme Studio, dark titlebars, large text files, and Start Menu groups.

Unauthenticated boot renders only the login overlay and permitted public login assets. Taskbar, Start Menu, desktop icons, windows, shell popups, and authenticated asset URLs must stay hidden until the authenticated boot payload reloads the shell. Login feedback is non-blocking and dark-theme-aware: retries replace the previous message, rejected credentials use a generic message, network/server failures show safe operational text, and successful sign-in shows a short loading state before the desktop reloads.

Theme Studio Save now updates the currently active editable user theme. Creating a new user theme is explicit through **Save As / New Theme**. User-created themes can be deleted; built-in themes are locked. Deleting the active user theme falls back to a built-in theme and refreshes the saved theme list used by Theme Studio and the Start Menu Themes group. Dark mode applies dark defaults underneath the saved theme CSS variables so user-defined `--titlebar-bg`, `--titlebar-text`, `--titlebar-inactive`, `--titlebar-inactive-text`, and window-control colors survive reload.

Large text viewing remains chunked. `fs.text.chunk` is the read path for large text files, frontend chunk requests are de-duplicated, scroll position maps to byte offsets, transient socket timeouts show retry feedback without closing the viewer, and the backend range loop quits cleanly on segment errors instead of spinning until the socket fails. Full edit/save stays bounded by `full-edit-on-demand text loading`.

Start Menu groups are collapsible with mouse and keyboard-accessible toggles. Built-in groups and the user Themes group share the same collapse state. Collapse state is session-local in the existing Vue `startMenuUi.expandedGroups` object; no server preference was introduced in this ROI.

## ROI 91 large text, dark-theme, table-module, and transfer hardening

This ROI keeps the MUMPS-first MIOOS architecture unchanged while correcting four regressions:

- Text viewers now keep `textChunkThresholdBytes` as the small-file/full-edit threshold and use separate `textChunkBytes` / `textChunkSizeBytes` values for the actual transport chunk size. The default text chunk is 65536 bytes and is clamped well below the prior 2411725-byte threshold so WebSocket control messages do not attempt multi-megabyte text payloads.
- Large text files open immediately in HTTP chunked view mode and can be switched to full edit-on-demand mode by choosing Edit. Small and medium files are loaded as a full editable document by stitching multiple safe chunks. Saving clears stale text chunk caches and reloads the saved content through the safe chunk path.
- A POST `/api/mioos/fs/text-chunk` route is available as an authenticated HTTP fallback for text chunks. It calls `READWIN^MIOOSFS` and returns only the requested byte window, never the whole-file `/api/mioos/fs/blob` payload.
- Dark theme contrast is restored across Start Menu items, child items, context/window/toolbar menus, common panels/cards, module surfaces, explorer/table/patient labels, and the Transfers surface.
- The UI Modules **New Table Module** flow now gives toast/status feedback, normalizes generated table-backed modules to `componentKey=table`, `surface=mioos-surface-table`, and the current `mioos-advanced-table-v8` table contract, and exposes saved table definitions through the catalogue payload.
- Transfers are dark-surface aware. Pause buttons use explicit readable contrast, and status shimmer/ripple is gated by the active-transfer state; idle panels are static.

MUMPS developers should configure text behavior with separate values:

```mumps
SET CONF("mioos","fs","textChunkBytes")=65536          ; transport chunk size
SET CONF("mioos","fs","textChunkThresholdBytes")=2411725 ; full-edit threshold
SET CONF("mioos","fs","fullEditOnDemand")=65536       ; full edit-on-demand/save cap
```

## ROI 92 — dark menu, text viewer, taskbar, and mobile window hardening

This ROI preserves the existing MUMPS/YottaDB + MIOTPL + MIOOSWS/MIOOSAPI + Vue 3 Options API architecture while tightening UI regressions in-place.

- Dark theme menu text is scoped to menu surfaces: Start Menu launchables, pinned/group rows, nested child rows, window toolbar menus, Explorer context menus, popup menus, and classic menubars use dark menu/theme variables without forcing light mode to white.
- Large text opening remains chunked through `fs.text.chunk`. Initial open is de-duplicated, idle viewers do not request neighbor chunks, scroll events explicitly arm the byte-offset load path, and failed chunk loads stop in manual-retry status instead of looping.
- Large text edit behavior remains safe: small/medium files stitch safe chunks for full edit/save, while oversize files stay in explicit `full-on-demand` mode with feedback.
- Window toolbar menu actions dismiss after mouse or keyboard activation. Inline Explorer/viewer/terminal/transfer actions still dispatch through their existing methods.
- Notifications/toasts inherit `--font-size-ui`, so Theme Studio global UI font size applies to alert text without hard-coded 11/12px overrides.
- Taskbar entries distinguish pinned-only apps, open apps, active/focused windows, inactive open windows, and minimized windows. Large window counts use a horizontal scroll marker and mobile taskbar rules.
- Mobile window movement uses pointer/touch titlebar drag and touch resize hooks. Window content, Explorer, and text viewer scroll areas keep normal touch scrolling.

## ROI 93 — dark Start Menu contrast and idle-safe large text viewing

This ROI keeps the existing MUMPS/YottaDB, MIOTPL, MIOOSWS/MIOOSAPI, VFS, and Vue 3 Options API UMD architecture unchanged.

Dark Start Menu launchable rows now have a scoped dark-mode readability contract. `.theme-dark-mode .mioos-start-menu-vue` defines dedicated readable Start Menu foreground variables, and launchable rows, pinned/group entries, nested child rows, hover, focus, selected, and disabled states use those variables only inside the Start Menu. Light theme is not globally forced to white, and other menu/context surfaces keep their own dark scoped rules.

Large text viewing remains chunk-stream based. `mioos.fs.textChunkThresholdBytes` is the small/medium-versus-virtual viewer threshold, while `mioos.fs.textChunkBytes` / boot `vfs.textChunkSizeBytes` is the per-request transport chunk size. The default transport chunk is 65536 bytes, clamped below MAXSTRING-risk payload sizes and intentionally far below the 2411725-byte virtualization/edit threshold.

Opening a large text file requests only the initial visible chunk. Scroll-driven chunk loads now require explicit user scroll intent (`wheel`, pointer/touch scrollbar interaction, keyboard navigation, or manual retry), so idle/programmatic scroll events cannot start an auto-load loop. Requests are still deduped by file id + offset + size, failures remain manual-retry/toast driven, and large files stay read-only above `full-edit-on-demand text loading` unless a future ROI implements tested chunk patch semantics. Small/medium text editing and `fs.text.save` remain supported; a successful save clears stale text chunk cache before reloading.


## ROI 95/96 — local CodeMirror text editor foundation

MIOOS text viewers use the local CodeMirror 5.65.21 package only when it is available from `public/mioos/vendor/codemirror/`. The browser helper is `public/mioos/app/mioos_codemirror.js`; it loads assets lazily, reuses already-loaded or in-flight script/style tags, marks completed assets with `data-mioos-codemirror-loaded`, and keeps the plain text fallback usable if CodeMirror core cannot load.

The supplied local package includes only a small source-accurate mode/theme set. MUMPS (`.m`, `.rou`, `.mumps`, `.int`, `.mac`) uses `mumps`; Markdown uses `markdown`; HTML/XML use `xml`; SQL uses `sql`; CSV uses `spreadsheet`. JavaScript, JSON, CSS, YAML, HL7, X12, log files, and unknown content remain `text/plain` unless a future attached local package provides tested modes.

Small and medium text files may use CodeMirror for read-only viewing and full-document editing loaded through chunks. Large files stay in the existing chunked read-only path above `full-edit-on-demand text loading`; MIOOS does not pretend to support unsafe random-access whole-file edits. Saving still clears stale chunk caches and reloads the current view through safe text chunks.

ROI 96 hardens the loader race path: if a CodeMirror `<script>` or `<link>` already exists but has not finished loading, the helper waits for the same in-flight asset instead of treating it as loaded. Theme or mode load failures are non-fatal and fall back to CodeMirror `text/plain`; only missing CodeMirror core falls back to the plain textarea/pre viewer.

## ROI 97 — Login-theme staging, local Marked previews, safe viewers, and upload/text hardening

ROI 97 restores the two-stage login workflow for local/offline shells. The unauthenticated page uses only the common pre-login theme: public-safe login background image and scoped login-background CSS. After the username stage, `/api/mioos/auth/login-theme` returns generic feedback plus the public-safe login-specific profile for that username when configured. Avatar, warning image, and login-specific styling are cleared whenever the username changes so stale visuals cannot survive between attempts. Theme image persistence continues to reject DataURLs and public login asset URLs are rewritten through `/api/mioos/theme-public-asset` rather than protected theme-asset routes.

Markdown files now open in a rendered preview backed by the vendored local Marked UMD file at `public/mioos/vendor/marked/lib/marked.umd.js`; editing continues through CodeMirror for bounded text files. Markdown and HTML previews render inside sandboxed `srcdoc` iframes without script execution. Large Markdown/HTML files stay in the chunked read-only text viewer instead of requesting a full blob. PDF files use the browser-native PDF viewer through the authenticated local file route and keep the normal download fallback.

Upload defaults were reduced to a MAXSTRING-safe HTTP chunk size while text viewing defaults were increased to the existing 256 KiB safe ceiling. Uploads no longer fall back to whole-file FileReader/WebSocket payloads; retries remain bounded and timeout errors surface as user-visible upload failures. Dark toolbar/menu normal states no longer draw per-item outlines, while `:focus-visible` remains styled for keyboard accessibility.


## ROI 98 — staged login visuals, dark UI hardening, and HTTP-first text chunks

- The staged login workflow remains split between the common pre-login background and the username/password stage. After a username is submitted, the public login-theme response can apply only controlled public-login assets for the account avatar, warning image, and login-specific CSS. Stale username-stage avatar/warning/CSS references are cleared when the username changes, and protected theme/blob URLs are not emitted before authentication.
- Theme Studio dark-mode neutral clear controls are scoped with `data-theme-editor-secondary` and keep the requested `#004cff` text color with a light, focused button surface. Light theme button styling is not broadly overwritten.
- Simple/read-only table surfaces now have explicit dark-theme header, cell, hover, selected, and text-color rules while leaving the Advanced Table/editable table styling intact.
- Markdown and HTML rendered previews fill the MIOOS viewer pane, respect toolbar/client-area sizing, and use the existing viewer zoom controls. Markdown zoom is injected into the sandboxed `srcdoc` so Zoom In/Out affects rendered content rather than only the outer pane.
- Text viewer success/info status is transient and can be shown or pinned from the window toolbar. Error status remains visible so save/read failures are not hidden too quickly.
- Large text reads prefer the authenticated HTTP text-chunk endpoint. The WebSocket text chunk command remains a bounded fallback path, but the default large-file viewer does not use a full-file blob fallback. Chunk requests are keyed by file id, offset, and size, and stale responses are ignored.
- Chunked/virtual large text is read-only for save purposes unless the full bounded file is loaded. The save guard prevents overwriting a large file with only the visible chunk.
- Active text/save chunk defaults are now `65536` bytes; upload/download chunk defaults remain separate at `860000` bytes. The virtualization/edit threshold remains separate from transport chunk sizing, and server-side clamp checks remain in place.


## ROI 99 — warning-image staging, dark tables, and bounded text windows

ROI 99 fixes the current regression set without changing the MUMPS-first architecture. The username stage now prefers the login-specific public profile returned by `MIOOSTHEME` before the common profile, so a configured `loginScreenConfig.warningImageUrl` is applied through `/api/mioos/theme-public-asset?id=...` after a login name is submitted. Common pre-login background/CSS remains the only visual asset before username staging. Stale username-specific avatar, warning image, and CSS are cleared when the login name changes; missing warning images clear their DOM source instead of leaving broken-image UI.

Dark Theme table readability is handled by a scoped table contract under `.theme-dark-mode` for read-only/simple tables, dense operational tables, editable CRUD/Advanced Table, Patient Registration tables, filter/modal tables, selected rows, headers, empty rows, validation/error states, and inputs/selects/textareas. The rules use table-specific variables such as `--mioos-dark-table-cell-bg` and `--mioos-dark-table-text` and do not add global wildcard color overrides, so Light Theme tables keep their existing behavior.

Large text viewing now separates the virtualization threshold from transport chunk size. `mioos.fs.textChunkThresholdBytes` stays at `2411725` for deciding when virtual/chunk mode begins. `mioos.fs.textChunkBytes`, boot `vfs.textChunkSizeBytes`, and `vfs.textChunkSafeMaxBytes` default to `65536` so HTTP and WebSocket text chunks stay below conservative MAXSTRING/socket/JSON payload ceilings. The viewer loads only the requested visible byte range, dedupes by file id + offset + size, prunes cached chunks, catches timeout/read failures, and waits for manual retry instead of looping.

Large text editing remains explicit and HTTP-bounded. Files open as `full-on-demand`; choosing Edit stitches the full text from safe HTTP chunks, and save uses chunked HTTP upload/save plumbing rather than a large WebSocket payload. A successful save clears stale chunk caches before reloading/revalidating the current view.


## ROI 100 large text edit cap removal and socket-timeout avoidance

The arbitrary `maxTextEditBytes` edit cap has been removed. All text-like files remain viewable through the bounded HTTP text-chunk route (`/api/mioos/fs/text-chunk`) so opening a large file requests only the visible range and does not fall back to large WebSocket payloads. The default text transport chunk is now `65536` bytes, while `textChunkThresholdBytes=2411725` still only decides when the virtual viewer starts.

Large files open quickly in HTTP chunked view mode. Choosing **Edit** explicitly stitches the file from sequential HTTP chunks into the normal text editor, marks the stream as `full-on-demand`, and then save writes the full edited content through bounded HTTP chunks using the existing upload routes, with `/api/mioos/fs/text-save` retained as a small/compatibility fallback and the WebSocket `fs.text.save` command retained only as an explicit compatibility path. Save still clears stale text chunk caches and reloads the current view after success. The viewer still avoids `/api/mioos/fs/blob` full-file fallback, idle prefetch loops, and automatic socket retry loops for large text.

## ROI 101 — dark table correctness and explicit editable text sessions

Dark Theme table rendering now uses a shared variable-driven table contract. The contract defines table surface, cell, alternate row, header, text, muted text, border, hover, selected, editable input, button, modal, error, warning, and success colors. Scoped `.theme-dark-mode` selectors cover simple read-only tables, dense operational tables, editable CRUD/Advanced Table rows, Advanced Filter controls, Patient Registration rows/forms, permissions grids, module table previews, table dialogs/modals, empty rows, selected rows, hover rows, and validation states. The old broad `.theme-dark-mode *` scrollbar override was removed; Light Theme keeps the normal table selectors and variables.

Text-like files now open through an explicit editable session instead of a scrollbar-driven virtual viewer. On open, the shell creates a text stream with `loadStrategy='explicit-complete-http'`, clamps transfer chunks to the safe text chunk size, loads sequential HTTP chunks with bounded retry, stitches them into the editor buffer, and marks the editor editable as soon as the full safe browser buffer is available. Scroll position no longer triggers file loading, and the viewer does not issue idle scroll/prefetch loops.

Large text save now prefers the existing authenticated HTTP upload staging routes. The previous modified/size stale-conflict gate was removed because inconsistent metadata produced false save failures. The browser sends bounded chunks, commits only after all chunks are received, verifies the committed size when the backend reports it, clears stale text chunk caches, and reloads/revalidates the current editor after success. `/api/mioos/fs/text-save` remains only for small compatibility saves and now rejects payloads above the safe text chunk limit with `fs_text_save_requires_chunked`; the WebSocket text-save command has the same guard so large edits are not sent as giant JSON/socket payloads. MIOOS still cannot make a browser/CodeMirror safely edit multi-gigabyte strings in memory; such files are bounded by practical browser memory and editor capacity, while transfer and save paths stay below YottaDB/GT.M MAXSTRING-oriented chunk limits.

## ROI 103 — large text open guard and direct HTML preview

Large text files no longer auto-load the entire file when the explorer metadata is unknown or above the safe text threshold. The viewer opens a single bounded HTTP text chunk as a preview, disables scroll-triggered loading, and shows a clear warning instead of recursively issuing chunk requests until browser memory is exhausted. Files below the safe threshold still load through explicit HTTP chunks and become editable; manual edit for previewed files remains guarded by the browser edit cap.

HTML files now open as a sandboxed iframe backed by the authenticated `/api/mioos/fs/blob` inline route. They do not run through the text chunk editor path on open, so HTML preview behaves like a document preview and does not issue `/api/mioos/fs/text-chunk` requests just to render.

## ROI 102 — HTML edit action and bounded large-text preview

HTML files open as sandboxed iframe previews by default. The window toolbar now exposes **Edit File as Text** for viewer windows with a file id; choosing it switches the same viewer into the CodeMirror/plain-text editor path and loads the file through the bounded text chunk pipeline. This keeps HTML preview behavior while restoring explicit HTML source editing.

Large or unknown-size text files no longer escalate from initial preview into automatic full-document chunk loading. Opening such a file loads one bounded preview chunk only, keeps the preview pane scrollable, and leaves full editor loading as an explicit toolbar action guarded by the browser edit byte cap and chunk-loop/stalled-offset checks. The transient bottom status panel is no longer kept alive by a permanent “editable loaded” notice; it auto-hides unless pinned, retriable, or showing an error.
