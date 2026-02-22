# MIOPLGD — MIOTPL Template Playground + Library

MIOPLGD is a **server-rendered** web app (pure M/YottaDB/GT.M) that provides:

- A modern Tailwind UI (via CDN) with lightweight animations
- A **template playground** (template + JSON context → rendered output)
- A **template library** (seeded examples + user templates) with **favorites**
- A small API surface for render/save/favorite/export/import
- Production-sane defaults (no untrusted lambdas, sandboxed ad-hoc render)

This project is designed to plug into an existing MUMPS.IO stack using:

- `MIOROUTE` for routing
- `MIOHTTP` for responses
- `MIOJSON` for JSON decoding
- `MIOTPL` for templating

---

## Folder layout

```
routines/
  MIOPLGD.m      # app routes + handlers + library storage
  MIOPLGDT.m     # smoke tests
templates/
  layouts/plgd_layout.html
  pages/plgd_home.html
  pages/plgd_playground.html
  pages/plgd_about.html
  partials/ui_nav.html
  partials/ui_footer.html
  partials/ui_tpl_card_grid.html
  partials/ui_tpl_card_list.html
docs/
  README.md
  ROI.md
  ARCHITECTURE.md
  SECURITY.md
```

---

## Install / Wire-up

1) Copy `routines/*.m` into your YottaDB/GT.M routine path.

2) Copy `templates/` into your web app working directory.

3) Register routes:

```mumps
; somewhere in your server startup:
D REG^MIOPLGD(.CONF)
```

4) Ensure your MIOTPL configuration is set (MIOPLGD calls `CONFDEF^MIOPLGD` to apply safe defaults).
If you already have a global `.CONF`, you can keep yours—defaults will only fill missing keys.

---

## Endpoints

### UI

- `GET /plgd` — Template library (grid/list views, search, filters, favorites)
  - Query params: `q`, `group`, `tag`, `sort`, `fav`, `view`, `per`, `page`
  - Pagination: stable cursor `after` / `before` (Next/Prev links use these)
  - Jump-to-page: set `page=<n>` (preserves filters/sort/view/per; resets cursor)
- `GET /plgd/playground?id=<ID>` — Playground for a selected template
- `GET /plgd/about` — Built-in docs

### API (POST)

All API calls accept `application/x-www-form-urlencoded` (recommended) and also accept JSON bodies.

- `/plgd/api/render`  
  Fields:
  - `template` (required)
  - `json` (optional, defaults `{}`)

  Response: `text/plain` rendered output.

- `/plgd/api/save`  
  Fields:
  - `id` (optional, blank means "create new")
  - `name` (required)
  - `group` (optional)
  - `tags` (optional, comma-separated)
  - `desc` (optional)
  - `fav` (0/1)
  - `template`
  - `json`

  Response: JSON `{"ok":true,"id":"..."}` (may include `"warning":"json_invalid"`).

- `/plgd/api/fav`  
  Fields:
  - `id` (required)
  - `fav` (optional; if missing, toggles)

  Response: JSON `{"ok":true,"id":"...","fav":0|1}`

- `/plgd/api/export`  
  Response: JSON `{"templates":[...]}`
  (Use for backup or sharing across environments.)

- `/plgd/api/import`  
  Body: JSON `{"templates":[...]}`
  Response: JSON `{"ok":true}`

---

## Data storage

Library templates are stored under:

- `^MIO("PLGD","tpl",ID,...)`

The library is seeded once (first request) with a handful of professional starter templates.

---

## Security notes (important)

MIOPLGD is safe-by-default for untrusted input:

- **No untrusted lambdas**: before rendering, it strips any scalar values beginning with `$$` anywhere in the decoded JSON context.
- **Sandboxed ad-hoc render**: ad-hoc templates posted to `/api/render` block:
  - partials (`{{> ...}}`)
  - inheritance (`{{< ...}}`)
- Template name/path traversal is already guarded by MIOTPL, but this app avoids letting the user choose filesystem templates directly.

If you plan to allow user templates to use partials, implement a strict allow-list (e.g., only `partials/safe_*`) and keep recursion limits low.

See `docs/SECURITY.md`.

---

## Running tests

From a working directory that contains the `templates/` folder:

```mumps
YDB> D SMOKE^MIOPLGDT
```

---

## Notes for production polish

- Add auth if you expose this on the open internet.
- Add request size limits at the HTTP layer.
- Add rate limiting per IP (especially for `/api/render`).
- Consider a per-tenant global root (multi-user mode).
- Add server-side HTML preview sandboxing (render output can be HTML).

See `docs/ROI.md` for the methodical roadmap.
