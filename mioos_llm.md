# MIOOS LLM Development Handoff

## What MIOOS is

MIOOS is a production-minded desktop shell built inside the existing **MUMPS.IO / MIO** web stack.

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
