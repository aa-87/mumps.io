This patch removes the last rendered placeholder/future token sources that can trip MIOMOST T003.

Changes:
- Removed authored placeholder apps `automation` and `integrations` from `APPS^MIOMOSST`
- Kept `ui-samples` at index 14 to preserve the test contract
- Changed terminal subtitle from `future admin console` to `admin console`
- Removed the `Planned surfaces` block from `miomos_desktop.html`
- Removed raw template logic and copy that still contained the `future` token
