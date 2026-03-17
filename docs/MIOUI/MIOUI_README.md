# MIOUI README

MIOUI is the SSR-first UI package inside this repo.

It is built for dense, operator-heavy MUMPS applications.
It stays server-owned.
It uses MIOTPL templates, MUMPS-built view models, and minimal browser enhancement.

## Current implemented areas

- app shell and layout system
- dense component catalog
- table, large-table, and million-row table studies
- billing and trace review surfaces
- workflow and onboarding surfaces
- control-room, adaptive, overlay, diversity, and topology layout families
- auth and form surfaces
- profile variant surfaces

## Current auth/forms coverage

The auth/forms lab lives at `/mioui/auth-forms`.

It currently includes:

- login card
- signup card
- forgot password card
- reset password card
- MFA challenge card
- profile registration form
- multi-step onboarding form
- advanced filter form panel
- inline validation summary
- workspace invitation form
- invitation state variants
- expired invite recovery form
- consent and approval form
- progressive disclosure security/preferences form
- account recovery variant stack
- trusted device message panel
- admin preference matrix form
- access review approval stack
- workspace bootstrap variant stack
- workspace bootstrap resolution form
- profile completion variant stack
- first-run account hardening form

## Current profile-page coverage

The profile variants page lives at `/mioui/profile-variants`.

It currently includes:

- patient profile dossier
- biller profile workbench
- manager profile command deck
- profile variant capability matrix
- patient financial summary profile
- patient payment-plan profile
- collector profile workbench
- QA reviewer profile board
- denial specialist profile desk

## Architectural rules

- SSR first
- MUMPS-owned context
- MIOTPL pages and partials
- reusable partials over page duplication
- dense layouts over decorative spacing
- quiet-on-success tests

## Testing

Auth/forms and profile coverage currently spans:

- route registration coverage in `MIOUIT010`
- auth/forms page coverage in `MIOUIT033`
- invitation, consent, and progressive-preferences coverage in `MIOUIT034`
- invitation-state and expired-invite-recovery coverage in `MIOUIT035`
- account-recovery and trusted-device coverage in `MIOUIT036`
- admin-preference-matrix and access-review coverage in `MIOUIT037`
- workspace-bootstrap variants and resolution coverage in `MIOUIT038`
- profile-completion and first-run-hardening coverage in `MIOUIT039`
- profile-variants page coverage in `MIOUIT040`
- patient financial-summary and payment-plan profile coverage in `MIOUIT041`
- collector, QA reviewer, and denial-specialist profile coverage in `MIOUIT042`
- smoke render preparation in `MIOUIT008`

## Current implementation note

The current pass preserves the existing auth/forms lab and expands the dedicated profile-variants page.
The profile family now includes patient, biller, manager, patient-financial, collector, QA reviewer, and denial-specialist variants.
It does not replace the existing architecture.
