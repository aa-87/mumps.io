# MIOOS UI Module Examples

This folder contains runnable templates for internal and user-created MIOOS UI modules.

The first example is `table`, which uses the reusable backend table component and `MIOOSTBL` query route.

Use these examples as copy-and-edit starting points. Keep module manifests data-driven and let the shell provide window chrome, theme variables, authentication, and transport.

## ROI 64B UI examples

`ui_elements/` now demonstrates a standalone component gallery (`componentKey=ui-elements`, `surface=mioos-surface-ui-elements`) rather than a table dataset. Use it for form controls, validation, modal/confirmation/toast feedback, file-picker metadata, and safe module composition patterns.


## Checkpoint stabilization 2026-05-05 example rule

Module examples should keep uploads and image references server-backed. Use VFS/theme asset identifiers or authenticated blob routes supplied by the shell; do not embed DataURLs in module manifests, examples, or generated table-backed modules. Large text samples should document bounded edit behavior rather than implying whole-file browser payloads.
