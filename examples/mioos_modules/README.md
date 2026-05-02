# MIOOS UI Module Examples

This folder contains runnable templates for internal and user-created MIOOS UI modules.

The first example is `table`, which uses the reusable backend table component and `MIOOSTBL` query route.

Use these examples as copy-and-edit starting points. Keep module manifests data-driven and let the shell provide window chrome, theme variables, authentication, and transport.

## ROI 63A System Settings visibility

The App Catalogue is enabled by default for authenticated MIOOS sessions. Administrators can hide or disable it from the GUI through **System Settings** instead of editing source routines. Example modules should continue to declare metadata safely and rely on the catalogue/settings contract rather than assuming hard-coded launcher behavior.

## ROI 64A UI modules rewrite track

The examples track is being rewritten around production-ready reusable components. The first foundation is the searchable App Catalogue / UI Modules hub and `mioos-advanced-table-v2`, a standalone table component intended for both internal shell modules and user-created modules.
