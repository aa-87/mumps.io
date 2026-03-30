# MIOMOS ROI 69 - WinXP Luna Replica Polish

## Goal

Push the Tailwind-native MIOMOS shell from an XP-inspired look to a tighter **Windows XP Luna replica** posture while preserving the existing MIOMOS DOM, Vue behavior, websocket model, VFS behavior, and xterm integration.

## Scope

This ROI is deliberately **visual-first**. No shell functionality should change.

The focus is on:

- taskbar density and Luna proportions
- Start button styling and green orb treatment
- active vs inactive task buttons, including the warm active highlight
- title bar gradients, border bevels, and control button treatment
- Start menu proportions and blue right rail
- desktop wallpaper composition toward a Bliss/Luna feel
- Explorer toolbar/address/common-tasks pane treatment
- tighter typography and spacing using a Tahoma-first shell stack

## Implementation notes

- `xterm.css` remains untouched
- MIOMOS functionality remains unchanged
- the work lives in the Tailwind-oriented foundation plus the thin chrome layer
- the `xpmsn-reference` shell mode continues to be reference-only and MIOMOS-native

## Files touched

- `public/miomos/miomos_tailwind.css`
- `public/miomos/miomos_chrome.css`
- `miomos_llm.md`

## Visual intent

The target is not merely “blue desktop chrome.” It is specifically:

- a denser XP/Luna shell rhythm
- stronger contrast between the desktop, taskbar, and windows
- more authentic green Start surface and orange active task state
- Explorer common-task and address surfaces that feel distinctly XP-era
- desktop icon spacing and label treatment that read more like a real shell and less like a modern dashboard

## Follow-on ROI direction

After this ROI, the next styling work should move into **file-type-specific surfaces** and **debugger UI chrome** so those applications inherit the same XP shell language instead of reintroducing modern mismatched panels.
