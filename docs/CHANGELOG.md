# Changelog (MIOTPL2)

Suggested structure — fill versions/dates as you cut releases.

## Unreleased

- Added MIOTPLB benchmark harness
- Docs: user/integration/blocks/security/testing/config/prod snippet
- Performance pass (hot loop + allocations)

## 1.0.0

- Initial stable release

# Changelog (MIOTPL2)

## 2.0.0 — 2026-02-21
- Full mustache-spec suite passing (including lambdas + inheritance extensions in this codebase’s test harness).
- Streaming compile path to avoid MAXSTRING, with cache stored under `^MIO("TPL","CACHE",FP,...)`.
- Output modes:
  - scalar output (`RENDER`)
  - reference output (`RENDERREF` / `RENDERX mode=R`)
  - optional auto mode (`RENDERX mode=AUTO`)
- Standalone trimming + indentation rules for partials / parents / blocks.
- Mustache inheritance extensions:
  - parent templates `{{< parent}} ... {{/ parent}}`
  - blocks via `{{$block}} ... {{/block}}` and `block:` section tags.
- Error reporting enhancements (line/col from token raw, stack of partial/parent calls) when enabled in your branch.
- Benchmark tooling: `MIOTPLB` benchmark report for compile/render/output size across `perf,big,min` modes.

## Notes
This changelog intentionally focuses on externally visible behavior and operational changes.