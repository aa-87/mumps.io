# MIOMOS Terminal New Window Context Menu Fix

## Goal

Restore a Windows-XP-like terminal workflow by letting operators right-click an existing terminal window or taskbar button and open another terminal window without disturbing the current terminal surface.

## Scope

- add a terminal-specific window context menu action: `Open in New Window`
- allow more than one desktop window with `appKey="terminal"`
- keep the existing terminal command transport and session behavior unchanged
- keep the current multi-tab terminal behavior intact
- move the active xterm surface between terminal windows when focus changes so the terminal remains usable in the newly focused window

## Notes

This patch stays entirely in the shell/template layer. It does **not** change auth, websocket ownership, terminal permissions, or the MUMPS terminal command boundary.

## Files touched

- `templates/pages/miomos_desktop.html`
- `routines/MIOMOST.m`
- `miomos_llm.md`

## Follow-up

Continue with the XP shell/VFS roadmap after this fix, including:

- browser-to-VFS drag/drop upload
- VFS-to-browser download/save workflow
- XP Explorer copy/move/delete semantics
- per-user VFS permissions and quota surfaces
