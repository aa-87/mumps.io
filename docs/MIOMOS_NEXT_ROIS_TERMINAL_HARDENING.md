# MIOMOS Next ROIs — Terminal + Hardening

## ROI 11 — Terminal fidelity and legacy rendering
Goal: move from terminal foundation to terminal fidelity.

Planned work:
- fit strategy for dynamic viewport sizing
- refined resize propagation
- improved keyboard/input handling
- better Unicode-width handling
- alternate screen validation
- mouse reporting evaluation
- bracketed paste handling
- transcript quality improvements
- validation matrix for dense legacy terminal workflows

Expected tests:
- resize correctness
- transcript correctness
- unicode and box-drawing cases
- attach after reconnect
- keyboard input edge cases

## ROI 12 — Terminal backend and PTY abstraction
Goal: prepare MIOMOS for true backend terminal execution.

Planned work:
- PTY/session abstraction on the MUMPS side
- per-session process metadata and lifecycle
- attach/detach semantics
- transcript capture controls
- idle timeout and forced termination
- permission and policy controls for backend sessions

Expected tests:
- open/attach/detach/close lifecycle
- timeout enforcement
- permission denial
- transcript retention behavior
- oversize output and backpressure handling

## ROI 13 — Settings and OS personalization expansion
Goal: deepen the OS-like desktop feel.

Planned work:
- dedicated Settings categories
- richer icon theming
- wallpaper presets and user-managed variants
- title-bar and chrome polish
- accessibility pass
- keyboard shortcut surfaces

Expected tests:
- settings category rendering
- persistence of expanded settings
- fallback behavior for incomplete settings
- keyboard and focus traversal tokens

## ROI 14 — Security/compliance hardening
Goal: production-grade platform controls.

Planned work:
- stronger session invalidation
- audit export hardening
- admin security reports
- retention controls and review surfaces
- permission editing UI
- stronger traceability across access/error/audit data

Expected tests:
- permission boundary enforcement
- retention prune flows
- export route controls
- session invalidation behavior
- admin-only surface access

## ROI 15 — Production polish and sellable readiness
Goal: finish MIOMOS as a professional, production-ready desktop platform.

Planned work:
- visual polish pass across all windows
- operator documentation expansion
- internal maintenance documentation expansion
- deployment hardening checklist
- demo vs production profile review
- final regression pack across auth, chat, settings, terminal, admin, audit, and observability

Expected tests:
- end-to-end desktop boot
- one-socket runtime behavior
- settings persistence across reload
- terminal attach after reconnect
- auth/admin/observability regression coverage
