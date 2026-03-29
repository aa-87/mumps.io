# MIOMOS ROI37 — xterm cursor collision and T011 alignment

## Summary
This pass leaves the live YottaDB terminal runtime unchanged and fixes two mismatches introduced by the browser renderer transition:

- `^MIOMOST` `T011` now validates a real YottaDB-direct command (`write 123,!`) instead of a shell command.
- xterm cursor blinking is protected from MIOMOS reduced-motion CSS so the cursor does not blink at `.01ms`.

## Why
The terminal backend is a YottaDB direct session over the pipe transport. Shell commands such as `whoami` are not authoritative for this runtime. The browser renderer can be xterm.js, but the terminal contract remains MUMPS-first.

## Implementation notes
- Keep `MIOMOSTERM` and `MIOMOSTPIPE` behavior unchanged.
- Scope the cursor fix to the xterm cursor selector only.
- Do not relax MIOMOS motion rules globally just to satisfy terminal rendering.

## Tests
`T011` should pass by asserting that `123` appears in the terminal output after sending `write 123,!`.
