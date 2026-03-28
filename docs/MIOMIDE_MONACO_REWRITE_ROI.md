# MIOMIDE Monaco rewrite ROI

This ROI rewrites the Monaco editor integration from scratch around one invariant:

- the page must render correctly before Monaco mounts
- Monaco enhances one dedicated, full-height host only after that host has measurable size
- if Monaco fails, editing still works through a textarea fallback

## Scope

This ROI intentionally narrows the UI to the minimum needed to make routine editing reliable:

- SSR-first shell
- explorer / tab strip / editor / output pane
- routine load
- routine edit
- routine save
- routine compile
- Monaco tokenization for MUMPS keywords, strings, comments, globals, and `$` functions
- textarea fallback if Monaco fails to initialize

## Why this is safer

Earlier attempts mixed layout rewrites, advanced tabs, panels, terminal state, and Monaco boot timing into one patch. That made it hard to isolate whether the failure was caused by layout collapse, AMD loader ordering, or editor mounting.

This rewrite separates those concerns:

1. fixed 4-row shell grid
2. full-height editor host
3. Monaco mounts only after the host has size
4. fallback editor keeps the routine editable even if Monaco fails

## Backend contract

- `GET /mioide` renders the IDE shell
- `GET /mioide/api/bootstrap` returns routes, appearance, editor config, and the initial routine list
- `GET /mioide/api/routines` lists routines
- `GET /mioide/api/routine/:name` loads a routine
- `POST /mioide/api/routine/:name/save` saves a routine
- `POST /mioide/api/routine/:name/compile` saves and compiles a routine

## Current limitations

- terminal is intentionally stubbed in this ROI
- debugger endpoints are placeholders
- advanced Monaco functionality like markers, split editors, and command palette are deferred until the render/edit loop is stable
