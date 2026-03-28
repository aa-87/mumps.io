# MIOMOS Internal README (ongoing)

## ROI 17 focus
Behavior hardening and production reliability.

## Architecture reminder
- MUMPS owns policy and authoritative state.
- Vue renders the boot/view payload and posts commands.
- Shell reliability behavior is policy-driven by `boot.desktop.policy`.

## New boot contract fields
Under `desktop.policy`:
- `heartbeatMs`
- `reconnectBaseMs`
- `reconnectMaxMs`
- `staleSocketMs`
- `commandMaxInflight`
- `persistMenuState`
- `persistActiveWindow`
- `persistLayout`
- `showReliabilityPanel`

## Thin-client additions
- local UI-state persistence
- command dedupe / in-flight guard
- reconnect and stale-socket tracking
- dismissible shell alerts

## Implementation note
This ROI intentionally avoids changing the command route shape or the websocket event contract so it can sit on top of the passing ROI 16 baseline with lower regression risk.
