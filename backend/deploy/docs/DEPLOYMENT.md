# MUMPS.IO Web Server (MIO) Deployment Pack

This folder provides production-ready deployment artifacts for the MUMPS.IO (MIO) web server on YottaDB/GT.M.

Goals:
- Deterministic runtime behavior (no reliance on shelling out from M code).
- Run behind a reverse proxy for TLS and HTTP/2.
- Provide systemd + reverse-proxy + Kubernetes recipes.
- Provide "golden" configuration examples.

## Runtime entrypoint

The server entrypoint is the `MIO` routine:
- Start: `yottadb -run MIO` (runs label `start` which loads config, registers routes, compiles router, then starts MIOD)
- Stop:  `yottadb -run stop^MIO` (requests shutdown via globals)

Config file path is read from the environment variable `MWS_CONF`.
If not set, it defaults to `./config/mws.conf.json`.

## Recommended architecture

- **Reverse proxy (Nginx/Caddy)** terminates TLS and forwards HTTP/1.1 to the MIO listener (default port 9080).
- MIO provides:
  - `/healthz` (always 200)
  - `/readyz` (503 when not ready)

## Files

- `deploy/systemd/`:
  - `mumps-io.service` — systemd unit
  - `mws.env.example` — environment variable template
  - `README.md` — install notes
- `deploy/nginx/`:
  - `mumps-io.nginx.conf` — proxy recipe (TLS termination assumed)
- `deploy/caddy/`:
  - `Caddyfile` — proxy recipe (TLS optional)
- `deploy/k8s/`:
  - Kubernetes manifests (Deployment, Service, Ingress, HPA optional)
- `deploy/golden-configs/`:
  - Example `mws.conf.json` profiles (prod/dev/k8s)

## Security / operational notes

- Keep MIO bound to a private network if possible (reverse proxy on same host/pod).
- If running behind a proxy, only trust `X-Forwarded-For` if your proxy is trusted.
- For production, keep the CSP preset at `balanced` unless you have nonce-enabled templates.
- Access logs and metrics are stored in globals for performance/determinism.

## Quick systemd install (summary)

1. Create runtime user (example):
   - `useradd --system --home /var/lib/mumps-io --shell /usr/sbin/nologin mio`

2. Place files:
   - unit: `/etc/systemd/system/mumps-io.service`
   - env:  `/etc/mumps-io/mws.env`
   - config: `/etc/mumps-io/mws.conf.json`

3. Enable + start:
   - `systemctl daemon-reload`
   - `systemctl enable --now mumps-io`

See `deploy/systemd/README.md` for details.

