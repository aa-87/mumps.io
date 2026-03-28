# MIOMOS Roadmap — Mini Realtime Desktop Environment

This roadmap assumes the MIOMOS shell remains:

- MUMPS-first
- SSR-first
- MIO-native
- websocket-oriented for live desktop interaction
- thin Vue in the browser with MUMPS-owned state and contracts

## ROI36 — WebSocket helper session contract and terminal backend convergence

Stabilize helper-side websocket command execution and remove split terminal ownership between websocket events and websocket command actions.

Deliverables:

- explicit helper session contract for websocket command testing
- `MIOMOSTPIPE` as the live websocket terminal owner
- test coverage for missing-session failure and explicit-session success

## ROI37 — Realtime event fabric

Extend MIOMOS from request/response websocket commands into a true event fabric.

Deliverables:

- `view.invalidate`
- `notification.push`
- `job.progress`
- `terminal.stdout`
- sequence-aware event replay after reconnect
- event backlog / catch-up rules

## ROI38 — Shell state machine hardening

Formalize the shell as a tested server-authored state machine.

Deliverables:

- separate taskbar order from z-order
- stable minimize / restore / focus behavior
- predictable Start menu sections and search state
- single-open shell surfaces where intended
- stronger tests around taskbar overflow and shell dialogs

## ROI39 — Mini desktop MVP

Turn MIOMOS into a small but fully functional desktop product shell.

Deliverables:

- formal app catalog / manifests
- pinned apps and launcher behavior
- workspace app
- settings app
- terminal app
- UI library app
- files-lite surface
- recent items and open-app routing

## ROI40 — Desktop object model and persistence

Add server-authored desktop objects that behave like real shell resources.

Deliverables:

- desktop folders
- folder windows
- simple file metadata
- create / rename / move / delete actions
- desktop icon position persistence
- open-with routing and recent items integration

## ROI41 — Realtime operational surfaces

Use the websocket model to surface live operational data.

Deliverables:

- notifications
- presence cleanup
- queue and job updates
- audit tail
- live observability widgets
- command palette backed by live server data

## ROI42 — Performance and backpressure hardening

Keep the desktop responsive under sustained realtime activity.

Deliverables:

- output chunking
- event coalescing
- slow-client policy
- websocket outbox limits
- reconnect storm control
- render-budget and perf regression checks

## ROI43 — Security and session hardening

Raise the shell to a production-ready security posture.

Deliverables:

- websocket/session binding hardening
- idle lock and session timeout UX
- forced signout / session registry controls
- audit coverage for privileged shell actions
- permission-denied behavior for websocket commands and events

## ROI44 — Admin and observability tooling

Make the platform operable for real deployments.

Deliverables:

- websocket/session diagnostics
- terminal/session inspection tools
- kill-session / kill-terminal controls
- exportable command and event failure traces
- admin surfaces for realtime health and diagnostics

## ROI45 — Release gates and production documentation

Add the operational discipline needed to ship and maintain MIOMOS as a product shell.

Deliverables:

- release checklist tied to tests
- deployment and restart runbooks
- route rebuild and websocket smoke checklist
- browser behavior checklist
- docs kept current with the actual shell contract
