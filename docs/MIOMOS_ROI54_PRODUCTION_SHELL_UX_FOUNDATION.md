# MIOMOS ROI54 — Production shell UX foundation

This ROI shifts the desktop shell from roadmap-style placeholder UX toward production-facing behavior.

## Goals

- persist shell preferences per user
- make the taskbar/account area feel real rather than decorative
- expose room-aware chat UX instead of a single hard-coded textarea
- allow multiple live terminal sessions from the same shell
- remove the prominent placeholder-only "Planned surfaces" block from the workspace

## Delivered behavior

### 1) Persistent shell settings per user

`MIOMOSSET` now persists a `shell` preference block under the existing per-user preference global.

Added shell preferences:

- `startMenuSection`
- `showClockSeconds`
- `showTrayLabels`
- `chatRoom`
- `chatLimit`
- `terminalLaunchMode`
- `quickLaunch`

These values are:

- loaded into `STATE("shell",...)`
- exposed through the settings view model/catalog
- saved through the existing `settings.save` command path
- surfaced in boot JSON under `desktop.shell`

### 2) Real taskbar account menu

The taskbar now exposes a user/account button which opens a real action menu.

Actions:

- open settings
- open chat
- open terminal
- switch user
- sign out
- about MIOMOS

This is intentionally implemented using the existing shell context-menu interaction model to preserve a consistent shell contract.

### 3) Multi-session terminal tabs

The terminal backend already supported multiple terminal identities. ROI54 adds the shell UX for it.

Delivered pieces:

- session listing in `MIOMOSTERM`
- terminal session rows in the boot/view model
- terminal tabs in the desktop UI
- `New session` behavior in the terminal toolbar
- active terminal tab persistence through session UI state

### 4) Room-aware chat UX

The collaboration surface now uses room metadata and roster information from MUMPS.

Delivered pieces:

- room catalog from `MIOMOSCHAT`
- access-aware room gating
- session-registry roster list
- room selector on the chat surface
- websocket fetch/send gating by room permission

### 5) Placeholder reduction

The large workspace placeholder section for future/planned surfaces is removed from the shell render.

The desktop remains curated around working surfaces rather than roadmap placeholders.

## Files changed

- `routines/MIOMOSPERM.m`
- `routines/MIOMOSSET.m`
- `routines/MIOMOSST.m`
- `routines/MIOMOSCMD.m`
- `routines/MIOMOSCHAT.m`
- `routines/MIOMOSTERM.m`
- `routines/MIOMOSVM.m`
- `routines/MIOMOSWS.m`
- `routines/MIOMOST.m`
- `templates/pages/miomos_desktop.html`
- `miomos_llm.md`

## Notes

This ROI intentionally does not try to solve full moderated chat workflow, notification-center UX, or pinned taskbar state. Those are better handled as follow-on ROIs once the shell preferences, account surface, and multi-session terminal foundation are stable.
