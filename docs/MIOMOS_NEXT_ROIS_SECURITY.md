# MIOMOS next ROIs toward production readiness

## ROI 6: identity hardening and admin surfaces
- local user admin app
- disable/lock user accounts
- password rotation and reset tokens
- invite-only signup mode
- route-level permission enforcement for admin/security surfaces
- tests for lockout, disabled account, reset token expiry, admin-only actions

## ROI 7: audit and observability hardening
- structured access/error export APIs
- retention pruning jobs
- downloadable audit digest views
- richer privileged-action audit details
- correlation IDs across desktop/bootstrap/ws/auth
- tests for retention, pruning, and export payload correctness

## ROI 8: real-time collaboration
- multi-socket room fan-out
- presence list and typing state
- chat moderation actions
- per-room permission controls
- tests for multi-user room fetch/send ordering and moderation

## ROI 9: theming and workspace personalization
- theme editor / brand packs
- per-user density and layout presets
- persisted taskbar/menu composition
- accessibility presets and contrast checks
- tests for preference persistence and fallback behavior

## ROI 10: security/compliance finish
- idle lock screen and re-auth
- support for external auth + local auth coexistence policies
- stronger audit coverage for exports, downloads, and permission changes
- support-focused access review screens
- tests for session timeout, absolute timeout, and permission drift
