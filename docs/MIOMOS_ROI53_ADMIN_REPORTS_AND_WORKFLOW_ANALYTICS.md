# MIOMOS ROI53 — admin reports and workflow analytics

## Goal

Extend the admin surface from user and role control into an operational reporting center that stays server-authored, SSR-rendered, and export-friendly.

## Delivered

- `GET /api/miomos/admin/reports`
- MUMPS-authored report helpers in `MIOMOSADMIN`
- Admin view-model expansion in `MIOMOSVM`
- New admin SSR report center in `miomos_desktop.html`
- Test coverage for route metadata, report contract, and rendered admin analytics tokens

## Report areas

### Active users and recent session posture
- active session count
- locked session count
- forced sign-out count
- recent session rows

### Guest usage analytics
- guest session count
- guest access-event count
- guest audit-event count
- last guest activity

### Failed sign-ins and lockout trends
- users with failures
- total failed attempts
- locked user count
- recent failure rows

### Invite and reset workflow activity
- open/used invites
- open/used resets
- recent invite/reset rows

### Permission and session posture
- users with admin-management capability
- terminal-capable users
- audit-view users
- settings-capable users
- role mix counts
- session binding, idle-lock, and registry posture

## Next ROI

**ROI54 — permission-aware websocket event fabric**
