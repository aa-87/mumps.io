# MIOMOS ROI47 — Guest role and role-aware shell workflow

## Goal

Carry the ROI46 bootstrap-auth work into the actual desktop shell so guest sessions do not just fail on privileged actions after launch. The shell should start already aware of the active role.

## Scope delivered

1. **Role-aware boot metadata**
   - `user.primaryRole`
   - `user.roleLabel`
   - `user.roleTone`
   - `user.isGuest`
   - `auth.workflow = role-aware`
   - `desktop.roleAwareShell = 1`
   - `desktop.launchVisibility = permission-aware`
   - guest-only hidden launcher arrays for apps and shell actions

2. **Guest launcher filtering**
   Guest sessions now hide the following shell entries at the launcher layer:
   - `terminal`
   - `security`
   - `admin`
   - `logs`

   Guest sessions also hide the `focusTerminal` shell action.

3. **Role copy and badges**
   The desktop now surfaces role-aware copy so the limited-access guest workflow is explicit instead of implicit.

4. **Access page clarity**
   The access page now shows seeded bootstrap identities and explains that guest access enters a limited role-aware shell.

## Why this ROI matters

ROI46 made guest login explicit and config-backed. ROI47 makes the shell itself honest about what a guest can actually do. That keeps the desktop cleaner, reduces dead-end clicks, and prepares the product for a stronger admin/user/guest operating model.

## Files touched

- `routines/MIOMOSST.m`
- `routines/MIOMOSVM.m`
- `routines/MIOMOSUI.m`
- `routines/MIOMOST.m`
- `templates/pages/miomos_auth.html`
- `templates/pages/miomos_desktop.html`
- `miomos_llm.md`

## Next ROI

- **ROI48** — admin role center
  - role assignment editor
  - effective permission preview
  - guest-login toggle and bootstrap-auth posture in admin UI
