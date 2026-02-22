# Architecture — MIOPLGD

MIOPLGD uses a simple pattern:

1) **Server-rendered UI** pages with MIOTPL (`RENDERPAGE^MIOTPL`)
2) A small set of **JSON/form APIs** for interaction (render/save/fav/export/import)
3) Library persistence in one global (`^MIO("PLGD",...)`)

---

## Request flow

### UI pages

- Handler builds a render context (`TCTX`)
- Calls `START^MIOTPL(.CONF)`
- Calls `RENDERPAGE^MIOTPL(page, layout, ...)`

`RENDERPAGE` captures blocks from the page template and then renders the layout with:

- `CTX("content")` — rendered page output
- `CTX("blocks",...)` — captured blocks like `{{$title}}...{{/title}}`

### Playground rendering

- Browser posts the user template (string) and JSON context
- Server:
  - parses request body
  - decodes JSON to an M array (`DECODE^MIOJSON`)
  - strips any scalar values starting with `$$` (lambda safety)
  - blocks `{{> ...}}` and `{{< ...}}` in ad-hoc templates by default
  - calls `RENDERANY^MIOTPL(templateString, ...)`
- Returns rendered output as `text/plain`

---

## Global schema

```
^MIO("PLGD","meta","seeded")=1
^MIO("PLGD","meta","nextId")=<int>

^MIO("PLGD","tpl",ID,"name")=<string>
^MIO("PLGD","tpl",ID,"group")=<string>
^MIO("PLGD","tpl",ID,"desc")=<string>
^MIO("PLGD","tpl",ID,"fav")=0|1
^MIO("PLGD","tpl",ID,"createdH")=$H
^MIO("PLGD","tpl",ID,"updatedH")=$H
^MIO("PLGD","tpl",ID,"tpl",N)=<line>
^MIO("PLGD","tpl",ID,"json",N)=<line>
```

---

## Extending safely

### Allowing partials in user templates (optional)

If you want users to use partials:

- Keep `CONF("templates","maxPartialDepth")` small (e.g., 10–20)
- Implement an allow-list:
  - only allow `partials/safe_*` names
  - reject any `{{> ...}}` that is not in the allow-list
- Consider using a separate template root for user content to avoid leaking app UI templates

### Streaming output

For very large outputs, consider:

- `RENDERX^MIOTPL(...,.OPT)` with mode `AUTO`
- strict `CONF("output","maxString")`
- return refs when appropriate

---

## Known assumptions

MIOPLGD assumes your stack already provides:

- `MIOROUTE` route registration + dispatching
- `MIOHTTP` response helpers
- `MIOJSON` JSON decoding

If any of these differ in your project, adapt the few helper calls in `MIOPLGD.m`.
