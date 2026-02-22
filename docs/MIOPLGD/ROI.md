# MIOPLGD Roadmap — ROI Milestones

This roadmap is intentionally methodical. Each ROI builds on the previous, keeps the app shippable, and limits risk.

> Legend: **ROI** = highest impact per unit effort for a template playground product.

---

## ROI 0 — Baseline foundation (ship fast)

**Goal:** A stable skeleton that can render a page and respond to API calls.

- [x] Route registration (`REG^MIOPLGD`)
- [x] `CONFDEF` safe defaults for MIOTPL
- [x] Layout + nav + footer (Tailwind UI)
- [x] Smoke test (`SMOKE^MIOPLGDT`)

**Exit criteria**
- `/plgd` loads
- `/plgd/about` loads
- smoke test passes

---

## ROI 1 — Template Library (seeded, browsable)

**Goal:** Provide immediate value with high-quality starter templates.

- [x] One-time seed to `^MIO("PLGD",...)`
- [x] Library page with grid/list view
- [x] Favorites toggle (server persisted)

**Exit criteria**
- Templates display with group/desc
- Favoriting works and persists

---

## ROI 2 — Playground core (render loop)

**Goal:** Turn library templates into a fast iteration tool.

- [x] Playground UI (template textarea, JSON textarea, output)
- [x] `/api/render` (form + JSON body support)
- [x] Lambda stripping safety
- [x] Sandbox: block partials + inheritance in ad-hoc templates

**Exit criteria**
- Click “Render” gives expected output
- Invalid JSON returns error

---

## ROI 3 — CRUD (save + update + export/import)

**Goal:** Make the library user-owned.

- [x] `/api/save` to create/update templates
- [x] `/api/export` and `/api/import` for portability

**Exit criteria**
- Save creates new ID and refresh persists
- Export/import round-trip works for small libraries

---

## ROI 4 — Findability + organization

**Goal:** Users can find templates quickly as the library grows.

- [x] Server-side search (`q`) across name/desc/group/tags
- [x] Filters: `group`, `tag`, `fav`
- [x] Sorting: `sort=name|updated|created|group|fav`
- [x] Tags stored on records + normalized tag index (`^MIO("PLGD","idx","tag",...)`)
- [x] Facets with counts (groups + tags)
- [x] “Recently updated” panel (top 6)

**Exit criteria**
- Search + filter feel instant for hundreds of templates (and remain acceptable for 1000+)
- No UI regressions: `/plgd`, `/plgd/playground`, `/plgd/about` still render

---

## ROI 4.5 — Pagination + stable cursor

**Goal:** Keep the library fast and navigable when it grows large.

- [x] Server-side pagination: `per` (page size)
- [x] Stable cursor navigation: `after` / `before` tokens
- [x] Metadata-only listing path (`GETMETA`) to avoid loading large template bodies during listing

**Exit criteria**
- Next/Prev reliably navigate even while templates are being edited (stable ordering)
- Listing remains responsive with large templates and large libraries


## ROI 4.6 — Jump to page + first/last

**Goal:** Support fast navigation in large libraries without losing filter/sort context.

- [x] Page indicator (page / total pages) even when using cursor navigation
- [x] Jump-to-page form (`page=<n>`) that preserves current filters/sort/view/per
- [x] First/Last links that reset cursor while preserving filters

**Exit criteria**
- You can type a page number and jump directly (without losing your search/filter/sort)
- Page indicator stays correct when clicking Prev/Next

## ROI 5 — Safety + policy gates (production hardening)

**Goal:** Safe to expose to more users / teams.

- [ ] Per-request limits: body size caps, render time caps
- [ ] Allow-list partials for user templates (optional)
- [ ] Render policy: max output length + cut-off marker
- [ ] Audit log: `^MIO("PLGD","audit",...)`

**Exit criteria**
- Render cannot exceed bounded resources

---

## ROI 6 — Performance (token caching + streaming)

**Goal:** Keep rendering fast at scale.

- [ ] Cache compiled tokens for library templates (store FP or TOKREF in `^MIO`)
- [ ] Use `RENDERX^MIOTPL` (AUTO mode) for large outputs
- [ ] Optional precompile step during startup for favorites / recent templates

**Exit criteria**
- Re-render latency stays low with large templates

---

## ROI 7 — UX polish (professional product feel)

**Goal:** “This feels like a real product.”

- [ ] Keyboard shortcuts: Ctrl/Cmd+Enter to render, Ctrl/Cmd+S to save
- [ ] Diff view (last saved vs current)
- [ ] Snippet insertion (“sections”, “lists”, “inverted”, etc.)
- [ ] Non-blocking error panel (parse errors, render errors)

**Exit criteria**
- New user can succeed in < 60 seconds

---

## ROI 8 — Collaboration + sharing (if you want to monetize)

**Goal:** Multiply value via sharing and teams.

- [ ] Multi-user mode (tenant key root)
- [ ] Shareable links (signed IDs or read-only exports)
- [ ] Role-based access (viewer/editor/admin)
- [ ] Paid tier gates (favorites limit, export/import, team libraries)

**Exit criteria**
- Teams can reuse templates across apps safely
