# MIOUI Profile Variants Plan

## Goal

Add a dedicated SSR-first profile-page family.

The current implemented pass now covers:

- patient profile
- biller profile
- manager profile
- a comparison matrix that shows what should differ between profile families
- patient financial-summary profile
- patient payment-plan profile
- collector profile
- QA reviewer profile
- denial-specialist profile

## Why this ROI matters

The auth/forms lab now has enough depth.
The next high-value surface is role-aware profile pages.
These are common in billing and operational software.
They also create a reusable foundation for:

- collector profiles
- QA reviewer profiles
- denial specialist profiles
- workspace admin profiles
- payer contact profiles

## Architectural shape

- dedicated route: `/mioui/profile-variants`
- dedicated builder routine: `MIOUIPRF`
- dedicated page template
- reusable partials for each profile family
- registry entries for builder, partials, and page
- smoke prep added to `MIOUIT008`
- numbered suites in `MIOUIT040`, `MIOUIT041`, and `MIOUIT042`

## Current surfaces

### Patient profile

Should emphasize:

- coverage
- balances
- outreach preferences
- recent financial activity
- explanatory next actions

### Biller profile

Should emphasize:

- queue ownership
- productivity metrics
- payer focus
- access posture
- assignment actions

### Manager profile

Should emphasize:

- staffing pressure
- approvals
- escalations
- team heat
- capacity review actions

### Capability matrix

Should make the differences explicit.
This reduces layout drift when more profile families are added later.

### Patient financial-summary profile

Should emphasize:

- balance posture
- statement cadence
- ledger review
- assistance and discount screening
- counseling actions

### Patient payment-plan profile

Should emphasize:

- installment design
- autopay readiness
- grace windows and missed-payment risk
- hardship overrides
- agreement delivery actions

### Collector profile

Should emphasize:

- promise-to-pay inventory
- outbound cadence
- hardship and settlement branching
- compliance-safe scripting
- recovery actions

### QA reviewer profile

Should emphasize:

- audit sample queues
- defect clustering
- documentation drift
- coaching posture
- policy escalation signals

### Denial-specialist profile

Should emphasize:

- denial inventory by reason
- filing-window risk
- appeal packet completeness
- overturn strategy
- high-value escalation actions

## Follow-on ROI options

1. workspace admin and organization profile variants
2. payer and carrier-contact profile variants
3. shared profile tabs, activity strips, and role-aware sidecar panels
4. provider, scheduler, and front-desk profile variants
