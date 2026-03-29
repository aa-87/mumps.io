# MIOMOS ROI36 — xterm.js YottaDB terminal reintegration

This pass keeps the MIOMOS terminal contract **MUMPS-first** and **YottaDB-direct over `MIOMOSTPIPE`**, while making the browser terminal surface a real **xterm.js** instance again.

## What changed

- xterm.js remains the only terminal renderer in the browser surface.
- The fake transcript fallback inside the terminal viewport was removed and replaced with a small loading state only.
- Terminal focus is no longer forcibly reset on every poll/result cycle.
- Terminal mount now waits for a real visible DOM box before opening xterm.
- Terminal output writes use xterm's async `write(..., callback)` path so scrolling happens after xterm parses the incoming chunk.
- The shell no longer paints a scanline overlay over the live xterm viewport.

## Why

The previous integration was recreating or refocusing the terminal surface too aggressively, which can make the cursor appear to blink too quickly and can make typing feel unreliable. xterm.js exposes `onData` for user input and `write(data, callback)` for rendering after parsing, which is the correct browser-side contract for a backing PTY/pipe session. citeturn913780search1turn913780search0

## Contract

- Client renderer: xterm.js
- Backend session: YottaDB direct session through `MIOMOSTPIPE`
- Input path: xterm `onData` -> `terminal.input`
- Output path: `terminal.open` / `terminal.poll` / `terminal.input` results -> xterm `write`
- Cursor blinking: xterm-controlled only; MIOMOS should not simulate cursor blinking with shell CSS

## Test coverage

`^MIOMOST` now also asserts:

- xterm asset token is present in the rendered desktop page
- xterm mount token is present
- terminal renderer token is present
