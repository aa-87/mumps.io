# ROI 72C — Start Menu Component Rewrite

## Goal

Dedicate one ROI entirely to rewriting the Start Menu component into a modern, mobile-friendly launcher without changing unrelated shell, table, patient, or terminal behavior.

## Source of truth

The Start Menu must continue to source links from the existing MIOOS runtime state rather than hard-coded frontend-only menus:

- `launcherEntries`
- `boot.modules`
- core shell tools such as Folder Explorer, My Computer, Documents, Theme Studio, Terminal, Transfers, App Catalogue, Control Panel, Diagnostics, Security Center, and Debug Center
- `localeOptions`
- `shellThemeOptions()`
- Desktop VFS files and folders from `desktopEntries`

## Implementation

The visual component remains `start-menu-popup` in `public/mioos/app/mioos_shell_ui.js`. ROI 72C replaces the old classic/popup markup with one modern launcher surface using:

- a concise header
- search with result count
- grouped sections
- compact item rows
- short source badges such as App, Module, File, Folder, Theme, and Lang
- mobile bottom-sheet layout

Supporting metadata helpers were added to `public/mioos/app/mioos_core.js`:

- `startMenuSelectItem()`
- `startMenuGroupIcon()`
- `startMenuSourceBadge()`
- `startMenuItemMeta()`

## Preserved behavior

- Search filters all groups.
- Keyboard navigation still supports Arrow Up/Down, Home, End, Enter, and Escape.
- Locale entries still call `changeLocale()`.
- Theme entries still call `applyShellTheme()`.
- Desktop VFS entries still open through `openDesktopEntry()`.
- Module entries still open through `openModuleEntry()`.
- App entries still open through `openApp()`.

## Regression tests

`T073^MIOOST` adds static regression coverage for the modern component, group rendering, source badges, hover/focus selection, preserved language/theme/folder explorer entries, and the ROI CSS/docs markers.

## Validation

```mumps
D ^MIOOST
```

```bash
node --check public/mioos/app/mioos_core.js
node --check public/mioos/app/mioos_shell_ui.js
```
