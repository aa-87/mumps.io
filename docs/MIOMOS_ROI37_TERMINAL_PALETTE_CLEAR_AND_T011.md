# MIOMOS ROI37 — Terminal palette, clear behavior, and YottaDB-aligned tests

This ROI stabilizes three terminal concerns on the current repo baseline without changing the working PIPE/YottaDB backend contract.

## Scope

- Restore a persisted terminal palette setting in **Settings → Terminal**
- Keep xterm.js as a renderer only; MUMPS remains the terminal/session authority
- Make **Clear** wipe the mounted xterm buffer instead of sending a shell-style command into YottaDB
- Align `^MIOMOST` terminal tests with the actual terminal runtime (`yottadb -direct`)

## Terminal palette contract

`MIOMOSTERM` now owns a `terminal.palette` preference with the following values:

- `theme` — follow the active MIOMOS theme mode
- `midnight-blue` — dark clinical palette
- `black-on-white` — light terminal palette
- `white-on-black` — high-contrast dark palette

The palette is:

- loaded into `STATE("terminal","palette")`
- exposed through the settings catalog
- persisted by `SAVEPROF^MIOMOSTERM`
- applied by the xterm renderer in the browser

## Clear behavior

The terminal clear button is now a UI action:

- it clears the local transcript buffer
- it clears the mounted xterm viewport/buffer
- it does **not** send `clear` into YottaDB

That keeps the terminal MUMPS-first while matching user expectation for a terminal UI clear button.

## Test alignment

`T011` previously sent `whoami`, which only makes sense for a shell process.
The actual MIOMOS terminal runtime is `yottadb -direct`, so the test now sends:

```
write 123,!
```

and asserts that `123` appears in terminal output.

## Regression coverage

The smoke suite now checks:

- terminal palette setting token
- terminal clear action token
- terminal palette catalog presence
- saved terminal palette preference
- YottaDB-aligned terminal output in `T011`
