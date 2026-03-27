# MIOMOS User Guide (ongoing)

## What MIOMOS is
MIOMOS is a MUMPS-first desktop workspace running inside the MIO web stack. It provides a compact desktop shell, optional local authentication, operational windows, admin/security surfaces, and realtime collaboration over a persistent websocket.

## Desktop basics
- Use the desktop icons or Menu to open apps.
- Use the taskbar to restore/minimize windows.
- Drag windows by the title bar.
- Snap a window left, right, or top to dock/maximize it.
- Double-click the title bar to maximize or restore.

## Built-in apps
### Workspace
Operational view for queues, review, exports, and primary day-to-day work.

### Chat
Team communication view. Messages are sent over the persistent MIOMOS websocket and stored server-side.

### Security
Security and observability surface. It shows:
- access/error/audit totals
- recent audit events
- recent error events
- permission pills for the current user
- export links for summary, logs, audit, and digest downloads

### Admin
User and identity operations. Depending on permissions, this surface shows:
- user directory
- invite tokens
- reset tokens
- enable/disable/lock/unlock posture

## Authentication
MIOMOS supports two main modes:

### Development mode
Authentication can be disabled during development by using the MIOMOS dev profile.

Typical local-dev posture:
```mumps
S CONF("miomos","profile")="dev"
S CONF("miomos","dev","authDisabled")=1
```

### Optional local authentication
When enabled, MIOMOS can provide built-in:
- sign up
- sign in
- sign out
- invite-only onboarding
- account lockout after failed attempts
- reset-token based password reset

## Security and observability exports
The Security window provides links to:
- summary JSON
- access export
- error export
- audit export
- security digest

These exports are permission-gated. If a link returns forbidden, your account does not currently have the required permission.

## Retention
MIOMOS keeps observability data according to server-side retention settings. In the current ROI, pruning is exposed through an API rather than a full desktop form.

## Keyboard shortcuts
- `Alt+1` Workspace
- `Alt+2` Chat
- `Alt+3` Security
- `Alt+4` Admin
- `Alt+M` open/close Menu
- `Alt+Left/Right/Up/Down` snap active window
- `Esc` close Menu

## Troubleshooting
### “login_required”
Local auth is enabled and the browser session does not currently have a valid MIOMOS auth token.

### “forbidden”
Your role does not have the needed MIOMOS permission.

### Socket shows offline
The desktop can continue to render SSR content, but live chat/status updates will be unavailable until the websocket reconnects.

## Ongoing gaps
This guide will keep expanding as MIOMOS adds:
- full admin forms
- support workflows
- accessibility presets
- session lock/re-auth flows
- deeper personalization
