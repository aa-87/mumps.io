# Recommended production CONF snippet

```mumps
N CONF
D START^MIOTPL(.CONF)

S CONF("templates","root")="templates/"
S CONF("templates","ext")=".html"

S CONF("templates","maxPartialDepth")=20

S CONF("output","chunk")=8192
S CONF("output","auto")=0
S CONF("output","maxString")=900000
S CONF("output","autoReturnRef")=0
```

Notes:
- Prefer `RENDERREF` for large pages.
- Treat lambdas as trusted-only.
