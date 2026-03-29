# MIOMOS LLM Development Handoff

## What MIOMOS is

MIOMOS is a production-minded desktop shell built inside the existing **MUMPS.IO / MIO** web stack.

It is not a toy desktop demo, not a standalone Node runtime, and not a generic SPA. The project is deliberately **MUMPS-first**, **SSR-first**, and **MIO-native**.

The browser uses a thin **Vue 3 Options API UMD** layer to render and interact with state that is authored and persisted by MUMPS routines.

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
- **7.css** as a strong UI influence
- **Native Vue 3 Options API UMD + CSS window manager** in the browser

## Hard constraints

- No TypeScript
- No Vue Composition API
- No Node/Express runtime assumptions
- No OS.js runtime dependency in the browser shell unless a future ROI explicitly reintroduces a narrow adapter for a proven need
- No `ZSYSTEM`
- No `GOTO` in production code
- Keep MAXSTRING-safe handling for large payloads
- Use `^TMP($J,...)` or globals for large buffers
- Structured errors should include at least `ERR("routine")` and `ERR("error")`
- Tests must be quiet on success

## Namespace expectations

Stay inside the `MIOMOS*` namespace for subsystem work.

Likely routines and responsibilities:

- `MIOMOS` — main route/entry integration
- `MIOMOSAPI` — API handlers
- `MIOMOSWS` — websocket lifecycle and event routing
- `MIOMOSST` — session and desktop state
- `MIOMOSSET` — user settings catalog and persistence
- `MIOMOSWM` — window manager catalog, defaults, motion, snap behavior
- `MIOMOSTH` — theme catalog
- `MIOMOSVM` — server-authored view-model data
- `MIOMOSUI*` — reusable UI helpers and library surfaces
- `MIOMOST*` — tests

## Current project direction

MIOMOS should feel:

- professional
- stable
- readable
- healthcare-appropriate
- trustworthy
- dense when needed, but not cluttered

It should not feel like:

- a retro gimmick
- a CSS experiment
- a fragile websocket demo
- a collection of mismatched libraries

## Current implementation posture

As of the latest ROI baseline:

- MIOMOS has a server-authored desktop boot contract emitted as JSON
- Vue is a thin render/interaction layer over MUMPS-owned state
- the browser shell now uses a **MIOMOS-native Vue/CSS window manager foundation**
- the shell includes workspace, admin, security, settings, UI Library, chat, and terminal surfaces
- terminal rendering now uses xterm.js as the browser renderer over the existing MIOMOS command/websocket boundaries
- themes are server-authored in `MIOMOSTH`
- settings and window manager catalogs are server-authored
- admin/auth/observability/session posture exists and is tested
- UI Library has become a first-class surface rather than a placeholder

## Theme direction

The UI should combine:

- **7.css desktop influence**
- **MIOMOS modern polish**
- a **Windows XP inspired shell chrome** for the taskbar, Start menu, and context menus when it helps clarity
- compact, professional healthcare-oriented readability

Themes should be server-authored and include enough metadata to drive:

- desktop background
- surface colors
- border colors
- text and muted text
- accent colors
- title bar styles
- shadows
- icon/chrome feel

Light themes must be first-class, not an afterthought.

## Current shell correctness priorities

The next few ROI's should prioritize shell correctness over novelty.

Specifically:

- taskbar items must keep a **stable slot order** while focus changes
- window z-order and taskbar order must remain separate concepts
- Start menu sections must stay **predictable and pinned** instead of drifting with incidental state changes
- taskbar, Start menu, and context menu interactions should feel deliberate and muscle-memory-friendly
- correctness regressions in shell behavior should be treated as testable bugs, not cosmetic issues


## Native shell direction

MIOMOS should continue using a **native Vue/CSS window manager** rather than depending on OS.js.

That means:

- window lifecycle stays in MIOMOS Vue state
- chrome and motion stay in CSS
- MUMPS remains the source of truth for apps, windows, settings, permissions, layouts, and session state
- websocket and HTTP remain transport layers, not desktop frameworks

## Mobile direction

MIOMOS is still desktop-first.

However, the shell is now being prepared for smaller screens by switching to a **stacked-shell** behavior under a compact breakpoint instead of trying to preserve a literal desktop metaphor on a phone.

The browser may change layout strategy, but the following remain server-authored:

- routes
- apps
- windows
- settings catalogs
- view models
- session state
- permissions

## Terminal direction

The terminal is important and should keep the server-side MIOMOS ownership model while using a real browser terminal renderer.

Guidelines:

- one live terminal session should be owned coherently by the correct server-side process boundary
- browser input should be treated as keystream, not toy line submission, where possible
- reconnect behavior must be safe
- output replay and attach behavior must be explicit and stable
- never regress into split transport ownership across HTTP and websocket jobs

## UI Library direction

The UI library should become reusable both:

- inside MIOMOS desktop apps
- later in ordinary SSR MIO pages outside the desktop shell

It should explicitly cover or scaffold:

- buttons
- inputs
- selects
- textareas
- radios / checks / toggles
- tabs
- menus
- toolbars
- cards / panels
- dialogs
- tables / dense data grids
- badges / pills / status chips
- breadcrumbs
- drawers
- toasts / notifications
- steppers
- tree / list views
- command palette patterns
- responsive / mobile-ready render strategies

## Testing posture

Prefer test-backed UI/UX work.

Tests should assert:

- route metadata
- boot contract values
- SSR tokens and component presence
- settings catalogs
- view-model sections
- session/layout persistence behavior
- permission and admin posture
- terminal transport contract

Do not treat UI polish as untestable.

## Recommended workflow in a new chat

1. Audit the repo and existing MIOMOS docs first.
2. Read the current MIOMOS routines and tests before proposing architecture.
3. Continue in small ROI-based increments.
4. Prefer working code, SSR integration, tests, and UI correctness.
5. Return only modified files in folder structure unless asked otherwise.
6. Keep changes compatible with existing MIO conventions.

## Suggested continuation prompt

Use this prompt in a new chat with the repo zip:

---

You are continuing a production-minded project named **MIOMOS** inside my existing **MIO / MUMPS.IO** repository.

Before changing anything:
1. Audit the repo first.
2. Read the MIOMOS docs and current `MIOMOS*` routines.
3. Understand the routing, templating, websocket, auth, middleware, static asset, settings, session, window manager, and test conventions.
4. Work only in small ROI-based increments.

Core requirements:
- MUMPS/YottaDB + MIO foundation
- MIOTPL SSR
- MIOHTTP / MIOROUTE / MIOMW transport and middleware
- existing auth/session/permission patterns
- existing websocket support
- Vue 3 Options API UMD only in the browser
- no TypeScript
- no Node/Express runtime
- no ZSYSTEM
- no GOTO in production code
- MAXSTRING-safe patterns
- quiet tests on success

Current priorities:
- keep MIOMOS professional, readable, and production-minded
- continue hardening the UI library
- protect light-theme correctness
- improve compact/mobile-friendly rendering without abandoning the MUMPS desktop contract
- keep session and state management server-authored
- maintain or improve test coverage for UI/UX and state behavior

When you deliver an ROI:
- explain the goal briefly
- provide only modified files in their folder structure
- include or update ROI documentation
- do not introduce speculative architecture that ignores the existing repo conventions

---

## Good next ROI candidates

- native menus, context menus, and dialog parity
- richer keyboard accessibility and focus management
- responsive auth and settings surfaces
- richer table responsiveness and dense data layouts
- per-window persistence and mobile task switching
- deeper admin governance screens
- stronger terminal UX without regressing session ownership
- xterm.js is now the intended browser-side renderer; do not reintroduce fake transcript or textarea terminal UI layers on top of it
- reusable SSR UI components outside the desktop shell


## Shell chrome direction

Current shell direction favors a **Windows XP inspired taskbar, Start menu, and context menus** layered onto the MIOMOS native Vue/CSS window manager.

This does **not** mean turning MIOMOS into a retro clone. The rule is:

- borrow XP structure, contrast hierarchy, and affordances
- keep MIOMOS typography, content discipline, and healthcare-friendly readability
- avoid gimmicky nostalgia or low-contrast gradients
- preserve server-authored state and permissions

Use XP influence most strongly in:

- the bottom taskbar
- the Start button and Start menu split layout
- right-click desktop and window context menus
- task buttons and tray area


## ROI28 — WinXP shell polish and shell dialogs

This ROI continues the native Vue/CSS shell direction and deepens the **WinXP-inspired shell chrome** rather than expanding OS-like framework dependencies.

Key outcomes:
- taskbar refined into an **XP-style taskbar + quick launch + notify area** composition
- Start menu gains an **XP-style footer** with `Run…`, `Log Off`, and `Turn Off Computer` actions
- shell-level dialogs introduced for **Run**, **About MIOMOS**, and **Turn Off Computer**
- view model now exposes a `shellChrome` section so taskbar/start/tray/dialog surfaces stay MUMPS-authored
- smoke tests assert taskbar/tray/dialog contract tokens and shellChrome metadata

Development guidance:
- keep taskbar, Start menu, tray, and dialogs **server-described** where practical
- prefer **one coherent shell language** over adding isolated widgets
- preserve readability across light themes and compact/mobile modes
- continue avoiding OS.js expansion; the native MIOMOS shell is the primary direction

## ROI30 terminal rewrite note

The current MIOMOS terminal should be treated as an **xterm.js browser renderer** backed by a **MUMPS-owned terminal session**. The browser renderer is not the owner of session or transport state, and MIOMOS should not regress back to OS.js or a fake textarea-based emulator.

Important constraints for future work:
- keep terminal ownership on the MUMPS side
- prefer one coherent transport contract over split HTTP/websocket terminal ownership
- preserve `session.ui.save` support because the desktop shell persists UI state frequently
- keep tests quiet on success and avoid introducing compile-time extrinsic/procedure mismatches


## ROI32 posture

The current shell direction prioritizes **interaction correctness** over visual novelty.

Key shell rules now include:
- taskbar order is stable and separate from z-order
- taskbar click policy is `xp-toggle`
- Start menu remembers the active section
- only one shell surface should stay open at once: Start menu, context menu, or dialog
- context menus should be window-aware and disable impossible actions rather than hiding everything

When extending MIOMOS from this point, prefer deterministic shell behavior and testable contracts over adding more decorative chrome.


## ROI33 — Shell navigation, start search, and taskbar overflow

Current MIOMOS direction continues the native Vue 3 Options API + CSS shell. The current shell contract adds three correctness behaviors that future work should preserve:

- **Stable taskbar order with overflow:** task buttons remain in fixed taskOrder sequence. Hidden buttons move into a **More Windows** overflow list instead of being re-sorted when windows are focused.
- **Start menu search:** the Start menu now has a single search field that filters **programs, directories, and shell actions** from one place.
- **Keyboard shell model:** `Ctrl+Escape` opens Start, `Enter` launches the first Start-search match, and `Escape` clears search before closing the menu.

When continuing MIOMOS, keep these rules intact:

1. Never tie taskbar ordering to live z-index.
2. Any future grouping or overflow must preserve the visible order contract.
3. Start menu search should stay deterministic and test-backed.
4. Shell overlays must continue to obey the single-open-surface rule.
5. Persisted UI state may include Start-menu section and query, but it must remain bounded and safe for MUMPS globals.


## Current productization track

MIOMOS is no longer just a shell concept. The current ROI track is about turning it into a deliverable product surface.

The current focus areas are:

- draggable shell dialogs with desktop-correct title-bar behavior
- desktop context menus with **New Folder**
- draggable desktop icons with automatic layout persistence
- a curated product desktop where only **UI Samples**, **Settings**, and **Terminal** remain on the root desktop
- future user, role, and permission product surfaces that behave like application administration rather than generic OS administration

## Desktop curation rule

Keep the root desktop restrained.

The root desktop should prefer:
- UI Samples
- Settings
- Terminal

UI-only or showcase-oriented surfaces should live inside the **UI Samples** folder rather than being sprayed across the desktop.

## Immediate next ROIs after this one

- ROI35: desktop icon rename/change-icon, stronger folder behavior, restore custom desktop state on reload
- ROI36: product desktop curation, folder views, and UI Samples content quality
- ROI37: users, roles, permissions, and admin product surfaces
- ROI38: permission-aware launch visibility and action enforcement
- ROI39: packaging, install bootstrap, and product docs


## ROI34 — Product shell folders and curated desktop

The current MIOMOS shell now treats the root desktop as a product surface instead of a catch-all launcher.

Important rules from ROI34:

- shell dialogs should behave like draggable desktop dialogs
- the desktop context menu should include **New Folder**
- desktop icon moves should autosave
- the root desktop should stay curated around **UI Samples**, **Settings**, and **Terminal**
- UI/demo-only surfaces should prefer the **UI Samples** folder instead of living on the root desktop

Persistence now includes:

- dialog positions
- custom folders
- desktop icon positions
- existing window layout state

When extending MIOMOS from this point, keep product restraint as a design rule. A cleaner desktop is more important than exposing every capability at once.


## ROI35 update — websocket-first live shell

The current live-shell direction is now **websocket-first**.

Important rule for future development:

- keep initial page bootstrap SSR over HTTP
- keep live shell traffic on the primary websocket session
- do not reintroduce `fetch()` for routine shell actions unless a very narrow exception is clearly justified

That means the following should prefer the websocket bus:

- layout saves
- UI-state saves
- settings saves
- theme changes
- view refreshes
- terminal open/input/poll/resize/close
- signout eventing

### Command bus contract

The browser shell should treat the websocket as a request/response bus with request IDs.

Current event names:

- `command.exec`
- `command.result`
- `command.error`
- `auth.signout`
- `auth.signout.ack`

### v1 stability posture

The next productization work should keep increasing tests around:

- shell transport correctness
- taskbar/start/context-menu correctness
- persisted desktop/layout behavior
- dialogs and drag behavior
- desktop icon behavior
- authorization-aware shell visibility and actions
- user and permission admin surfaces

The goal is no longer “can MIOMOS do this visually?”

The goal is:

**does MIOMOS behave like a stable, production-minded product shell with a clear MUMPS-owned contract?**


## Websocket helper and terminal contract

Keep these rules aligned with the tests:

- direct websocket command tests in `^MIOMOST` should create a real MIOMOS session first in prod/local-auth mode
- use an explicit session-aware helper for direct websocket command tests rather than depending on ambient auth state
- the live websocket terminal path should use `MIOMOSTPIPE`
- websocket terminal assertions should use valid MUMPS input when the pipe backend runs `yottadb -direct`


## ROI36 xterm renderer reintegration note

The source-of-truth terminal contract is now:

- server-side terminal ownership stays in MIOMOS MUMPS routines, primarily the websocket/command path and `MIOMOSTPIPE` for the live YottaDB session
- browser-side rendering should be done by xterm.js, not by a fake transcript textarea or CSS-only emulator
- xterm.js should own focus, key capture, local echo, and cursor rendering
- MIOMOS should only send whole command lines to the backend command boundary unless a future ROI introduces true character-stream transport end-to-end
- avoid repeated forced focus on every poll/result cycle, as that can make the cursor appear to blink incorrectly or make typing unreliable
- prefer a thin renderer integration that preserves the passing MIOMOST suite and the current YottaDB-over-pipe backend behavior


## Terminal contract updates

- MIOMOS terminal runtime is `yottadb -direct` over the PIPE transport. Tests must use real MUMPS input, not shell commands.
- The terminal settings catalog includes `terminal.palette` with `theme`, `midnight-blue`, `black-on-white`, and `white-on-black`.
- The Clear button is a client-side xterm viewport clear, not a command sent into YottaDB.
- xterm remains a renderer only; transport, session ownership, and terminal process ownership stay in MUMPS.


## Animation settings note
- The `animations` setting supports only `off`, `standard`, and `full`.
- Legacy `reduced` animation preferences must be normalized to `standard`.
- Do not reintroduce `data-animations="reduced"` CSS branches; the separate `motionProfile` setting remains independent.


## ROI43 websocket observability
- Maintain a server-authored websocket registry keyed by session and connection.
- Keep runtime behavior unchanged; use the registry for diagnostics, admin counts, and future controls.
- Preserve additive tests/docs for websocket metrics and export helpers.


## ROI44 — Security and session hardening

- Enforce principal/session binding in `ENSURE^MIOMOSST`.
- Add `LOCK^MIOMOSST`, `UNLOCK^MIOMOSST`, `FORCESIGNOUT^MIOMOSST`, and `CLEARFORCE^MIOMOSST`.
- Maintain session registry snapshots under `^MIO("MIOMOS","SESSION","REG",...)`.
- Emit `session.signout` for direct websocket session-guard failures.
- Audit forbidden websocket actions and privileged terminal actions.


## ROI45 — Release gates and runbooks

- Keep release/readiness metadata additive and server-authored in boot JSON.
- Tie the authoritative release test gate to `^MIOMOST`.
- Preserve explicit runbook metadata for deploy, restart, and route rebuild operations.
- Keep websocket smoke and browser smoke checklists visible in SSR tokens and boot metadata.
- Do not use the release-gates ROI to change working runtime behavior.


## Current auth and role workflow posture

As of ROI46:

- MIOMOS supports startup-seeded local identities for `admin`, `user`, and `guest`
- seeded passwords use the existing salted `MIOSHA256` path through `MIOMOSAUTH`
- guest quick login is now an explicit config-backed workflow rather than an implicit no-auth shortcut
- boot JSON exposes only safe auth bootstrap metadata such as usernames, display names, roles, and the guest-login toggle
- the `guest` role exists as a limited permission role and should stay more constrained than `operator` or `developer`

## Role and workflow roadmap

Completed:

- **ROI46** — startup identity bootstrap and guest login toggle

TODO next:

- **ROI47** — guest role and role-aware login workflow
  - hide or disable desktop apps and shell actions that guest should not use
  - surface clearer role badges and session copy in the shell
  - keep terminal/admin/security actions unavailable to guest at the UI layer, not just by server permission checks

- **ROI48** — admin role center
  - user directory improvements
  - role assignment editor
  - effective permission preview
  - guest-login toggle in admin UI
  - bootstrap-auth status panel

- **ROI49** — admin reports and workflow analytics
  - active users
  - guest usage
  - failed logins / lockouts
  - reset/invite activity
  - permission and session summaries

- **ROI50** — seeded password rotation and policy hardening
  - first-login password change for seeded accounts
  - password policy settings
  - seeded credential warnings
  - stricter production defaults for guest quick login


## ROI55 — Dedicated terminal window sessions

Completed after ROI54:

- launching the Terminal app now opens a new MIOMOS window instead of restoring the shared singleton terminal surface
- new launches request a fresh backend PIPE session using `terminal.open` with `forceNew=1`
- each terminal window now owns its own xterm.js renderer, transcript, input history, terminalId, and lifecycle state in the Vue shell
- closing a terminal window closes that specific backend terminal session instead of leaving a shared session behind
- the websocket command path preserves explicit reattach/poll/input/resize behavior by terminalId, so multiple terminal windows can coexist under the single MIOMOS websocket

Guardrails:

- default `terminal.open` without `forceNew` should continue to attach to an existing session when a specific terminal window wants to reuse its current terminalId
- a fresh launch from the shell must not reuse `^MIO("MIOMOS","PIPE","BYSESSION",sessionId)`; it must request a new session explicitly
- terminal taskbar entries should reflect real independent windows rather than one global terminal model

## ROI56 — Real chat workflow with moderation and unread shell badges

Completed after ROI55:

- collaboration chat now supports real direct-message room keys between users rather than only shared room snapshots
- chat metadata is MUMPS-authored and includes room lists, direct-contact lists, unread counts, moderation capability, and active-room state
- unread counts now reflect per-user last-read state stored in MUMPS globals and surface back into the collaboration window and taskbar badges
- support/admin moderators can remove chat messages and the room snapshot preserves moderated history with deleted markers instead of silently dropping rows
- the collaboration surface now renders a real room/direct-message sidebar, active-user roster, moderated message controls, and unread-aware shell badges

Guardrails:

- direct rooms must stay permission-aware and only expose messages to participants or moderators with admin visibility
- guest users may use shared chat if enabled by role, but should not receive direct-message capability
- unread counts must be durable per principal and should clear only when the room is fetched/read for that principal
- taskbar and quick-launch badges must reflect server-authored unread totals rather than browser-only counters
