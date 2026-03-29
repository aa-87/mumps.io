# MIOMOS ROI40 — Resume token and replay foundation

## Goal
Add a conservative, test-backed resume foundation on top of the current passing MIOMOS websocket baseline without changing the working terminal command bus or reconnect behavior.

## What this ROI adds
- Session-scoped `resumeToken` persisted under `^MIO("MIOMOS","SESSION",sid,...)`
- Session-scoped monotonic websocket `eventSeq`
- Small replay outbox ring buffer per session
- Hello handshake support for:
  - `resumeToken`
  - `lastSeenEventSeq`
- Hello response metadata:
  - `resumeSupported`
  - `resumeTransport`
  - `resumeToken`
  - `resumed`
  - `lastEventSeq`
  - `replayCount`
- Browser local storage of websocket resume state per MIOMOS session
- Replay-ready direct websocket terminal events (`terminal.open`, `terminal.stdout`, `terminal.resize`, `terminal.close`)

## Intentional limits
This ROI does **not** change the existing command bus semantics for normal desktop commands or terminal commands. The command path remains the source of truth for the currently working UI.

Replay is intentionally limited to a safe foundation:
- terminal direct websocket events are sequence-stamped and stored
- chat snapshots still bootstrap chat state on hello
- command request/response replay is intentionally deferred to a later ROI so pending request semantics stay stable

## Why this shape is safer
The repo baseline is already passing and currently stable after reverting the more aggressive reconnect experiments. This ROI only adds resume metadata, sequencing, outbox storage, and client persistence. It does not take ownership away from the current command bus path.

## New server helpers
### `MIOMOSST`
- `RESUMETOKEN(SID)`
- `LASTSEQ(SID)`
- `NEXTSEQ(SID)`
- `APPENDOUTBOX(SID,SEQ,JSON,LIMIT)`
- `REPLAYJSONS(SID,LASTSEQ,LIMIT,.OUT)`

### `MIOMOSWS`
- `HELLOJSON(.STATE,PAYLOAD,.OUT)`
- `SENDREPLAY(.DEV,.STATE,JSON,REPLAYABLE,.CONF)`
- `STAMPREPLAYJSON(SID,JSON,.RESP,.ERR,LIMIT)`
- `HELLOSIDJSON(.CONF,.REQ,.CTX,SID,PAYLOAD,.RESP,.ERR,.REPLAY)`

## Tests added
- SSR token coverage for resume transport
- Boot JSON coverage for resume policy and replay limit
- Replay stamping test for sequence assignment
- Resume hello test proving:
  - resume is supported
  - resume is recognized with matching token
  - replay is returned for missed sequence state

## Follow-on ROI
The next websocket ROI can safely build on this by adding richer replay categories and reconnect-driven terminal reattach behavior.

- Resume foundation note: replay stamping now prefers structured JSON re-encode and falls back to direct `eventSeq` injection for internal event payloads, so replay does not depend on a single terminal payload shape.


Resume note: the hello handshake now uses an explicit non-empty token equality check when deciding whether a reconnect is resumable, so replay eligibility is no longer gated by a malformed conditional.
