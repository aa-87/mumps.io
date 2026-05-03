# ROI 72A — Shell/Table Stabilization and Terminal Rewrite Planning

## Goal

Stabilize the shell and Advanced Table surfaces before the larger terminal rewrite track proceeds. This ROI is intentionally regression-focused: it fixes launch-breaking viewer templates, dense menu usability, table cell-edit ergonomics, multi-file upload entry points, and Patient Registration status actions while preserving the existing Vue Options API UMD and MUMPS-first backend architecture.

## Fixes

- Start Menu now uses a dense Windows 98-style list treatment so it can handle large catalogs without excessive padding.
- Inline table cell editors keep the `✓` save and `×` cancel controls visible even in narrow cells.
- Enter saves a cell edit and Escape cancels it.
- Select and multiselect cell editors keep the Add Value path available through the server-backed `column.option.add` mutation.
- Table action feedback uses a floating modal toast instead of inline table feedback.
- Patient Registration exposes server-side `Mark active` and `Mark inactive` row actions, plus a bulk Mark active action.
- Multi-file upload is supported from the upload picker, folder drag/drop, and desktop drag/drop.
- File viewers use safe Vue template bindings and download through the existing viewer/download helper.
- Window control buttons stop pointer events before titlebar drag handling, avoiding drag/maximize/close render conflicts.

## Terminal rewrite follow-up ROIs

The terminal rewrite remains intentionally split into focused ROIs because it touches websocket transport, MUMPS PIPE lifecycle, UI rendering, and automation.

### Terminal ROI T1 — transport foundation

- Dedicated terminal socket lifecycle per terminal window.
- Immediate input send path with bounded acknowledgement timeout.
- Fast output streaming without poll-driven lag when websocket transport is available.
- Clean close/reattach semantics.
- Backend tests for open/input/output/resize/close lifecycle.

### Terminal ROI T2 — profiles and customization

- Terminal profile registry for font family, font size, background, foreground, cursor, scrollback, and shell startup metadata.
- Per-window profile selection.
- Persisted terminal shortcut definitions.
- MUMPS-authored profile examples.

### Terminal ROI T3 — startup automation sequences

- Terminal shortcuts can specify a startup routine and timed input sequence.
- Sequence steps support delay, input, wait-for-output, and stop-on-error.
- Automation is auditable and permission-gated.
- The UI must clearly distinguish automated input from user input.

### Terminal ROI T4 — final hardening

- Mobile terminal controls.
- Multi-terminal layout support.
- Terminal reconnection/reattach tests.
- Transport degradation behavior.
- Documentation for safe deployment without `ZSYSTEM` assumptions.

## Validation

Run JavaScript syntax checks for touched browser modules and `D ^MIOOST` in a YottaDB / GT.M environment. This environment cannot run `ZLINK`/`D ^MIOOST`, so those checks must be completed in the project runtime.
