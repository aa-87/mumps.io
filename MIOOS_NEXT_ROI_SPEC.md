# MIOOS Next ROI Production Spec

This document is the formal next-phase ROI plan for MIOOS and is intended to be merged into `mioos_llm.md` and reflected in `docs/mioos/*` as work lands.

It supersedes the shorter near-term roadmap notes where they conflict, while preserving the standing project constraints, MIO-native architecture, and SSR-first posture already established in the repository.

---

## 1. Purpose

The next phase of MIOOS work is no longer about isolated feature additions. It is about turning the current shell, websocket transport, terminal, VFS, and desktop UI into a **production-grade operating surface** that is:

- fast enough to feel instantaneous
- stable under concurrent activity
- visually polished in both light and dark modes
- accessible and legible by default
- extensible through first-class modules
- developer-friendly through built-in diagnostics and debugging tools
- documented and testable end-to-end

This phase must treat performance, correctness, and polish as release requirements rather than future cleanup.

---

## 2. Non-negotiable implementation rules

These apply to every ROI below.

- Stay in the `MIOOS*` namespace.
- Keep MUMPS-first and MIO-native architecture.
- Keep SSR as the authoritative baseline; Vue enhances shell behavior rather than replacing server ownership.
- Use Vue 3 Options API UMD only.
- No TypeScript.
- No Node runtime assumptions.
- No `ZSYSTEM`.
- No `GOTO` in production code.
- Keep MAXSTRING-safe payload handling.
- Use globals / `^TMP($J,...)` for large or staged payloads.
- Structured failures should continue to surface `ERR("routine")` and `ERR("error")`.
- Tests must stay quiet on success.
- Docs must be updated as each ROI lands.
- Accessibility, performance, and i18n must remain release gates.
- Preserve English default plus Arabic (RTL) and Spanish support.
- Keep HIPAA-aware engineering posture.

---

## 3. Current baseline assumptions

This plan assumes the repository baseline already includes:

- SSR desktop shell
- Vue 3 Options API UMD browser files under `public/mioos/app/`
- websocket-backed shell behavior
- YottaDB PIPE-backed terminal posture
- VFS foundation and explorer upload support
- browser-side chunked uploads with some parallelization
- existing MIOOS boot contract and tests in `^MIOOST`

This plan does **not** assume the current behavior is production-ready. It assumes it is the working baseline to harden and extend.

---

## 4. Official next ROI sequence

The next production track is:

1. **ROI-A — WebSocket Transport v2 and perceived performance**
2. **ROI-B — Window Manager v2 and reusable window chrome**
3. **ROI-C — 7.css-based theme system, light/dark parity, and system polish**
4. **ROI-D — Module system and desktop app extensibility**
5. **ROI-DX — Built-in Debug / Developer Tools app**
6. **ROI-E — MVP lockdown, end-to-end tests, release docs, and hardening**

This order matters. Transport and shell behavior must be made reliable before heavy polish and extensibility work are layered on top.

---

# ROI-A — WebSocket Transport v2 and Perceived Performance

## Goal

Make MIOOS feel immediate and responsive under normal desktop use, file uploads, terminal interaction, and future module activity.

The user should not perceive the shell as sluggish while uploads or terminal traffic are active.

## Core design decision

MIOOS should support **multiple concurrent websockets per session** instead of enforcing a hard single-socket model.

However, this is **not** an unlimited-socket model.

It must be a **bounded, configurable session socket pool** with strict ownership and routing rules.

## Required configuration posture

Add or formalize websocket transport settings under MIOOS config, including at minimum:

- `^MIO("CONF","mioos","ws","maxSocketsPerSession")`
- `^MIO("CONF","mioos","ws","heartbeatSeconds")`
- `^MIO("CONF","mioos","ws","resumeWindowSeconds")`
- `^MIO("CONF","mioos","ws","maxInflightPerChannel")`
- `^MIO("CONF","mioos","upload","chunkBytes")`
- `^MIO("CONF","mioos","upload","maxInflightChunks")`
- `^MIO("CONF","mioos","upload","batchFlushThreshold")`

The server remains the source of truth for these limits and advertises effective limits in the boot contract.

## Required transport model

Each websocket belongs to a session and has one or more logical purposes. At minimum, MIOOS should support logical channels such as:

- `ui`
- `fs`
- `terminal`
- `events`
- future module-specific channels where justified

Every message should carry enough routing context to preserve ordering and ownership, for example through fields such as:

- `channel`
- `event`
- `seq`
- `requestId`
- `sessionId` or equivalent server-bound association
- `socketRole` or inferred socket purpose

## Acceptance criteria

### A1. Session socket pool
- A session may hold multiple concurrent sockets up to a configured maximum.
- Sockets are tracked under a session-aware registry.
- Exceeding the configured limit must fail cleanly and predictably.
- Duplicate accidental sockets must not corrupt state.

### A2. Channel affinity and scheduling
- UI traffic must not be blocked behind heavy file upload traffic.
- Terminal interactivity must remain responsive during uploads.
- Client-side scheduling must prefer the least-busy eligible socket while preserving logical ordering per stream.

### A3. Backpressure and flow control
- The server must be able to constrain per-channel inflight work.
- File uploads must obey bounded in-flight chunk windows.
- Flow-control state must be recoverable after reconnect.

### A4. Upload pipeline redesign
- Chunk uploads should use bounded parallelism.
- Upload state must survive partial interruption where practical.
- Writes should be staged safely in globals or `^TMP` before final assembly.
- Finalize must verify chunk completeness before commit.

### A5. Event batching
- Chatty command/result patterns should be reduced where safe through batch envelopes or grouped delivery.
- The client must still surface deterministic command resolution.

### A6. Resume and reconnect
- Resume should be session-aware and socket-aware.
- Reconnecting one socket should not necessarily tear down the session.
- Interrupted uploads should be recoverable where contractually possible.

### A7. Observability
- Transport state must expose enough metadata for later debug tooling.
- Per-session socket counts, last heartbeat, inflight queues, and recent failures should be inspectable.

## Primary routine targets

- `MIOOSWS`
- `MIOOSST`
- `MIOOSAPI` where HTTP fallback or control routes are needed
- `MIOOSFS` for upload/finalize staging
- `MIOOST` for regression coverage

## Browser targets

- `public/mioos/app/*socket*.js`
- explorer upload module(s)
- terminal transport module(s)
- any shared command bus file(s)

## Tests required

Add or extend tests for:

- max sockets per session enforcement
- session with 1, 2, and configured-N sockets
- UI responsiveness during upload traffic
- terminal responsiveness during upload traffic
- inflight chunk window enforcement
- reconnect/resume of one socket while others remain active
- batched event delivery correctness
- upload finalize correctness after out-of-order chunk arrival

## Documentation required on landing

Update:

- `mioos_llm.md`
- `docs/mioos/README.md`
- `docs/mioos/Internal_Doc.md`
- `docs/mioos/User_Guide.md` where user-visible behavior changes

---

# ROI-B — Window Manager v2 and Reusable Window Chrome

## Goal

Turn the current windowing behavior into a polished, reusable, OS-grade window foundation that every app and module can share.

This is the core UX layer for Explorer, Terminal, Debug, and future modules.

## Core design decision

There must be one authoritative window model and one authoritative window behavior engine.

Terminal windows, Explorer windows, image viewers, dialogs, and future debugger windows must all derive from the same behavior contract.

## Required window contract

Each window must have server/client-agreed state including at minimum:

- `id`
- `kind` or `moduleId`
- `title`
- `icon`
- `x`, `y`
- `width`, `height`
- `zIndex`
- `state` (`normal`, `minimized`, `maximized`, `snapped`)
- snap metadata where applicable
- `resizable`
- `draggable`
- `focused`
- optional persisted workspace metadata

## Acceptance criteria

### B1. Smooth drag behavior
- Dragging should feel direct and stable.
- Use lightweight transforms and animation scheduling where appropriate.
- Avoid layout thrash during drag.

### B2. Snap behavior
- Support left and right half snapping.
- Support top-edge maximize behavior.
- Support corner snapping / quadrant posture if implemented in the shell.
- Show a clear snap preview affordance.

### B3. Resize behavior
- Windows must resize smoothly using explicit handles.
- Minimum sizes must be enforced.
- Resize behavior must remain stable under theme changes.

### B4. Standard desktop controls
- Close
- minimize
- maximize
- restore
- focus / bring-to-front
- double-click title maximize/restore behavior

### B5. File drag/drop integration
- Windows that accept file drop must do so through a common contract.
- File drop must integrate safely with VFS upload workflow.
- Native browser drop side-effects must remain guarded where required.

### B6. Reusable chrome
- Terminal must use the same base windowing substrate.
- Explorer must use the same base windowing substrate.
- Future modules must not need bespoke window state engines.

### B7. Workspace persistence
- Window positions and states should be persistable where appropriate.
- Restored windows must reopen into valid bounds.

## Primary routine targets

- `MIOOSST`
- `MIOOSVM`
- `MIOOSUI`
- `MIOOST`

## Browser targets

- shared shell/window manager files under `public/mioos/app/`
- explorer window integration files
- terminal window integration files
- shared CSS in `public/mioos/mioos.css`

## Tests required

- create/focus/close window lifecycle
- z-order correctness
- minimize/maximize/restore transitions
- snap-to-left / snap-to-right correctness
- resize min bounds
- persisted window state reload
- file-drop routing to accepted windows

## Documentation required on landing

Update internal architecture and user guide docs to describe desktop window behavior, restore rules, and any keyboard or drag/drop behavior exposed to users.

---

# ROI-C — 7.css Theme System, Light/Dark Parity, and System Polish

## Goal

Create a visually polished, professional, legible MIOOS theme architecture using **7.css** as a scoped visual foundation while preserving MIOOS ownership of layout, behavior, accessibility, and theme tokens.

## Core design decision

Use the **scoped** 7.css distribution as a presentation layer inside the MIOOS shell, not as the full application architecture.

MIOOS must continue to own:

- layout contracts
- window state behavior
- animation behavior
- accessibility overrides
- color tokens
- theme persistence
- component state integration

## Theme requirement

Every supported MIOOS theme family must support **both light and dark variants**.

Legibility and contrast are release gates.

## Required theme matrix

At minimum, formalize and support:

- Win7 Classic Light
- Win7 Classic Dark
- Win7 Modern Light
- Win7 Modern Dark
- High Contrast Light
- High Contrast Dark

Additional variants may be added later, but these establish the system.

## Acceptance criteria

### C1. Scoped 7.css integration
- 7.css must be imported in a way that does not globally damage unrelated MIO surfaces.
- The shell should mount inside a scoped wrapper or equivalent controlled boundary.

### C2. Tokenized MIOOS theming
- MIOOS must define its own stable design tokens for foregrounds, backgrounds, chrome, borders, accents, focus rings, inactive surfaces, and terminal defaults.
- 7.css visual primitives should consume or be reconciled with these tokens through overrides.

### C3. Light and dark parity
- Desktop shell
- taskbar/menu chrome
- context menus
- forms
- explorer panes
- terminal chrome
- dialogs
- notifications
- debug app
- title bars and inactive states

All of the above must be validated in both light and dark variants.

### C4. Legibility hardening
No theme may ship with common low-contrast failures such as:

- grey text on grey background
- unreadable disabled state text
- unreadable form controls
- unreadable inactive title bars
- invisible focus outlines
- poor terminal foreground/background pairing
- unreadable selection highlights

### C5. Motion and polish
- Support motion preferences such as full/reduced/none if already present or justified.
- Keep animations subtle and performant.
- Window motion and shell transitions should feel professional, not ornamental.

### C6. Theme persistence
- Theme choice must persist by session or user profile where appropriate.
- Boot contract should expose theme capabilities and active selection.

### C7. RTL and locale safety
- Theme and layout changes must remain safe for Arabic RTL rendering.
- Visual chrome must not assume LTR-only layout.

## Primary routine targets

- `MIOOSST`
- `MIOOSI18N` where locale-direction interactions matter
- `MIOOSUI`
- `MIOOSVM`
- `MIOOST`

## Browser targets

- shell CSS in `public/mioos/mioos.css`
- theme support files in `public/mioos/app/`
- templates under `templates/` that render shell chrome and windows

## Tests required

- active theme emitted in boot data
- light/dark theme persistence
- RTL-safe shell wrapper behavior
- required theme token presence where testable
- rendered shell contains expected theme hooks/classes
- no regressions in terminal and explorer chrome across themes

## Documentation required on landing

Document:

- official theme matrix
- theme token strategy
- 7.css scope strategy
- accessibility/contrast expectations
- user-visible theme switching behavior

---

# ROI-D — Module System and Desktop App Extensibility

## Goal

Make MIOOS extensible through first-class modules that can be launched as desktop apps, icons, and windows without bespoke shell wiring each time.

## Core design decision

Explorer, Terminal, Debug, and future tools should behave like registered modules rather than one-off hardcoded apps.

## Required module contract

A module manifest or equivalent registration contract should include at minimum:

- `moduleId`
- display name
- icon metadata
- route or launch entry
- permissions or minimum role
- preferred window defaults
- channel/transport preferences
- theme compatibility metadata where needed
- diagnostics/debug capability metadata where needed

## Acceptance criteria

### D1. Module registry
- MIOOS can enumerate registered modules.
- Module metadata can be surfaced to desktop/menu/icon layers.

### D2. Desktop integration
- Modules can appear as desktop icons and/or launchable entries.
- Launching a module opens a proper window via the shared window manager.

### D3. Permission awareness
- Restricted modules must honor role-based visibility and launch rules.
- Admin-only modules must not surface as general-user apps unless explicitly allowed.

### D4. Lazy activation
- Modules should load only the code/data required when launched where practical.
- Browser payload should not become monolithic because of unused future modules.

### D5. Stable launch contract
- Each module should open through a stable shell contract rather than custom ad hoc app wiring.

## Primary routine targets

- `MIOOS`
- `MIOOSAPI`
- `MIOOSST`
- `MIOOSVM`
- `MIOOSUI`
- `MIOOST`

## Browser targets

- desktop icon launcher files
- menu/app registry files
- shared app/window launch helpers

## Tests required

- module registration discovery
- module launch success
- role-based module visibility
- module launch into shared window manager
- boot contract advertises module inventory where intended

## Documentation required on landing

Document module registration, launch semantics, permissions, and future extension guidance.

---

# ROI-DX — Built-in Debug / Developer Tools App

## Goal

Make MIOOS significantly more developer-friendly and supportable by shipping a built-in Debug app/window that provides safe diagnostics for users and deeper operational visibility for admins and developers.

## Core design decision

The Debug app is a first-class MIOOS module, not a hidden dev-only afterthought.

It must be role-aware so that average users get safe diagnostic information while admins and developers get deeper controls.

## Required audiences

### Standard user
May access safe diagnostics such as:

- application version
- connection health
- active theme and locale
- basic session summary
- safe troubleshooting information

### Admin / developer
May additionally access:

- websocket inspector
- window manager inspector
- module registry inspector
- upload/file inspector
- event/log history where safe
- advanced diagnostics and test controls

## Required Debug app surfaces

### DX1. System overview
- version/build information
- environment profile
- active user and role
- session summary
- active theme and locale
- active module/window count

### DX2. Websocket inspector
- active sockets for current session
- socket roles/channels
- heartbeat / reconnect state
- inflight queues and recent failures
- ability to inspect recent event traffic safely

### DX3. Window manager inspector
- open windows
- focused window
- z-order stack
- minimized/maximized/snapped state
- restore/reset layout actions where authorized

### DX4. File/upload inspector
- active uploads
- chunk progress
- finalize status
- file integrity metadata where available
- retry/cancel hooks where authorized

### DX5. Module inspector
- registered modules
- launch metadata
- permission visibility
- diagnostics exposure

### DX6. Theme and UI diagnostics
- active theme family and variant
- motion settings
- contrast mode
- resolved theme token snapshot where feasible

### DX7. Logs and support snapshot
- recent warnings/failures where safe
- exportable support bundle or diagnostic snapshot if implemented

## Acceptance criteria

- Debug app launches through the module system.
- Debug app uses the shared window manager.
- Standard users only see safe diagnostics.
- Admin/developer users can access advanced inspection and control surfaces.
- Debug data remains bounded and safe for browser rendering.

## Primary routine targets

- `MIOOSAPI`
- `MIOOSWS`
- `MIOOSST`
- `MIOOSVM`
- `MIOOSUI`
- `MIOOST`

## Browser targets

- dedicated debug app module files under `public/mioos/app/`
- shared inspector view components if split

## Tests required

- debug module registration
- role-based visibility
- safe user diagnostic surface present
- admin/developer advanced sections present
- websocket/window/module summary contract correctness

## Documentation required on landing

Document:

- how to open and use the Debug app
- role-specific behavior
- supported diagnostics and limitations
- support workflow guidance

---

# ROI-E — MVP Lockdown, End-to-End Tests, and Release Hardening

## Goal

Finish the minimum viable production shell with measurable quality gates, usable documentation, and end-to-end regression coverage.

## Core design decision

This phase is not feature exploration. It is release hardening.

Any feature work that weakens testability, docs, transport correctness, accessibility, or shell stability should be deferred.

## Required acceptance criteria

### E1. End-to-end user flows
Cover at minimum:

- login / guest entry / desktop boot
- open explorer window
- upload file and observe progress
- open terminal and interact successfully
- open multiple windows and exercise focus/minimize/maximize/restore/snap
- switch themes between light and dark
- reload and verify persisted shell state where supported
- launch Debug app and verify role-specific visibility

### E2. Transport and performance checks
- websocket pool limit enforcement
- shell responsiveness during upload traffic
- terminal responsiveness during upload traffic
- reconnect behavior for one socket without losing the whole session where supported

### E3. Accessibility checks
- keyboard reachability of shell chrome where practical
- visible focus states
- contrast-safe text and controls
- reduced-motion or motion-safe behavior if implemented
- RTL-safe rendering validation

### E4. Security and policy checks
- role-aware module visibility
- path-safety in filesystem operations
- safe diagnostics exposure
- reasonable rate limiting / bounded resource behavior where contractually supported

### E5. Documentation completeness
At release-ready minimum, keep these current:

- `mioos_llm.md`
- `docs/mioos/README.md`
- `docs/mioos/User_Guide.md`
- `docs/mioos/Internal_Doc.md`
- `docs/mioos/HIPAA.md`

Add deployment/operator notes if needed for new config and diagnostics behavior.

### E6. Regression posture
- All MIOOS tests pass.
- New tests remain quiet on success.
- No known shell-breaking JavaScript errors remain.
- No known transport regressions remain in normal desktop flows.

---

## 5. Cross-ROI design rules

These are mandatory across ROI-A through ROI-E.

### 5.1 Performance rule
The shell must be designed for **perceived immediacy**.

This means:

- UI commands should not wait behind upload-heavy traffic.
- animations must not block interaction
- client code should remain thin and modular
- the boot contract should remain deliberate and not balloon unnecessarily

### 5.2 Windowing rule
No future app should bypass the shared window manager.

### 5.3 Theme rule
No new app or shell component may ship without validated light and dark behavior.

### 5.4 Developer-experience rule
New subsystems should expose enough structured state that the Debug app can inspect them later.

### 5.5 Documentation rule
Every ROI must update both the handoff and the user/internal docs as appropriate.

### 5.6 Testing rule
Every new contract must have at least one regression test proving it exists and behaves as intended.

---

## 6. Suggested milestone landing order

To reduce risk, implement in this order:

### Milestone 1
- ROI-A foundational transport work
- socket pool limits
- channel affinity
- upload pipeline hardening

### Milestone 2
- ROI-B shared window engine rewrite/polish
- terminal/explorer alignment to common window contract

### Milestone 3
- ROI-C 7.css scoped integration
- light/dark/high-contrast family definition
- legibility hardening

### Milestone 4
- ROI-D module registry and launch system
- convert major built-ins into formal modules

### Milestone 5
- ROI-DX Debug app
- diagnostics surfaces for sockets, windows, uploads, modules, theme

### Milestone 6
- ROI-E end-to-end coverage
- docs finalization
- release gates and support workflows

---

## 7. Immediate implementation recommendation

If starting now, the next coding ROI should be **ROI-A**.

Reason:

- it directly addresses the reported sluggishness
- it improves upload throughput and responsiveness
- it creates the transport foundation needed by the Debug app and future modules
- it reduces the risk of polishing unstable shell behavior later

The first concrete deliverable set should therefore be:

- session-aware websocket socket pool
- configurable socket limit
- per-channel routing and affinity
- bounded upload inflight pipeline
- reconnect/resume hardening
- regression coverage for multi-socket behavior

---

## 8. Definition of success for this roadmap

This roadmap succeeds when MIOOS feels like a real product shell rather than a promising prototype.

That means a user can:

- log in
- open multiple windows
- upload files without UI lag
- use terminal without transport glitches
- switch between attractive, readable light and dark themes
- trust window behavior to feel normal
- launch future apps/modules consistently
- use built-in diagnostics when something goes wrong

while the developer can:

- inspect transport and shell state
- extend the platform with modules
- trust the test suite to guard core contracts
- hand the project off cleanly through current docs

