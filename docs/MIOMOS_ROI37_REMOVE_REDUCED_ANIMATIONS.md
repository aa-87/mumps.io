# MIOMOS ROI37: Remove Reduced Animations Option

This patch removes the `Reduced` value from the **Animations** setting while leaving the separate **Motion Profile** setting unchanged.

## Changes
- Default `animations` changed from `reduced` to `standard`.
- Settings catalog now exposes only `Off`, `Standard`, and `Full`.
- Legacy persisted preference value `reduced` is normalized to `standard` at load time.
- `data-animations="reduced"` CSS branches were removed.

## Non-goals
- No changes to `motionProfile` values such as `reduced`, `standard`, `polished`, or `silky`.
- No changes to terminal runtime behavior or websocket flows.
