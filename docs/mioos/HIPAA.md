# MIOOS HIPAA-Aware Technical Posture

## Important limitation

This document does **not** mean MIOOS is legally certified, audited, or automatically HIPAA compliant.

HIPAA compliance depends on the full environment:

- hosting
- access control
- encryption
- logging
- retention
- operational processes
- vendor agreements / BAA posture

What MIOOS can do is maintain a technical posture that supports HIPAA-sensitive use.

## Technical principles

### 1. Server-owned policy

Sensitive policy should remain server-authored in MUMPS routines rather than delegated to the browser.

### 2. Least privilege

Use role-based and attribute-based authorization through the MIO auth stack.

### 3. Minimize client exposure

Do not send PHI to the browser unless the current desktop surface truly requires it.

### 4. Session hygiene

Use explicit sign-in/sign-out, revocable sessions, bounded JWT/session lifetimes, and auditable identity claims.

### 5. Transport security

Production deployment should require TLS and secure cookie posture.

### 6. Auditability

Security-relevant actions should be loggable and attributable to authenticated principals.

### 7. Storage discipline

Large or sensitive payloads should remain MAXSTRING-safe and should prefer server-side globals or `^TMP($J,...)` buffers where appropriate.

## Current project alignment

Current MIOOS work already aligns with this posture by emphasizing:

- SSR and server-authored boot/view contracts
- local auth/session plumbing over the MIO auth stack
- structured errors
- quiet tests and explicit contracts
- no Node runtime assumptions
- no `ZSYSTEM`

## What still needs to happen

To move closer to HIPAA-ready operation, later ROIs should add or harden:

- stronger authz boundaries per desktop app and file/action
- auditable chat and collaboration events
- session timeout and device/session management UX
- secure terminal attach and debugger authz
- PHI-aware file playback permissions and logging
- deployment guidance for encryption, cookies, logs, and backups


## Transfer integrity note
Verified chunked downloads reduce the chance of silent corruption during browser saves, which is helpful in regulated environments, but they do not replace audit logging, encryption, access controls, or deployment policy.
