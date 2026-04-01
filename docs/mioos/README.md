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

1. xterm.js multi-session terminal foundation
2. durable terminal reconnect/reattach behavior
3. global-backed virtual file system
4. explorer and file playback/apps
5. chat / rooms / groups / users
6. production-grade MUMPS debugger

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
