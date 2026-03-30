# MIOMOS ROI 169 hotfix — native file drop guard and theme inheritance

This hotfix corrects two regressions in the XP shell drag/drop work:

1. Browser file drops now stay inside MIOMOS handlers and no longer fall through to native browser navigation.
2. New drag/drop and Explorer shell additions inherit the active system font family and font size.

## Scope
- Restore hidden SSR drag/drop contract tokens used by `^MIOMOST`.
- Restore a planned/future Start entry so the XP roadmap remains visible in the shell.
- Add capture-phase browser dragover/drop guards.
- Add folder-window file drop staging for browser-originated files.
- Add explicit theme inheritance rules for new shell surfaces.

## Notes
- Staged browser file drops are session-local UX scaffolding for the upcoming websocket/VFS bridge.
- No auth or terminal transport behavior is changed.
