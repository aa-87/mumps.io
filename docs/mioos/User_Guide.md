# MIOOS User Guide

## Signing in

Use the shell sign-in form to authenticate with a local MIOOS account.

Default bootstrap users in development-style setups are typically:

- `admin`
- `user`
- `guest`

If guest access is enabled, the shell can be entered without a full named sign-in.

## Switching languages

The shell supports:

- English
- Arabic
- Spanish

Use the language controls in the start menu side panel. Arabic switches the shell into RTL mode.

## Desktop basics

- open apps from the desktop icons or Menu
- use the taskbar to restore or minimize windows
- use the title bar buttons to minimize, maximize/restore, or close
- refresh the desktop from the Menu when needed

## Accessibility notes

- buttons and inputs are keyboard reachable
- reduced-motion preferences are respected
- shell chrome is designed to remain readable in all three supported languages

## Current limitations

- terminal is a foundation shell surface in this ROI, but reconnect durability and richer backends are still planned
- explorer/VFS, chat, rich playback apps, and debugger are planned for later ROIs

## Terminal foundation

Open **Terminal** from the desktop or Menu. Each new terminal window creates its own session and supports commands like `help`, `whoami`, `locale`, `profile`, and `date`.


## ROI 5 update
MIOOS terminals now run as real YottaDB `-direct` PIPE sessions owned by the websocket shell rather than a simulated command surface.


## Terminal behavior update
Each terminal window now opens its own websocket-backed terminal channel. The terminal should feel cleaner because typed input is no longer locally echoed into xterm before YottaDB responds.


## ROI 15 — Explorer search and VFS integrity
- Added VFS-level `fs.search` and `fs.hash` contracts over HTTP and websocket.
- Explorer now supports in-folder search, optional deep search, and a details panel with path, MIME, size, and SHA-256 for selected files.
- Boot metadata now advertises VFS search/hash capabilities so future apps can stay contract-driven.


## ROI B — Shared window manager foundation
MIOOS now uses a shared window manager contract for shell windows. Windows support drag, resize, maximize, minimize, restore, edge/corner snapping, and explorer drop-upload on supported windows. Terminal windows now inherit the same shell frame behavior rather than using a one-off interaction model.


## Theme Studio ROI

A detailed Theme Studio UI tool is available in MIOOS as a dedicated desktop app/window. It focuses on profile authoring and preview only, without changing the current native shell/taskbar/window styling baseline. The tool supports wallpaper choices, typography, sizing, color tokens, class recipes, extra CSS, import/export, local profile storage, and XP/Windows 7/Mac-inspired starter looks.


## ROI-F — Explorer + Transfers polish
- Explorer now uses 7.css as an interior accent layer while preserving native MIOOS shell chrome.
- Added a Transfers window for upload/download queue visibility and progress tracking.
- Transfer progress is surfaced across Explorer and the dedicated Transfers center.


## ROI-G — Desktop Icons, Layouts, and Context Menus
- Desktop icons are draggable with small, medium, and large size modes.
- Desktop and icon context menus expose refresh, rearrange, sorting, sizing, personalization, and Control Panel shortcuts.
- Icon layout preferences are persisted per user through the shell transport and also cached locally for responsiveness.


- ROI-H reapply: added chunked websocket downloads plus PDF and structured file viewers without changing the existing shell/window baseline.


## Download behavior
Large downloads continue through the Transfers experience, but MIOOS now performs an integrity check before saving when the browser supports secure hashing. If a download fails verification, the save is blocked instead of silently writing a corrupted file.


## Transfer controls
The Transfers window now shows cancel controls for active uploads/downloads and retry controls for failed or cancelled transfers. Retry works within the current browser session and is intended for operational recovery after a transient socket or refresh interruption.


## ROI 22 — Transport diagnostics and socket health
- Added a Diagnostics desktop app/window so the shell can inspect the advertised websocket contract, active transfer counts, terminal usage, and client-side socket telemetry without leaving the desktop.
- `transport.health` now returns session-scoped transport health including socket pool limits, heartbeat/resume settings, upload/download activity, and open terminal counts.
- The browser now records core and FS worker socket state transitions, pending request counts, last events, and recent socket errors for diagnostics.
