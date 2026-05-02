# MIOOS WebSocket Transport

MIOOS now treats WebSocket transport as the default communication mode for shell modules, VFS actions, backend table queries, theme persistence, Theme Studio asset uploads, and auth form actions. HTTP routes remain registered as a configurable compatibility fallback, but the boot contract advertises `boot.transport.mode = "websocket"` by default.

## Modes

- `websocket` — default. Client code uses `desktop.command` over `/ws/mioos` and only falls back to HTTP when `boot.transport.httpFallback` is enabled and a command cannot be completed over WebSocket.
- `http` — compatibility mode. Existing HTTP API routes can be used by deployments that cannot support WebSockets.

Configuration defaults:

```mumps
CONF("mioos","transport","mode")="websocket"
CONF("mioos","transport","httpFallback")=1
CONF("mioos","fs","transport")="websocket"
CONF("mioos","upload","chunkTransport")="websocket"
```

## Boot wallpaper rule

When WebSocket mode is active, first-paint wallpaper CSS must not point at `/api/mioos/fs/blob`. The boot state resolves the VFS wallpaper to a data URL so a new unauthenticated browser does not issue a pre-login blob HTTP request.

## Module rule

Modules should call `vm.command(name, payload)` or module/table helpers backed by `desktop.command`. New module code must not call `fetch()` directly unless it explicitly checks that transport mode is `http` or an HTTP fallback is enabled.

## Performance notes

The current architecture keeps one core WebSocket plus optional FS/terminal sockets. The highest-impact safe improvements are:

1. Keep command traffic on a single deduped request/response path.
2. Use batched upload chunks (`fs.upload.batch`) rather than one frame per chunk where possible.
3. Increase FS socket parallelism for uploads/downloads while preserving `maxInflightPerChannel` backpressure.
4. Avoid HTTP blob requests for previews in WebSocket mode by using `fs.read` data URLs.
5. Honor `heartbeatSeconds` from boot instead of hard-coding the ping interval.

