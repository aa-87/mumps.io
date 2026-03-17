# MIOUI Auth and Forms Plan

This document tracks the current auth/forms slice as a living area, not a one-off stub bundle.

## Current route

- `/mioui/auth-forms`

## Current implemented surfaces

- auth split shell
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

## Current test coverage

- `MIOUIT010` for route registration and auth metadata
- `MIOUIT033` for base auth/forms page smoke tokens and registry checks
- `MIOUIT034` for invitation, consent, and progressive preference tokens and registry checks
- `MIOUIT035` for invitation-state and expired-invite-recovery tokens and registry checks
- `MIOUIT036` for account-recovery and trusted-device tokens and registry checks
- `MIOUIT037` for admin-preference-matrix and access-review tokens and registry checks

## Immediate follow-up opportunities

- workspace bootstrap variants: create workspace vs join existing workspace
- dense first-run hardening forms for recovery, MFA, and trust choices
- role-aware reviewer handoff and reviewer-note form families
- billing review filter presets and multi-column query forms
