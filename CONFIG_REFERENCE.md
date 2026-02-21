# MIOTPL2 Configuration Reference

## Template I/O
| Key | Type | Default | Meaning |
|---|---:|---:|---|
| `CONF("templates","root")` | string | `"templates/"` | Root directory for template name resolution. |
| `CONF("templates","ext")` | string | `""` (your project choice) | Default extension appended when name has no dot. |
| `CONF("server","templateDir")` | string | `"templates"` | Used by precompile enumeration. |
| `CONF("templates","streamFiles")` | bool | `0` | If true, stream-read templates to avoid MAXSTRING. |
| `CONF("templates","streamFallback")` | bool | `1` | If true, fallback to streaming when file too large. |
| `CONF("templates","fileChunk")` | int | `32768` | Chunk size for streaming file reader. |
| `CONF("templates","precompileEnabled")` | bool | `0` | If true, precompile templates on `START`. |
| `CONF("templates","precompile","path",n)` | string | (none) | Optional explicit file paths to precompile. |
| `CONF("templates","maxPartialDepth")` | int | `20` | Recursion depth limit for partials/parents. |

## Output behavior
| Key | Type | Default | Meaning |
|---|---:|---:|---|
| `CONF("output","auto")` | bool | `0` | Enables `RENDERX` AUTO behavior when mode not specified. |
| `CONF("output","maxString")` | int | `900000` | Max scalar output for AUTO before requiring ref output. |
| `CONF("output","autoReturnRef")` | bool | `0` | In AUTO overflow, return ref instead of error. |
| `CONF("output","chunk")` | int | `8192` | Chunk size for ref-output writer. |

## Partials injection (optional)
| Key | Type | Meaning |
|---|---:|---|
| `CONF("templates","partialsRef")` | ref | If set, partials come from this map instead of filesystem. |
| `CTX("meta","partialsRef")` | ref | Same as above but per-render override. |

## Rendering meta (optional)
| Key | Type | Meaning |
|---|---:|---|
| `CTX("meta","templateName")` | string | Used for error stacks (root template label). |
| `CTX("meta","captureBlocks")` | bool | Used by layout/page rendering to collect blocks. |

## Cache layout
- `^MIO("TPL","CACHE",FP,"H")` — content hash
- `^MIO("TPL","CACHE",FP,"TOK",...)` — tokens
- `^MIO("TPL","CACHE",FP,"ts")` — timestamp