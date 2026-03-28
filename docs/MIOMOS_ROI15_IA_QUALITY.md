# MIOMOS ROI 15 — Information Architecture and Production Shell Quality

## Goal
Advance MIOMOS from a polished shell to a more production-ready desktop by tightening information architecture, semantic iconography, menu structure, and directory modeling while keeping Vue as a thin render layer over MUMPS-authored metadata.

## What changed

### 1. Stronger server-authored entry metadata
`APPS^MIOMOSST` now emits a richer shell catalog:
- `group`
- `order`
- `desktopPinned`
- `status`
- `summary`
- semantic icon defaults for app/settings/directory/planned entries

This keeps the shell model MUMPS-first while making it easier for Vue to render a production-quality menu and desktop without inventing client-only behavior.

### 2. Semantic desktop and menu model
The shell now emphasizes:
- pinned entries on the desktop
- grouped menu sections in a consistent order
- clear separation between:
  - pinned work surfaces
  - directories
  - applications
  - system/admin surfaces
  - planned roadmap items

### 3. Directory model refinement
Workspace-facing directory cards now use server-authored summaries so the shell can communicate operational meaning, not just decorative folder tiles.

### 4. Production-style shell polish
The layout update improves:
- menu width and readability
- badge/state treatment
- semantic glyph styling
- hover and motion polish
- clearer visual distinction between app / settings / directory / planned items
- stronger production feel without adding client-owned state

## Architectural posture
This ROI intentionally keeps MUMPS authoritative for:
- shell entry metadata
- grouping and order
- launch intent
- readiness/planned state
- directory summaries

Vue remains responsible for:
- rendering
- local interaction mechanics
- command submission

## Files changed
- `routines/MIOMOSST.m`
- `templates/layouts/miomos_shell.html`
- `templates/pages/miomos_desktop.html`

## Expected benefits
- better top-level navigation clarity
- more OS-like semantics
- less prototype feel in the menu/desktop
- safer future expansion for folders, placeholders, and planned surfaces

## Next recommended ROIs
1. ROI 16 — Full production UI/UX quality pass
2. ROI 17 — Behavior hardening and runtime reliability pass
3. ROI 18 — Documentation and release-readiness completion
