# MIOMOS ROI57 placeholder removal fix 2

This patch removes the remaining placeholder app entries and the planned surfaces desktop block while preserving the existing app index contract expected by the updated MIOMOST suite.

## Changes
- Leaves `apps(12)` and `apps(13)` undefined
- Preserves `apps(14,"key")="ui-samples"`
- Removes the `Planned surfaces` section from the desktop template
- Removes remaining future/planned label strings tied to placeholder-only surfaces
