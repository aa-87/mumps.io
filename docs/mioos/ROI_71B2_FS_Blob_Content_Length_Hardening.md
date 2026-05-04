# ROI 71B2 — VFS blob content-length hardening

## Problem

Saved wallpaper/background images can be loaded by the desktop as authenticated VFS blob URLs such as:

```text
/api/mioos/fs/blob?id=fs-24
```

A regression allowed the blob endpoint to set `Content-Length` from the VFS entry metadata even when the actual stored payload chunks were shorter. Browsers correctly reject that response with `ERR_CONTENT_LENGTH_MISMATCH` because the server advertises more bytes than it sends.

## Fix

`FSBLOB^MIOOSAPI` now repairs and uses the actual stored VFS payload size before writing any HTTP response headers. This keeps `200`, `206`, `304`, `416`, and `HEAD` responses consistent with the bytes that can actually be streamed.

`SENDVFS^MIOOSAPI` now streams by walking the stored VFS data chunks in order and calculating byte intersections with the requested range. This avoids depending on stale or incompatible chunk-size metadata and prevents short writes for legacy/stale files.

`MIOOSFS` now exposes:

- `DATASIZE(ID)` — sums the actual `$ZLENGTH` of stored VFS data chunks.
- `REPAIRSIZE(ID)` — repairs file metadata size to match the actual stored chunk payload and returns the repaired size.

## Acceptance

- `/api/mioos/fs/blob?id=<file>` must not emit a `Content-Length` larger than the available stored payload.
- `HEAD` and `GET` must agree on actual payload size.
- Range requests must parse against the actual payload size.
- Existing uploaded wallpapers with stale metadata should self-heal on the first blob request.
- If a file is truly corrupt or empty, the endpoint may fail to display the image, but it must not produce `ERR_CONTENT_LENGTH_MISMATCH`.

## Validation

Run:

```mumps
D ^MIOOST
```

The ROI 71B2 regression check is `T076`, which creates a VFS file, intentionally corrupts the metadata size, and verifies `REPAIRSIZE^MIOOSFS` restores the actual stored payload size used by `FSBLOB^MIOOSAPI`.
