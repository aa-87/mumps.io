# Next MIOMOS Production ROIs

## Baseline

- All current tests are passing at the ROI62 baseline.
- The immediate priority is theme correctness, shell polish, and visual consistency before expanding new desktop behaviors.
- MIOMOS should continue to feel like a Windows XP-class development workstation authored by MUMPS, not a browser toy shell.

## ROI 63 — XP theme system polish

- align all runtime fallbacks on `clinical-blue` as the default shell theme
- expand `MIOMOSTH` so themes carry shell-aware chrome tokens, not only generic surface colors
- harden XP-style taskbar, Start menu, context menu, dialog, and Explorer palette usage from a single server-authored theme contract
- add `xp-olive` and `xp-silver` as first-class daytime shell variants
- keep the browser a thin renderer over server-authored theme metadata

## ROI 64 — shell chrome parity and spacing

- refine title-bar height, control sizing, spacing, separators, and typography to match a polished Windows XP shell more closely
- harden inactive/active title bar contrast across all themes
- normalize taskbar button metrics and launcher spacing
- tighten Start menu search, tab, and footer spacing for consistent muscle memory

## ROI 65 — window frame and resize polish

- improve drag, resize, maximize, restore, and snap visuals so they feel native and intentional
- refine hit targets for resize edges and window controls
- preserve stable task order while allowing more fluid focus changes
- add test-backed shell tokens for window frame behavior where practical

## ROI 66 — Explorer visual parity

- continue XP Explorer parity work for folder panes, details view, icon view, and selection affordances
- unify Explorer toolbar, breadcrumb, side pane, and details row theming
- improve density and icon alignment for development workflows with many files and routines
- keep VFS and desktop object surfaces visually coherent

## ROI 67 — terminal palette and chrome alignment

- align terminal chrome, tab/window treatment, and focus states with the active shell theme
- improve default palette choices for light vs dark themes
- keep fit-container behavior stable while polishing the surrounding terminal frame
- expand browser-side terminal smoke coverage as needed

## ROI 68 — settings studio and theme workflow

- improve Settings so theme previews feel authoritative and production ready
- surface theme family, mode, contrast posture, and shell preview more clearly
- allow choosing XP blue / olive / silver variants without visual drift
- keep saved settings strictly server-backed and websocket-friendly

## ROI 69 — desktop icon, folder, and shortcut polish

- refine desktop icon grid spacing, label contrast, drag persistence, and selection feedback
- continue shortcut, rename, and recycle-bin parity
- improve system-place iconography and shell affordances for development use
- keep folder creation and rename flows predictable

## ROI 70 — realtime shell services

- continue websocket-first shell services for notifications, shell status, launcher refresh, and view invalidation
- avoid transport ownership drift back to mixed HTTP-first behavior
- keep one authoritative live socket per tab/session
- expand realtime observability for shell event flows

## ROI 71 — developer platform surfaces

- strengthen MIOMOS as a MUMPS development workstation
- improve routine/file launch flows, shell actions, and desktop shortcuts for developer workflows
- make terminal, Explorer, UI Library, and workspace surfaces feel like one coherent platform
- keep future debugger and IDE-adjacent work aligned with MIOMOS shell conventions

## ROI 72 — performance and rendering hardening

- reduce unnecessary Vue churn during window movement and shell-state updates
- avoid layout thrash from repeated theme and viewport application
- harden start menu, taskbar, and explorer rendering under many open windows
- document browser-side performance expectations for production shells

## ROI 73 — accessibility and contrast verification

- explicitly verify all light and dark themes for button, input, pane, titlebar, and menu contrast
- preserve XP-inspired styling without sacrificing legibility
- improve keyboard navigation cues and focus rings
- keep high-contrast themes first-class citizens

## ROI 74 — production profile hardening

- tighten prod defaults for auth, cookies, idle lock, session policy, and shell diagnostics
- ensure shell behavior degrades cleanly when permissions or services are restricted
- verify route/auth posture for desktop, bootstrap, websocket, settings, and admin surfaces
- extend runbooks for production deployments

## ROI 75 — release gate and ship checklist

- finalize MIOMOS production runbooks and smoke checklists
- expand test coverage for theme contracts, shell defaults, and websocket shell services
- add operator-facing notes for startup, rebuild, recovery, and troubleshooting
- declare the shell production-ready only once theme, behavior, transport, and admin posture all pass together
