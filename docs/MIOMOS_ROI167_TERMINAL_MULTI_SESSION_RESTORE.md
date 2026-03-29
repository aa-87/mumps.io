# MIOMOS ROI167 hotfix — Restore multi-session terminal behavior

## Goal

Restore the ability to run more than one YottaDB terminal session at the same time on the current passing VFS baseline.

## What changed

- `MIOMOSTERM` now exposes a session list for the current MIOMOS shell session.
- `MIOMOSVM` now reads terminal sessions from `MIOMOSTERM` instead of the permissions routine.
- `terminal.open` supports `forceNew=1`, which maps to the existing `__new__` PIPE session path.
- The desktop terminal surface now renders terminal session tabs and a **New Session** action.
- Re-launching Terminal while a live session is already open creates a fresh session instead of collapsing back to the same one.
- Active terminal tab identity is now persisted in the UI-state contract.
