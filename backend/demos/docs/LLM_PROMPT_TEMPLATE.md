# Copy/Paste LLM Prompt Template (MIOTPL apps)

Paste the content below into your LLM of choice. It forces a consistent output structure and avoids common MIOTPL integration mistakes.

---

You are generating a **MUMPS/YottaDB** web application that uses **MIOTPL** for templating.

## Constraints
- Use **MIOTPL** public entry points exactly as documented.
- Assume routing is provided by `MIOROUTE` and HTTP responses by `MIOHTTP` (do not reimplement them).
- Assume a JSON parser exists (call it, don’t reimplement).
- Templates are stored under `templates/`.
- Do not execute untrusted code. Do not allow user data to set lambda values (`$$...`).

## Deliverables
Output the full contents of these files (no placeholders):

- `routines/<APP>.m`
- `routines/<APPTEST>.m`
- `templates/layouts/app_layout.html`
- `templates/pages/home.html`
- `templates/pages/<any extra pages>.html`
- `templates/partials/<any partials>.html`
- `docs/README.md`

## App requirements
- Provide a homepage that demonstrates:
  - variables, lists, inverted sections
  - partials
  - parent/layout + blocks
- Provide one advanced page that demonstrates:
  - dynamic partial name (`{{> *key}}`) OR a safe server-provided lambda
- Provide a single helper that renders pages with `RENDERPAGE^MIOTPL`.
- Include a smoke test that renders `home.html` and asserts key substrings.

## Configuration
Use this production-safe default CONF snippet:

```
S CONF("templates","root")="templates/"
S CONF("templates","ext")=".html"
S CONF("templates","precompileEnabled")=0
S CONF("templates","streamFiles")=0
S CONF("templates","streamFallback")=1
S CONF("templates","maxPartialDepth")=20
S CONF("output","auto")=1
S CONF("output","maxString")=900000
S CONF("output","autoReturnRef")=1
D START^MIOTPL(.CONF)
```

Now generate the application.
