# MIOMOS ROI36 — Clean xterm reintegration over direct websocket terminal events

## Goal
Reintegrate xterm.js without changing the working YottaDB/PIPE backend and without layering a fake textarea terminal UI on top of the live terminal surface.

## What changed
- The terminal window mounts a real xterm.js host element.
- Terminal input uses the dedicated websocket terminal events directly (`terminal.open`, `terminal.input`, `terminal.poll`, `terminal.resize`, `terminal.close`).
- This bypasses the generic `command.exec` inflight queue for terminal typing.
- xterm owns focus, keyboard capture, selection, cursor rendering, and viewport drawing.
- MIOMOS remains the source of truth for the terminal session and output stream.

## Why this is cleaner
The earlier integration mixed xterm rendering with the generic desktop command bus and a replica terminal surface. That made it easier to hit command backpressure while typing and easier to accidentally layer more than one cursor/input surface.

The clean contract is:
- xterm.js for browser rendering
- direct websocket terminal events for terminal I/O
- `MIOMOSTPIPE` for the YottaDB direct session

## Settings and theming
- Terminal font family and font size flow from the existing MIOMOS terminal settings.
- Cursor blink and cursor style flow into xterm options.
- Terminal theme colors derive from the active MIOMOS theme variables.
