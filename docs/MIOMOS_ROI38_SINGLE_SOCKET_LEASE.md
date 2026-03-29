# MIOMOS ROI38 — Single active websocket lease

## Goal

Harden the MIOMOS websocket transport so each MIOMOS session has one authoritative active websocket owner at a time.

This ROI does **not** implement replay or resume yet.
It establishes the lease contract that later reconnect/resume work will build on.

## What changed

### Server-side lease model

`MIOMOSWS` now treats `hello` as a lease-claim handshake.

For each MIOMOS session, the server tracks:

- `activeConnectionId`
- `activeLeaseId`
- `activeLastSeenAt`
- `activeLeaseExpiresAt`
- `duplicatePolicy`
- `leaseGeneration`

The authoritative lease state lives under:

- `^MIO("MIOMOS","WS","SESSION",sessionId,...)`
- `^MIO("MIOMOS","WS","CONNECTION",connectionId,...)`

### Duplicate socket policy

Current policy: `supersede-older`

That means:

- the first socket to say `hello` becomes active
- a later socket for the same MIOMOS session claims a newer lease
- the older socket is fenced off on its next command or heartbeat
- the fenced socket receives `session.superseded` and is closed

### Client behavior

The browser desktop now:

- records `connectionId`, `leaseId`, and `leaseExpiresAt` from `hello` / `pong`
- treats `session.superseded` as a terminal socket state for that page instance
- stops automatic reconnect once the socket has been superseded
- surfaces the superseded condition as a shell alert

## New boot / policy contract

The desktop boot JSON now exposes:

- `desktop.policy.singleSocketLease = 1`
- `desktop.policy.wsLeaseTtlSeconds = 45`
- `desktop.policy.duplicateSocketPolicy = "supersede-older"`
- `desktop.policy.resumeTransport = "planned-roi40"`

## Test coverage

`^MIOMOST` now covers:

- render tokens for the single-socket lease contract
- boot JSON policy exposure for the lease settings
- helper-backed websocket lease handshakes
- duplicate hello superseding the older connection
- fencing the older connection via `LEASEACTIVE^MIOMOSWS`

## Acceptance bar for ROI38

- one MIOMOS session has one active websocket owner
- later websocket hellos supersede older owners deterministically
- stale owners cannot continue to issue live shell commands once fenced
- the browser does not reconnect endlessly after being superseded

## Explicitly deferred to the next ROIs

### ROI39
- heartbeat / lease renewal hardening
- jittered reconnect
- close-reason normalization

### ROI40
- resume token
- replay by event sequence
- replay window fallback to fresh snapshot

### ROI41
- terminal continuity across reconnect
- terminal reattach and grace period
