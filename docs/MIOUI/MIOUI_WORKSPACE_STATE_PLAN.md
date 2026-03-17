# MIOUI Workspace State Plan

## ROI 16

This ROI turns dense layouts into durable workspace state.

It adds reusable surfaces for:

- session-restored layout state
- auth-aware role defaults
- route-specific pane persistence
- mobile-first dense audit layout variants
- threaded annotation rails tied to workspace context
- a visible workspace state footer

## Why this matters

High-intensity operator products lose time when the user must rebuild the same shell every login or every route change.

This layer makes layout state part of the product contract.

## New page

- `/mioui/workspace-state`

## New reusable surfaces

- `mioui_session_layout_restore.html`
- `mioui_auth_role_default_layouts.html`
- `mioui_route_pane_persistence.html`
- `mioui_mobile_audit_layout_variants.html`
- `mioui_annotation_state_rail.html`
- `mioui_workspace_state_footer.html`

## Follow-on ROI ideas

- per-tenant layout policy limits
- state merge rules between role defaults and user overrides
- stale-state expiration markers
- optimistic save banners and conflict warnings
- layout audit history timeline
