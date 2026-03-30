# MIOMOS ROI 169 Hotfix — Boot Contract Restore and Theme Inheritance

This hotfix restores the MIOMOS boot/view contract after the drag/drop patch drifted from the last passing XP-shell baseline.

## Fixes
- Restores desktop composition to `ui-samples-settings-terminal`
- Restores XP shell drag/drop boot metadata:
  - `dragDropModel=xp-shell-semantics`
  - `dragDropDefaultOperation=move`
  - `dragDropCopyModifier=ctrl`
  - `dragDropShortcutModifier=alt`
  - `dragDropBridge=layout-preview-until-websocket-fs-bridge`
- Restores terminal profile defaults in boot JSON:
  - `fontFamily=Consolas`
  - `sizeMode=fit-container`
- Restores Explorer SSR tokens for the XP folder-view contract:
  - `data-explorer-view-option="details"`
  - `data-explorer-view-option="large-icons"`
- Adds a shell-level theming guardrail so all future MIOMOS UI additions inherit the active system font family and font size.

## Scope
This hotfix is intentionally limited to boot/view metadata, SSR contract tokens, and theme inheritance. It does not change the current multi-window terminal behavior.
