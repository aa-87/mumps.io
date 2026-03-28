# MIOMOS ROI36 MUMPS terminal contract

## Why this change exists

The websocket terminal profile is opening `yottadb -direct`, which is a MUMPS terminal, not a POSIX shell.

A websocket test that sends `whoami` is therefore asserting the wrong runtime behavior. In a direct YottaDB terminal, `whoami` is parsed as invalid MUMPS input and will fail even though the terminal transport is working correctly.

## Contract

When the configured PIPE command is `yottadb -direct`:

- `terminal.open` should return a pipe-backed terminal profile
- `terminal.input` should accept MUMPS commands
- tests should assert deterministic MUMPS output, for example `write "MIOWS-OK",!`

## Test adjustment

`MIOMOST` T016 now validates the websocket terminal path by sending a real MUMPS command and asserting the output buffer contains `MIOWS-OK`.

This keeps the test aligned with the runtime the terminal is actually launching.
