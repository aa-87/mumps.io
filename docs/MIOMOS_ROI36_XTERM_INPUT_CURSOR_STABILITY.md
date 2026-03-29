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
