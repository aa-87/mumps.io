# MIOMOS ROI164 — Taskbar flyouts and account menu

This ROI continues shell correctness on top of the passing `session.ui.save` rebuild without changing the websocket auth workflow.

## What changed

- wired the existing server-authored `view.notifications` payload into a real **taskbar notification flyout**
- wired the existing server-authored `shellChrome.accountMenu` payload into a real **account flyout**
- kept the **single-open-surface** rule by treating taskbar flyouts as peers of Start, context menus, and dialogs
- added outside-click and Escape-key dismissal for taskbar flyouts
- kept flyout actions thin and deterministic: they launch existing apps, open existing dialogs, refresh the view, or call the existing signout workflow
- added regression coverage for the new flyout contract tokens and boot/view metadata

## Production intent

The taskbar now behaves more like a real desktop control surface. Notifications and account actions are authored in MUMPS, rendered by the thin Vue layer, and do not bypass the existing websocket command/event model.

## Explicit non-goals

- no changes to auth route ownership
- no changes to websocket handshake, resume, or shell command transport
- no changes to `session.ui.save` payload shape

## Recommended next ROI

- keyboard-first flyout navigation and richer focus management
- window-switcher and taskbar grouping polish
- stronger notification history and dismiss-state persistence
