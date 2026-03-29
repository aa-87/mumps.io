# MIOMOS ROI 163 — Shell State Machine and Taskbar Correctness

## Goal
Formalize MIOMOS shell behavior so focus, minimize, restore, close, context menus, dialogs, and taskbar slots behave like a deterministic desktop shell instead of a mostly client-local window list.

## Scope implemented
- Added a **server-authored shell state machine contract** to boot JSON.
- Persisted additional shell UI state server-side:
  - `shellSurface`
  - `dialogKind`
  - `contextMenuKind`
  - `surfaceTargetId`
  - `activeTerminalTabId`
- Added server-side **layout normalization** for saved window arrays so task order is deterministic even if the browser sends duplicate or missing `taskOrder` values.
- Hardened desktop shell focus behavior:
  - minimizing the active window focuses the next visible window
  - closing the active window focuses the next visible window
  - restoring a window both restores and focuses it
- Added the missing client method `restoreWindow(...)` used by window context actions.
- Preserved taskbar order separately from z-order and made that policy explicit in SSR tokens and boot metadata.
- Hardened folder deletion so deleting the active folder window falls through to the next visible window instead of leaving stale active state behind.

## Server contract additions
Boot JSON now includes:
- `desktop.stateMachine.model = server-authored-shell-state`
- `desktop.stateMachine.version = roi163-shell-state-machine`
- `desktop.stateMachine.taskbarPolicy = stable-order-separate-from-z`
- `desktop.stateMachine.taskbarClickPolicy = xp-toggle`
- `desktop.stateMachine.focusPolicy = focus-next-visible-on-minimize-close`
- `desktop.stateMachine.restorePolicy = restore-and-focus`
- `desktop.stateMachine.surfacePolicy = single-open-surface`
- `desktop.stateMachine.dialogPolicy = exclusive-shell-dialogs`
- `desktop.stateMachine.layoutNormalization = server-normalized-task-order`
- `desktop.stateMachine.uiStatePersistence = local-plus-server`

## SSR contract additions
Desktop HTML now exposes explicit shell correctness tokens:
- `data-shell-state-machine="server-authored-shell-state"`
- `data-shell-focus-policy="focus-next-visible-on-minimize-close"`
- `data-shell-layout-normalization="server-normalized-task-order"`

## Tests updated
`^MIOMOST` coverage was extended to assert:
- SSR tokens and explanatory copy for the new state machine contract
- boot JSON state-machine metadata
- UI state persistence and normalization for dialog/context shell surfaces
- shell view model exposure for the new state-machine fields
- layout normalization behavior when duplicate `taskOrder` values are saved

## Why this ROI matters
This ROI creates a deterministic shell base for the next production ROIs:
- desktop objects and folders
- launcher/search behavior
- terminal multi-window workflows
- file explorer surfaces
- stronger reconnect/replay behavior
- admin and developer tools that depend on stable shell state

## Recommended next ROI
**ROI 164 — Desktop objects, launch surfaces, and folder workflows**
- richer desktop icon metadata
- rename/delete/open flows
- better directory windows
- tighter taskbar overflow behavior for many windows
- cleaner shell action routing for folders and developer tools
