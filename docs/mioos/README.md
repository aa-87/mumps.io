# MIOOS README

MIOOS is a MUMPS-powered desktop shell for the MIO web stack.

## Current baseline

- SSR desktop shell via `MIOTPL`
- Vue 3 Options API UMD thin client
- local auth/session support on top of the MIO auth stack
- websocket shell channel
- English, Arabic (RTL), and Spanish locale support
- accessibility and performance metadata in the boot contract
- modular browser files under `public/mioos/app/`

## Immediate priorities

1. durable terminal reconnect/reattach behavior
2. global-backed virtual file system
3. explorer and file playback/apps
4. chat / rooms / groups / users
5. production-grade MUMPS debugger
6. shell polish, snapping, and motion details

## Key constraints

- no TypeScript
- no Vue Composition API
- no Node/Express assumptions
- no `ZSYSTEM`
- no `GOTO` in production code
- MAXSTRING-safe payload handling only

## Docs map

- `mioos_llm.md` — project handoff for future implementation work
- `docs/mioos/User_Guide.md` — operator-facing guide
- `docs/mioos/Internal_Doc.md` — architecture and subsystem notes
- `docs/mioos/HIPAA.md` — HIPAA-aware technical posture and limits

## Current terminal posture

ROI 4 lands an xterm.js terminal foundation with websocket command handling and multi-window session creation.


## ROI 5 update
MIOOS terminals now run as real YottaDB `-direct` PIPE sessions owned by the websocket shell rather than a simulated command surface.


## ROI 6 update
MIOOS now uses a split websocket posture: the core shell stays on `/ws/mioos`, while terminal windows use `/ws/mioos/terminal`. Each terminal window should re-bind to a terminal-specific websocket URL such as `/ws/mioos/terminal?terminalId=<uuid>&windowId=<id>` after open so shell actions stay responsive and the terminal path behaves more like a real terminal surface without a noisy poll loop.


Current terminal behavior follows MIOMOS: xterm.js on the client, a YottaDB PIPE-backed terminal on the server, and a core websocket command bus for terminal open/input/poll/resize/close.


## Terminal reset note
- Reset MIOOS terminal handling to mirror the working MIOMOS model: one core websocket, promise-based command bus, xterm local line editing, and MIOMOSTPIPE-style pipe session lifecycle adapted into MIOOSTPIPE.

## Latest ROI: VFS foundation

MIOOS now includes a global-backed virtual file system foundation. The current ROI focuses on contracts and durability rather than explorer UI. Files and folders live under globals, support metadata and permissions, and are available over both HTTP routes and websocket commands for later explorer integration.


## ROI 10 — Explorer upload and image viewer
- Added browser-side upload to the global-backed VFS using existing `fs.write` commands.
- Added image-aware file association handling in Explorer with preview and a dedicated image viewer window.
- Kept the backend stable by reusing existing VFS websocket commands rather than changing server storage contracts.


## ROI — Upload throughput and progress UX
- Added Explorer upload progress UI with percentage and stage text.
- Increased default chunk size for chunked uploads.
- Added a small parallel chunk pipeline on the browser for better upload throughput without sending a single oversized websocket frame.


## ROI 15 — Explorer search and VFS integrity
- Added VFS-level `fs.search` and `fs.hash` contracts over HTTP and websocket.
- Explorer now supports in-folder search, optional deep search, and a details panel with path, MIME, size, and SHA-256 for selected files.
- Boot metadata now advertises VFS search/hash capabilities so future apps can stay contract-driven.


## ROI B — Shared window manager foundation
MIOOS now uses a shared window manager contract for shell windows. Windows support drag, resize, maximize, minimize, restore, edge/corner snapping, and explorer drop-upload on supported windows. Terminal windows now inherit the same shell frame behavior rather than using a one-off interaction model.


## Theme Studio ROI

A detailed Theme Studio UI tool is available in MIOOS as a dedicated desktop app/window. It focuses on profile authoring and preview only, without changing the current native shell/taskbar/window styling baseline. The tool supports wallpaper choices, typography, sizing, color tokens, class recipes, extra CSS, import/export, local profile storage, and XP/Windows 7/Mac-inspired starter looks.
