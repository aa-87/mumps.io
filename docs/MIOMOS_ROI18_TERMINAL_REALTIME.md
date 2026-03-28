# MIOMOS ROI 18 — Realtime Terminal Transport

## Goal
Move the MIOMOS terminal from a line-oriented demo bridge to a websocket-owned realtime terminal path that stays within the MIO/YottaDB architecture.

## Why this ROI exists
Earlier terminal work proved out the shell surface and PIPE launch capability, but the live path still had two production blockers:
- the browser sent terminal input as completed lines instead of raw keystream data
- the terminal could be opened by an HTTP request job and then used from a websocket job, which is not a stable ownership model for PIPE-backed interactive sessions

For a terminal that feels close to a real terminal, the websocket handler must own the session lifecycle and keep terminal I/O in that same M process.

## What changed

### Websocket-owned terminal lifecycle
`MIOMOSWS` now treats the websocket as the authoritative terminal transport for:
- `terminal.open`
- `terminal.attach`
- `terminal.input`
- `terminal.resize`
- `terminal.poll`
- `terminal.close`

The terminal session is reopened on attach when the stored session is stale for the current process.

### Raw terminal input
The browser now sends terminal input in `data` frames rather than buffering until Enter.
This allows:
- per-keystroke forwarding
- control character delivery
- closer alignment with legacy terminal behavior
- better compatibility with YottaDB direct mode interactions

A small pending-input buffer is kept client-side so keystrokes typed during reconnect/open negotiation are flushed after the server confirms `terminal.open` or `terminal.attach`.

### Session ownership and replay
`MIOMOSTPIPE` now tracks:
- session principal
- MIOMOS session id
- owning M process job
- open time
- last-seen time
- viewport cols/rows
- transcript tail

Attach now returns a transcript tail snapshot so reconnects can restore visible context without resending the entire session history.

### Terminal defaults and hardening
`MIOMOS` configuration now provides explicit PIPE defaults for:
- `command`
- `openTimeout`
- `readTimeout`
- `readLimit`
- `readPolls`
- `drainPause`
- `transcriptMaxChunks`
- `attachTailChunks`
- `sessionIdleSeconds`
- `sessionAbsoluteSeconds`

The default terminal command is now `yottadb -direct`.

### UX refinement
The desktop terminal surface now advertises the realtime transport model and behaves like a live terminal instead of a line-submission console.
The client also:
- reattaches after websocket hello/reconnect
- resizes with a `ResizeObserver`
- stops relying on command-route polling for the primary terminal UX

## Risk posture
Moderate.
- Terminal transport behavior changed significantly.
- The command route still exists, but the desktop now prefers the websocket path for live terminal work.
- PIPE lifecycle remains intentionally conservative and MUMPS-owned.

## Suggested verification
- Load `/miomos`
- Launch Terminal
- Confirm the first prompt appears without using the command route
- Type individual characters and confirm immediate forwarding
- Confirm Enter, backspace, and control sequences traverse the websocket path
- Resize the terminal window and confirm cols/rows updates are emitted
- Disconnect/reconnect the websocket and confirm the terminal reattaches with recent transcript context
- Close the terminal and confirm metadata is cleared

## Next likely ROI
- richer control-sequence validation matrix
- alternate screen validation
- bracketed paste handling
- transcript/backpressure controls for long-running sessions
- policy-driven admin/session termination hooks
