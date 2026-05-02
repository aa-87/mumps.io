# Permissions Admin Module Example

This example shows an internal MIOOS UI module that uses the reusable backend table component for every grid and sends all module traffic through the core WebSocket command channel.

## Component

- Component key: `permissions`
- Surface: `mioos-surface-permissions`
- Script: `/public/mioos/app/mioos_permissions.js`
- Transport: WebSocket only

## Commands

- `module.table.query` for all permission tables
- `permission.upsert` to add or edit permissions, groups, and profiles
- `permission.delete` to remove permissions, groups, profiles, or assignments
- `permission.assign` to assign a permission profile to a user or role
- `permission.effective` to inspect effective permissions for the signed-in principal

## Table datasets

- `permissions`
- `permission-groups`
- `permission-profiles`
- `permission-assignments`
- `permission-audit`

## HIPAA-aligned safeguards

Permission changes are audited without storing PHI in the audit record. PHI-related permissions are explicitly marked, minimum-necessary profiles are first-class records, and break-glass access is a sensitive permission/profile flag.
