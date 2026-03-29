# MIOMOS ROI 163 — Shell Hardening Rebuild

## Goal
Rebuild the next shell-correctness ROI from a known-good auth baseline so taskbar and window behavior become more deterministic **without changing the existing websocket auth and sign-out workflow**.

## Scope implemented
- Added read-only boot metadata for a shell state-machine contract.
- Added window-manager view-model metadata for the same shell-correctness rules.
- Added SSR tokens that document the shell correctness contract in the rendered desktop HTML.
- Reordered desktop mount behavior so layout is loaded before active-window normalization.
- Added `restoreWindow(...)` cleanly for window context-menu actions.
- Added client-side focus fallback so minimizing or closing the active window focuses the next visible window.
- Hardened folder deletion so removing the active folder window clears stale active state and falls through cleanly.
- Hardened terminal window close so active-window fallback happens after terminal window closure too.
- Reduced unnecessary startup shell persistence by normalizing focus locally on mount rather than persisting a focus event immediately.

## Explicit non-goals
This rebuild does **not** change:
- `auth.signout` websocket ownership
- `session.signout` event handling
- sign-in or sign-out routes
- the `session.ui.save` command contract

## Boot metadata added
- `desktop.stateMachine.model = server-authored-shell-state`
- `desktop.stateMachine.version = roi163-shell-hardening-rebuild`
- `desktop.stateMachine.taskbarPolicy = stable-order-separate-from-z`
- `desktop.stateMachine.taskbarClickPolicy = xp-toggle`
- `desktop.stateMachine.focusPolicy = focus-next-visible-on-minimize-close`
- `desktop.stateMachine.restorePolicy = restore-and-focus`
- `desktop.stateMachine.surfacePolicy = single-open-surface`
- `desktop.stateMachine.dialogPolicy = exclusive-shell-dialogs`
- `desktop.stateMachine.layoutNormalization = client-normalized-task-order`
- `desktop.stateMachine.uiStatePersistence = existing-session-ui-save`

## Why this approach
The previous attempt expanded shell persistence and auth-adjacent behavior together. This rebuild separates those concerns:
- auth and websocket event flow stay stable
- shell correctness is improved where it is safest: boot metadata, client behavior, and tests

## Recommended next ROI
Desktop object workflows should be rebuilt the same way: additive to shell correctness, but isolated from auth and sign-out transport.
