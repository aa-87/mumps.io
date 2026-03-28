# MIOMOS ROI 11 — MUMPS-first production contract

This ROI pushes MIOMOS toward production readiness by moving more desktop state and operational behavior back into MUMPS while keeping Vue as a thin render and interaction layer.

## Goals
- Keep MUMPS authoritative for desktop routes, view models, settings, permissions, and terminal policy.
- Make the browser mostly a renderer for server-authored JSON.
- Correct the shell/page contract so styles, scripts, and raw content are stable.
- Add focused smoke tests for the new contract.

## Delivered in this ROI
- New server-driven view model routine: `MIOMOSVM.m`
- New command execution routine: `MIOMOSCMD.m`
- New API routes:
  - `GET /api/miomos/view`
  - `POST /api/miomos/command`
- Updated boot payload with:
  - route contract for `view` and `command`
  - version `roi11-mumps-first-production`
  - embedded `view` section
- Corrected shell layout:
  - global styles live in the layout
  - Vue/OS.js/xterm are loaded once
  - page content is rendered raw with `{{{content}}}`
- Rebuilt desktop page:
  - boot JSON is embedded in the page
  - Vue renders from server-authored boot and view data
  - layout persistence is saved back to MUMPS via command route
  - quick theme and settings save are routed through MUMPS

## Command contract
Supported commands in this ROI:
- `desktop.ping`
- `layout.save`
- `theme.quick`
- `settings.save`
- `view.refresh`
- `terminal.open`

## Production direction
This ROI is a foundation step. It does not attempt to complete every remaining hardening item at once. It establishes a cleaner contract so later ROIs can harden terminal fidelity, admin workflows, audit review, and deployment posture without pushing logic back into the browser.
