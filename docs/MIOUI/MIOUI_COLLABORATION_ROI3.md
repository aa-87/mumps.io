# MIOUI collaboration ROI 3

## Scope

This ROI shifts the collaboration layer toward onboarding surfaces.

The goal is not a marketing-style signup funnel.
The goal is dense, reusable, workspace onboarding for real operator software.

The onboarding family stays SSR-first.
It reuses the identity and connected-user primitives from ROI 1.
It points forward to workspace shells and billing-integrated collaboration.

## Variants

- standard onboarding workspace
- dense onboarding review
- guided onboarding launch

All three variants reuse the same server-built onboarding context.
The pages vary composition, density, and where preview panels are placed.

## Components

- onboarding summary shell
- step cards with progress state
- setup block cards
- invite preview roster
- launch readiness checklist
- launch and defaults panel
- starter room cards
- guided journey rail
- connected-user preview
- user bubble preview

## Test coverage

- route registration for all onboarding routes
- smoke render for all three onboarding pages
- builder contract checks for counts, active tabs, and summary values
- token coverage across all three variants for step labels, launch controls, room defaults, and connected-user preview

## Synthetic data

All names, roles, rooms, notes, and launch details in this ROI are synthetic fixtures.
No source patient or billing message content is reused.
