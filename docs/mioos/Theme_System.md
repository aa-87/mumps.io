# MIOOS Theme System

## 2026 desktop simplification update
- Customize now uses a richer classic display-properties-style shell with unified shell token sections.
- The active preset families are Meadow Classic, Glass Horizon, Graphite Dock, and Ember Panel. These remain original MIOOS families while spanning classic-shell, glass-shell, dock-oriented, and warm-panel desktop moods.

## Purpose
Customize replaces Theme Studio as the supported appearance editor.

## Design goals
- Token-based
- Layered and exportable
- Desktop and mobile previews
- Broad shell coverage
- Maintainable semantic naming

## Theme families
- Meadow Classic
- Glass Horizon
- Graphite Dock
- Ember Panel
- Custom profiles

These are original families inspired by classic enterprise OS paradigms such as classic Windows-like, glass Windows-like, dock-oriented desktop, and warm Linux-like without copying proprietary assets.

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
Profiles are editable and exportable. Active theme selection is preserved through globals-backed profile routes, the shell boot contract, and client-side fallback state.

## Runtime layers
- Structural shell CSS
- Semantic tokens
- Profile-specific override values
- Optional custom CSS field for advanced deployments

## Runtime contract
- Boot state now advertises `windowGrammar=7css-primary` and `controlAugment=basecoat-augment`.
- The active profile resolves one shared token set for desktop, panel/taskbar, launcher, window chrome, explorer, transfer surfaces, typography, effects, validation, and export behavior.
- Customize persists globals-backed design profiles with local fallback while the live shell applies the resolved runtime variables immediately.
