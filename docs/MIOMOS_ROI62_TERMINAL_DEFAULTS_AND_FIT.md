# MIOMOS ROI62 — Terminal defaults and fit-container sizing

This ROI improves the out-of-box terminal experience without changing transport ownership.

## Goals

- make `Consolas` the default terminal font
- make terminal sizing default to `fit-container`
- send the computed terminal grid on initial `terminal.open` so the backend session starts with the same cols/rows the browser viewport expects
- slightly enlarge the default terminal window so the shell feels more production-ready

## Notes

- MUMPS remains the terminal/session authority
- xterm.js remains a renderer only
- fixed-grid sizing still exists as an explicit saved preference for users who want stable rows/cols
