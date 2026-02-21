# MIOTPL2 Integration Guide

## Directory layout

Typical:

- `templates/pages/*.html`
- `templates/layouts/*.html`
- `templates/partials/*.html`

Configure:

```mumps
S CONF("templates","root")="templates/"
S CONF("templates","ext")=".html"
```

Then render by name:

- `D RENDER^MIOTPL2("pages/home",.CONF,.CTX,.OUT,.ERR)`

## Performance knobs

### Token cache

MIOTPL2 caches compiled tokens under `^MIO("TPL","CACHE",...)`. The cache is automatically used by `RENDER/GETTOKFP/GETTOKREF`.

### Precompile

```mumps
S CONF("templates","precompileEnabled")=1
S CONF("templates","precompile","path",1)="templates/pages/home.html"
D START^MIOTPL2(.CONF)
```

### Streaming compile for large templates

```mumps
S CONF("templates","streamFiles")=1
S CONF("templates","fileChunk")=32768
```

### Large output handling

Prefer REF output for large pages:

```mumps
N OREF,ERR
S OREF=$NA(^TMP($J,"OUT"))
D RENDERREF^MIOTPL2("pages/big",.CONF,.CTX,OREF,.ERR)
```

Or auto mode:

```mumps
N OUT,ERR,OPT
S OPT("mode")="AUTO"
D RENDERX^MIOTPL2("pages/big",.CONF,.CTX,.OUT,.ERR,.OPT)
```

## Providing partials from memory (no filesystem)

```mumps
K ^TMP($J,"partials")
S ^TMP($J,"partials","header")="<h1>{{title}}</h1>"
S CTX("meta","partialsRef")=$NA(^TMP($J,"partials"))
```

Both `{{>header}}` and `{{<parent}}` resolve from this map when set.
