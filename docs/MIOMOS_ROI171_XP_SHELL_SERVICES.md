# MIOMOS ROI 171 — XP shell services and familiar system places

## Goal

Push the MIOMOS desktop closer to classic Windows XP familiarity without disturbing the passing websocket shell bus or the restored multi-window terminal behavior.

This ROI focuses on shell services users expect immediately on an XP-like desktop:

- **My Computer**
- **My Documents**
- **My Network Places**
- **Recycle Bin**
- **Create Shortcut** on desktop icons
- recycle / restore / empty workflows for removable desktop items

## What changed

### Server-authored contract

`MIOMOSST` and `MIOMOSVM` now expose shell-service metadata so the browser renders from an explicit MUMPS-owned contract:

- `shellServicesModel = xp-classic-shell-services`
- `systemPlaces = my-computer,my-documents,my-network-places,recycle-bin`
- `shortcutServicesEnabled = 1`
- `recycleBinEnabled = 1`

### Desktop entries

Added XP-style system places as server-authored desktop entries while preserving the existing curated app composition contract used by the current tests.

### Recycle Bin workflow

Custom desktop folders and desktop shortcuts now follow a safer XP-style removal flow:

- delete routes them into **Recycle Bin**
- **Restore** brings them back
- **Delete Permanently** removes only the selected recycled item
- **Empty Recycle Bin** clears all recycled desktop items

### Shortcut workflow

Desktop icon context menus now expose:

- **Create Shortcut**

Shortcuts are desktop-pinned and persist through the existing layout save path.

### Persistence

Layout persistence now also carries:

- shortcut entries
- recycle-bin contents

No new auth or terminal transport behavior was introduced in this ROI.

## Guardrails

- Keep the current terminal multi-window behavior untouched.
- Do not change auth or sign-out transport.
- Any new UI must continue inheriting the active shell font family and font size.
- Preserve the current tests that expect `desktopComposition=ui-samples-settings-terminal`.

## Next ROI candidates

- **ROI 172** — Explorer interaction parity: rename, sort, icon-size/view toggles, and selection model closer to XP Explorer.
- **ROI 173** — VFS-backed shell services: move Recycle Bin and shortcut metadata fully into per-user globals instead of layout-only persistence.
- **ROI 174** — MUMPS development-platform essence under the XP shell: routine explorer, global browser, and M developer tools with XP-consistent UX.
