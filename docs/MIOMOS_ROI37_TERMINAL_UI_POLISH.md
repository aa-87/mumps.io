# MIOMOS ROI37 — Terminal UI polish

This ROI keeps the YottaDB-over-PIPE terminal backend unchanged and focuses on the browser surface and settings catalog.

## Scope

- Make the **Clear** button clear the xterm screen buffer instead of sending a command to YottaDB.
- Add terminal color presets under **Settings → Terminal profile**.
- Keep terminal theming explicit and stable without changing the transport or websocket command model.

## Changes

### Clear button behavior

The terminal toolbar button now calls the client-side clear action and carries the token:

- `data-terminal-clear="screen-buffer"`

The action clears:

- xterm viewport and scrollback buffer when xterm is mounted
- local MIOMOS transcript cache
- current unsent input line

It does **not** send a `clear` command into the YottaDB session.

### Terminal color presets

The terminal settings catalog now includes:

- `midnight-blue`
- `black-on-white`
- `white-on-black`

These presets are stored in terminal preferences and applied to:

- xterm theme colors
- terminal viewport chrome
- status line readability

## Testing

`^MIOMOST` now checks:

- terminal clear token presence
- terminal palette setting token presence
- terminal palette catalog entries
