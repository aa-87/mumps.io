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

## Runtime token application update

The Customize window now applies more user-editable profile fields directly as runtime CSS variables instead of relying on preset-family changes only. The active profile drives taskbar height/color, start button sizing/colors, launcher width/height/header colors, titlebar sizing/colors, sidebar width, icon size/spacing, control height, density, and wallpaper URL/fit. Saving persists the normalized profile through the globals-backed theme route, and boot-time load can reapply the saved active profile with minimal startup work.

### Server-rendered first paint

The shell no longer depends on an authenticated theme-load XHR before sign-in. `MIOOSUI` emits a small MIOTPL-rendered inline theme variable block on `#mioosRoot`, giving the login and first desktop paint a stable themed appearance. After sign-in, the Customize window and authenticated shell session may call the globals-backed theme service to load and save detailed profiles.

## ROI 60 first-paint theme flow

Active profiles saved through `MIOOSTHEME` are now resolved during `LOAD^MIOOSST` and rendered through `THEMEINL^MIOOSUI`. This keeps boot fast and avoids the visible flash/lag caused by client-side theme loading before authentication. The browser still supports `themeStudioLoadRemote()` from Customize, but automatic startup theme loading now prefers the server-rendered `desktop.activeThemeProfile` boot contract.

Uploaded wallpapers are stored as VFS files and referenced by blob URLs in the saved profile (`desktop.wallpaperPreset="custom-url"`, `desktop.wallpaperUrl=<blob-url>`). The initial renderer maps those values into `--mioos-desktop-background` so custom wallpapers can appear on first paint after sign-in.

## Server-backed boot theme and login surface

On an initial boot with no active server profile and no explicit user-local applied theme, the shell defaults to the `Glow` Theme Studio profile. If a server-rendered active profile exists, it remains authoritative and is hydrated before first paint.

Theme Studio login configuration now drives the runtime login modal. Image upload responses are parsed defensively so backend failures produce user-visible errors instead of breaking the uploader.
