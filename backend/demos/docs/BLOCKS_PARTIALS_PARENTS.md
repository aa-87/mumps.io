# How blocks, partials, and parents work (MIOTPL)

## Partials (`{{>name}}`)

Resolution order:
1. `CTX("meta","partialsRef")` (authoritative)
2. `CONF("templates","partialsRef")`
3. Filesystem (`CONF("templates","root")` + name + ext)

If the call-site tag is standalone, MIOTPL captures call-site indentation and applies it to the rendered partial.

Dynamic names:
- `{{> *key}}` resolves `key` to the partial name.
- `{{> **key}}` is rejected.

## Parents + Blocks (inheritance extension)

Parent usage:

```mustache
{{<base}}
  {{$content}}child content{{/content}}
{{/base}}
```

Parent template provides defaults:

```mustache
<html>
  {{$content}}default content{{/content}}
</html>
```

Execution model:

1. Child enters `{{<base}}...{{/base}}`.
2. MIOTPL captures all `{{$block}}...{{/block}}` definitions inside that parent call.
3. MIOTPL renders the parent template.
4. When the parent hits a block placeholder:
   - use the child override if present
   - else render the parent default body

Indentation is stripped at definition and re-applied at expansion, so nested layouts behave predictably.

## captureBlocks mode (page → layout)

`RENDERPAGE(page,layout,...)` runs the page first with captureBlocks enabled:

- captured blocks are stored into `CTX("blocks",name)`
- page output is stored into `CTX("content")`
- layout is rendered, consuming `content` and block overrides
