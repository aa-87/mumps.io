# MIOOS Migration Notes

## Migration approach
This reset is incremental, not a destabilizing big-bang rewrite.

## Phase order
1. Narrow the active product surface
2. Extend VFS metadata for real folder properties/customization
3. Rewrite explorer, transfers, taskbar, and start menu interactions
4. Replace active transitional styling load with focused reset CSS
5. Update tests and docs
6. Continue cleanup of inactive/internal legacy paths

## Key compatibility decisions
- Theme editor internals still use some `themeStudio*` method names to avoid a risky total client rewrite in one pass.
- Websocket diagnostics infrastructure remains available as backend capability even though the diagnostics window is removed from the active experience.
- Existing ROI history remains documented for continuity and regression references.

## Follow-on cleanup
- Further split oversized templates and JS files
- Fully rename remaining themeStudio client identifiers
- Remove deeper legacy admin/catalog code that is no longer reachable from the shell
- Add more granular audit export/reporting docs