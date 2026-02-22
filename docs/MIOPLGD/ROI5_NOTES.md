# ROI 5 — Syntax Highlighting Editors (CodeMirror)

This patch adds CodeMirror 5 (CDN) to `/plgd/playground` for:
- Mustache/Handlebars-style template highlighting
- JSON highlighting + live validation
- Shortcuts: **Ctrl/⌘+Enter** to render, **Ctrl/⌘+S** to save
- JSON Format button (pretty print)

## Install
Copy these files into your project:

- `templates/layouts/plgd_layout.html` (unchanged; included for completeness)
- `templates/pages/plgd_playground.html` (updated)
- `routines/MIOPLGD.m` and `routines/MIOPLGDT.m` (unchanged)

If your project already has these, you only need to replace:
- `templates/pages/plgd_playground.html`

## Notes
- Uses CodeMirror 5.65.16 via cdnjs.
- No build step, no bundler, keeps Tailwind CDN setup.
