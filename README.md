# MIOTPL2 User Guide

MIOTPL2 is a Mustache-first template engine for MUMPS (YottaDB/GT.M) used by MUMPS.IO. It supports core Mustache, plus a small set of practical extensions:

- Mustache inheritance (`{{<parent}} ... {{/parent}}`) and blocks (`{{$block}} ... {{/block}}`)
- Dynamic partial/parent names (`{{> *key}}`, `{{< *key}}`) (single deref only; `**` is rejected)
- Variable lambdas (`{{name}}` where `name="$$LBL^ROU"`), and higher-order section lambdas (`{{#lambda}}...{{/lambda}}`)

## Template syntax

### Variables

- Escaped variable: `{{name}}` (HTML-escapes `& < > " '`)
- Unescaped variable: `{{& name}}` or `{{{name}}}` (triple braces only with default delimiters)

Missing variables render as empty string.

### Sections

- Normal section: `{{#items}}...{{/items}}`
- Inverted section: `{{^items}}...{{/items}}`

Truthiness in the current engine is **legacy**:
- Empty string, `0`, `"0"`, `"false"`, `"null"` are false
- Lists/objects are true only if they have at least one subscripted element

### Partials

- Include partial: `{{>header}}`
- Dynamic partial: `{{> *partialNameKey}}`

Partials can be loaded from filesystem (default) or from a supplied partials map.

### Delimiter changes

`{{= <% %> =}}` changes delimiters for the remainder of the template.

### Comments

`{{! this is ignored }}`

### Inheritance + Blocks (extension)

- Parent include: `{{<base}} ... {{/base}}`
- Define block content: `{{$block}} ... {{/block}}`
- Provide block placeholder in parent with default content: `{{$block}} default {{/block}}`

## Public entry points (common)

### Startup

```mumps
N CONF
D START^MIOTPL2(.CONF)
```

### Render a file template (by name)

```mumps
N CONF,CTX,OUT,ERR
D START^MIOTPL2(.CONF)

S CONF("templates","root")="templates/"
S CONF("templates","ext")=".html"

S CTX("name")="Ahmed"
D RENDER^MIOTPL2("pages/home",.CONF,.CTX,.OUT,.ERR)
I $D(ERR) ZWRITE ERR Q
W OUT
```

### Render an inline template string

```mumps
N CONF,CTX,OUT,ERR
D START^MIOTPL2(.CONF)
S CTX("name")="Ahmed"

D RENDERANY^MIOTPL2("Hello {{name}}!",.CONF,.CTX,.OUT,.ERR)
I $D(ERR) ZWRITE ERR Q
W OUT
```

### Render a page into a layout (content + blocks)

```mumps
N CONF,CTX,OUT,ERR
D START^MIOTPL2(.CONF)

D RENDERPAGE^MIOTPL2("pages/about","layouts/main",.CONF,.CTX,.OUT,.ERR)
I $D(ERR) ZWRITE ERR Q
W OUT
```
