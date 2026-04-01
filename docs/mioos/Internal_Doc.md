# MIOOS Internal Documentation

## Architecture summary

MIOOS is a server-authored shell.

- MUMPS owns the authoritative state
- SSR delivers the initial page and boot contract
- Vue 3 Options API UMD renders and interacts with that contract
- websocket is the primary realtime surface
- auth/session state is resolved on the server

## Current browser split

The browser shell is now split into:

- `public/mioos/app/mioos_state.js`
- `public/mioos/app/mioos_i18n.js`
- `public/mioos/app/mioos_auth.js`
- `public/mioos/app/mioos_ws.js`
- `public/mioos/app/mioos_wm.js`
- `public/mioos/app/mioos_core.js`
- `public/mioos/mioos_desktop.js` as the tiny mount wrapper

## Locale model

Locale resolution is server-side in `MIOOSI18N` with the following order:

1. query parameter (`lang` / `locale`)
2. locale cookie if present
3. `Accept-Language`
4. configured default (`en`)

Supported locales today:

- `en`
- `ar`
- `es`

## Accessibility baseline

The shell currently enforces a baseline of:

- keyboard focus visibility
- reduced-motion CSS support
- dialog/menu/taskbar labels where practical
- SSR `lang` and `dir`
- RTL-aware layout adjustments

## Performance baseline

The shell currently favors:

- thin client state
- server-authored catalogs and view models
- websocket-first transport
- constrained DOM structure
- no build step for the browser modules

## Near-term next step

The next implementation ROI should harden terminal durability using the same contract discipline:

- one clear transport boundary
- server-owned session policy
- multi-window support
- reconnect and reattach posture

## ROI 4 terminal foundation

Terminal windows now use xterm.js in the browser and a server-owned websocket command contract in `MIOOSTERM` / `MIOOSWS`.


## ROI 5 update
MIOOS terminals now run as real YottaDB `-direct` PIPE sessions owned by the websocket shell rather than a simulated command surface.


## Terminal transport architecture
Use the primary MIOOS websocket for desktop state and shell commands. Use `MIOOSTWS` on `/ws/mioos/terminal` for terminal-only events such as `terminal.open`, `terminal.attach`, `terminal.input`, `terminal.resize`, and `terminal.close`. After a terminal is created, the browser should bind that window to a terminal-specific websocket URL such as `/ws/mioos/terminal?terminalId=<uuid>&windowId=<id>` so terminal traffic stays isolated and no steady-state poll loop is needed for routine typing. This same pattern can later be reused by the debugger and other realtime apps that need isolation.


## Terminal transport note

The active MIOOS browser terminal path follows the proven MIOMOS pattern: terminal.open / terminal.input / terminal.poll / terminal.resize / terminal.close all travel over the core shell websocket command bus. Dedicated per-terminal websocket experimentation is deferred until the MIOMOS-equivalent behavior is stable.


## Terminal reset note
- Reset MIOOS terminal handling to mirror the working MIOMOS model: one core websocket, promise-based command bus, xterm local line editing, and MIOMOSTPIPE-style pipe session lifecycle adapted into MIOOSTPIPE.
