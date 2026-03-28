# MIOMIDE ROI 6 — Monaco Editor Foundation

This ROI pivots the IDE around Monaco as the primary editor surface.

## Scope

- Replace the textarea/highlight overlay editor with Monaco
- Register a MUMPS language in Monaco with Monaco-friendly tokenization
- Back each open tab with its own Monaco text model
- Persist and restore editor tabs from local workspace state
- Apply compile problems as Monaco markers
- Preserve tab drag/drop and tab context menu behavior
- Keep terminal, search, globals, save, compile, and run flows working
- Improve routine loading by returning joined `source` text and using a more robust source path lookup

## Key backend changes

### `MIOMIDERT`

- `LOAD` now returns:
  - `source`
  - `sourceLines`
  - `lineCount`
  - `byteCount`
  - `checksum`
- Added `SOURCEPATH(CONF,NAME,CREATE)` so routine loading first tries to resolve an existing source path before falling back to the default write path.
- `SAVEARR` now returns joined `source` too.

### `MIOMIDEST`

- Bootstrap now advertises a dedicated Monaco editor block:
  - engine
  - loader URL
  - base URL
  - language id
  - model URI prefix
  - word wrap
  - minimap
  - sticky scroll
  - glyph margin
  - quick suggestions
  - bracket pair colorization
  - dark/light theme IDs

### `MIOMIDE`

- Adds default Monaco config under `CONF("miomide","editor",...)`
- Exposes Monaco loader/base values to the SSR page context

## Frontend changes

- Load Monaco with the no-build AMD loader path
- Create a Monaco editor instance once and switch models per tab
- Keep view state per tab where available
- Map save/compile/reload/revert actions onto Monaco-backed content
- Apply compile diagnostics to the active model with Monaco markers
- Use Monaco snippet insertion for the snippet library
- Keep VS Code-like shell behavior around the editor surface

## Notes

- This ROI uses Monaco's AMD build to stay aligned with the current no-build browser setup.
- A later ROI can move Monaco to a locally served asset path or to an ESM/build pipeline.
- A later Monaco-focused ROI should add:
  - rename/navigation providers
  - symbols/outline
  - hover help
  - formatting hooks
  - diff editor for revert/review flows
  - richer MUMPS semantic tokenization
