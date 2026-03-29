# MIOMOS ROI36 — xterm input and cursor stability

## Goal

Keep the working YottaDB-over-pipe terminal backend intact while making the xterm.js browser renderer behave like a normal terminal surface.

## Rules

- xterm owns the browser input surface and cursor rendering.
- MIOMOS should not override xterm helper textarea positioning.
- MIOMOS should not restyle xterm cursor animation cadence in CSS.
- xterm profile application should happen on mount, theme/font changes, and explicit terminal resize events — not on every poll or output message.
- terminal focus should target xterm itself and its managed textarea.

## Why

The previous pass mixed browser-renderer ownership with custom CSS/input overrides:

- repeated profile application on each poll/output cycle caused visible cursor flicker
- helper-textarea CSS overrides could interfere with keyboard focus and data entry

## Test posture

`^MIOMOST` should continue to cover the renderer contract at the rendered HTML level:

- `data-terminal-engine="xtermjs-ydb"`
- `data-terminal-renderer="xtermjs"`
- `data-terminal-focus="xterm-managed"`
- `data-terminal-textarea="xterm-owned"`

The backend terminal tests remain YDB/PIPE-first and should not regress because of browser-only renderer changes.

## Cursor blink note

MIOMOS has broad reduced-motion selectors that can compress `animation-duration` for all descendants under the desktop root. When xterm.js is mounted inside that tree, those selectors can unintentionally shorten xterm's own cursor-blink animation to nearly zero, which looks like a rapid flicker even though the terminal renderer is otherwise healthy.

The CSS should explicitly exempt the mounted xterm subtree from MIOMOS reduced-motion animation compression, or restore xterm's own animation duration inside the terminal host.

## Test posture update

`T011` should validate the backend terminal contract with a real MUMPS command such as `write 123,!`, not a shell command like `whoami`. The PIPE terminal launches `yottadb -direct`, so the terminal-output test should assert MUMPS output rather than POSIX shell identity output.
