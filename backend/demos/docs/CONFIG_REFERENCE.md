# MIOTPL Config Reference

| Key | Default | Purpose |
|---|---:|---|
| `CONF("templates","root")` | `templates/` | Root dir for NAME-based renders |
| `CONF("templates","ext")` | `""` | Extension appended when NAME has no `.` |
| `CONF("templates","precompileEnabled")` | `0` | Enable `PRECOMPILE` on `START` |
| `CONF("templates","streamFiles")` | `0` | Stream file reads |
| `CONF("templates","streamFallback")` | `1` | Fallback to stream on size limit |
| `CONF("templates","fileChunk")` | `32768` | Streaming chunk size |
| `CONF("templates","maxPartialDepth")` | `20` | Partial/parent recursion limit |
| `CONF("templates","partialsRef")` | `""` | Optional in-memory partials/parents map |
| `CONF("templates","captureBlocks")` | `0` | Capture blocks into `CTX("blocks")` |
| `CONF("output","auto")` | `0` | Enable `RENDERX` auto output by default |
| `CONF("output","maxString")` | `900000` | Auto mode max scalar size |
| `CONF("output","autoReturnRef")` | `0` | Auto mode returns ref instead of error |
| `CONF("output","chunk")` | `8192` | REF output chunk size |
| `CONF("compat","truthiness")` | `legacy` | Reserved compat key |

## CTX meta keys

- `CTX("meta","partialsRef")`: per-render partials/parents map
- `CTX("meta","captureBlocks")`: enable block capture for a render
- `CTX("meta","templateName")`: optional name for error stack root
