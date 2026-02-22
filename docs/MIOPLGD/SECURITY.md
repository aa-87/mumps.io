# Security — MIOPLGD

MIOPLGD is intentionally conservative. Template playgrounds can become a **resource and data exposure risk** if not bounded.

---

## Threat model (what can go wrong)

1) **Code execution via lambdas**  
   MIOTPL supports lambdas by allowing scalar values beginning with `$$` to call M code.
   If a user could set `{"x":"$$RUN^..."}`
   and templates invoked it, that would be a remote code execution vector.

2) **Server file exposure via partials**  
   If user templates can use partials (`{{> name}}`), they could attempt to include internal templates on disk.

3) **Denial of service**  
   Extremely large templates / contexts or intentionally expensive templates can degrade availability.

4) **HTML/script injection in UI**  
   Stored templates displayed inside the playground could break out of `<textarea>` if not bounded.

---

## Controls implemented

### 1) Lambda stripping

Before rendering, `STRIPLAMR(.CTX)` walks the entire context array and sets any scalar value beginning with `$$` to empty.

This protects `/api/render` and any other untrusted context sources.

### 2) Sandbox for ad-hoc templates

`/api/render` rejects templates that contain:

- `{{>` (partials)
- `{{<` (inheritance)

You can relax this later, but only with an allow-list.

### 3) Size limits

`/api/save` enforces basic payload size limits (200k each for template and json).

You should also enforce request body size in your HTTP server.

### 4) Textarea breakout prevention

`/api/save` rejects templates containing `</textarea` so stored data cannot break the editor UI.

---

## Recommended production additions

- Authentication (at least for save/import)
- Rate limiting by IP / user
- Render timeouts (if your server supports them)
- Output limits:
  - cap output bytes, truncate with marker
- Audit logs for template edits + favorites
- Per-tenant root global and tenant quotas
