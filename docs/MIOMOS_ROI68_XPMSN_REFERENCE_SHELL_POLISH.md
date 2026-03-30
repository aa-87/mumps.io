# MIOMOS ROI 68 — XPMSN reference shell polish

## Goal

Use the `xpmsn` project only as a **visual reference target** for MIOMOS shell surfaces while keeping MIOMOS architecture, SSR, websocket ownership, VFS, and terminal behavior unchanged.

## Scope

This ROI is intentionally presentation-focused. It does not change:

- websocket command ownership
- VFS behavior
- auth/session logic
- terminal transport
- MIOTPL page structure beyond small non-functional shell-reference tokens

## What changed

### Shell reference contract

The desktop surface now carries an explicit shell-reference token so the visual target is testable and documented:

- `data-shell-reference="xpmsn-reference"` in SSR output
- boot contract value `desktop.shellReference="xpmsn-reference-only"`
- boot contract value `desktop.visualTarget="xp-replica-development-shell"`

This makes the design direction explicit without coupling MIOMOS to third-party code.

### Layout tuning

The Tailwind-oriented foundation was refined to get closer to an XP replica shell feel:

- tighter desktop icon grid
- shorter taskbar rhythm
- more compact title bars
- narrower quick launch controls
- stronger Start menu proportions

### Chrome tuning

The chrome layer now targets a more literal XP shell silhouette:

- greener rounded Start button
- more cobalt taskbar and title bars
- compact XP-like window controls
- dual-pane Start menu emphasis
- lighter explorer panes and dialog chrome
- icon-selection and hover states closer to an XP desktop

## Guardrails

- `xterm.css` remains untouched
- no functionality is encoded into the new shell-reference token
- MIOMOS remains the owner of desktop state and routing
- this ROI should be safe to iterate visually without reopening the websocket/VFS repair cycle

## Next recommended ROI

Continue with a second XP replica wave focused on the **Explorer and file surfaces**:

- tighter folder-task pane language
- details/list header fidelity
- file-type badges and previews
- recycle-bin and system-folder visual parity
- MUMPS development assets styled as first-class shell citizens
