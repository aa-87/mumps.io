# MIOOS Theme System

## 2026 desktop simplification update
- Customize now uses a classic display-properties-style shell.
- The active presets are tuned toward Windows XP / Windows 7 / Ubuntu-inspired families while remaining original MIOOS themes.

## Purpose
Customize replaces Theme Studio as the supported appearance editor.

## Design goals
- Token-based
- Layered and exportable
- Desktop and mobile previews
- Broad shell coverage
- Maintainable semantic naming

## Theme families
- Classic Horizon
- Orchard
- Terra
- Custom profiles

These are original families inspired by classic enterprise OS paradigms such as Windows XP, macOS, and Ubuntu without copying proprietary assets.

## Covered targets
- Wallpaper
- Shell surfaces
- Taskbar
- Start menu
- Window chrome
- Menus and dialogs
- Icon treatments
- Explorer surfaces
- Typography
- Density, radius, borders, and shadows

## Persistence
Profiles are editable and exportable. Active theme selection is preserved through the shell boot contract and client state.

## Runtime layers
- Structural shell CSS
- Semantic tokens
- Profile-specific override values
- Optional custom CSS field for advanced deployments