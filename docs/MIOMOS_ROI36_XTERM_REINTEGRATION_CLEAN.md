# MIOMOS ROI36 Xterm reintegration (clean pass)

## Goal

Reintroduce xterm.js as the browser terminal renderer without changing the now-stable MIOMOS backend terminal contract.

## Source of truth

This pass starts from the repo state where `^MIOMOST` is already green and the terminal transport behaves correctly.

## Contract

- `MIOMOSTPIPE` remains the live YottaDB terminal owner for desktop command/websocket terminal actions.
- The browser should render that session with xterm.js.
- The browser should not use a fake transcript textarea or a CSS-only terminal emulator.
- Input remains line-oriented at the browser/command boundary for now. xterm.js handles local echo and line editing until Enter submits the line to MIOMOS.

## Front-end implementation

- Add xterm.js CSS and JS assets to the shell layout.
- Replace the replica terminal markup with an xterm host element inside the existing terminal viewport.
- Keep the existing toolbar and statusline tokens so the shell contract stays recognizable to tests and users.
- Mount xterm only after the host element has real dimensions.
- Let xterm own focus and cursor behavior.
- Do not force focus on every poll/result cycle.

## Behaviors to preserve

- `terminal.open`, `terminal.poll`, `terminal.input`, `terminal.resize`, and `terminal.close` continue to call the same MIOMOS backend commands.
- The terminal continues to use the current session and YottaDB pipe transport.
- `^MIOMOST` remains green.

## Tests

The smoke test should continue to validate the terminal surface and now also validate xterm renderer tokens in the rendered page.

## Follow-up ROI

A later ROI can vendor xterm assets locally instead of loading them from a CDN and can add a true character-stream transport if desired.
