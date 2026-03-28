# MIOMOS ROI 19 — Admin, Permissions, Theme Packs, and UI Foundation

## Objective
Advance MIOMOS from shell stabilization into a production-minded desktop foundation by improving four areas together:
- richer SSR-admin surfaces
- role/permission review visibility
- reimplemented theme packs with broader surface tokens
- a reusable UI library foundation for future MIOMOS and non-desktop SSR pages

## What changed

### Theme system reimplementation
`MIOMOSTH` now exposes fuller theme packs instead of mostly accent-level swaps.
Each theme pack includes tokens for:
- desktop background
- surface / alternate surface / inset surface
- borders and stronger borders
- active and inactive title chrome
- taskbar and menu surfaces
- button, input, and focus states
- success / warning / danger / info colors
- shadow levels

New theme catalog coverage includes:
- `midnight-professional`
- `slate-light`
- `clinical-blue`
- `surgical-teal`
- `high-contrast`
- `paper-chart`
- `sterile-night`

The client now applies theme variables into live CSS custom properties so the desktop chrome actually changes as a pack.

### Settings and UI foundation
`MIOMOSSET` and `MIOMOSVM` now expose a broader settings contract:
- expanded theme catalog
- accessibility preset catalog scaffold
- current theme object in addition to the theme key
- UI foundation payload for SSR previews

`MIOMOSUI` now ships an explicit UI foundation scaffold including:
- buttons
- inputs / textareas / selects
- checks / radios / toggles
- tabs
- cards
- tables
- badges / pills
- breadcrumbs
- drawer / toast previews
- stepper and tree patterns
- command palette entries
- token summaries for colors, spacing, typography, and states

This is intentionally SSR-first and demo-oriented. It lays the contract for later extraction into reusable MIOMOSUI pages and partials.

### Admin and permission surfaces
`MIOMOSADMIN` now exposes action metadata for the basic admin workflows already present in routes:
- disable account
- enable account
- lock account
- unlock account
- create invite
- issue reset token

`MIOMOSPERM` now exposes:
- a central permission catalog
- role definitions
- a role × permission matrix for review screens

The desktop admin and security windows now show:
- admin workflow cards
- richer user state tables
- invite and reset summaries
- permission matrix review surface
- governance / security review notes

## Why this ROI matters
This ROI does not try to finish every admin workflow interaction. Instead it makes the production surface coherent:
- the theme model is now strong enough to support real brand packs
- the UI library has a server-side contract and visible design language
- admin and permissions are no longer hidden in JSON-only routes
- later ROIs can attach inline actions to a cleaner, already-tested SSR shell

## Follow-on ROI suggestions
1. Inline admin mutations from the desktop shell with confirmation dialogs and toast feedback.
2. Theme editor / brand pack authoring backed by persisted token sets.
3. Reusable `MIOMOSUI*` partials for tables, forms, badges, drawers, and steppers.
4. Basic filtering, pagination, and sort affordances for admin/security tables.
5. Audit augmentation for admin actions triggered directly from the desktop shell.
