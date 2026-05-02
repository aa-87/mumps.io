# MIOOS UI Module Examples

This folder contains runnable templates for internal and user-created MIOOS UI modules.

The first example is `table`, which uses the reusable backend table component and `MIOOSTBL` query route.

Use these examples as copy-and-edit starting points. Keep module manifests data-driven and let the shell provide window chrome, theme variables, authentication, and transport.

## ROI 63A System Settings visibility

The App Catalogue is enabled by default for authenticated MIOOS sessions. Administrators can hide or disable it from the GUI through **System Settings** instead of editing source routines. Example modules should continue to declare metadata safely and rely on the catalogue/settings contract rather than assuming hard-coded launcher behavior.
