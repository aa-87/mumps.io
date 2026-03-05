# systemd install notes

## Paths you must set
- Install location (example): `/opt/mumps.io/MIO/backend`
- Routines directory: `/opt/mumps.io/MIO/backend/routines`
- Database directory: `/var/lib/mumps-io/ydb`
- Config: `/etc/mumps-io/mws.conf.json`

## Steps

1) Create user + directories
- Create service user:
  - `useradd --system --home /var/lib/mumps-io --shell /usr/sbin/nologin mio`
- Create directories:
  - `/var/lib/mumps-io/ydb`
  - `/var/log/mumps-io`
  - `/etc/mumps-io`
- Chown to `mio:mio` as needed.

2) Place files
- Copy:
  - `mumps-io.service` -> `/etc/systemd/system/mumps-io.service`
  - `mws.env.example` -> `/etc/mumps-io/mws.env` (edit values)
  - `../golden-configs/mws.conf.prod.json` -> `/etc/mumps-io/mws.conf.json` (edit as needed)

3) Validate YottaDB env
Ensure `ydb_dist`, `ydb_gbldir`, `gtmroutines` are correct for the mio user.

4) Start
- `systemctl daemon-reload`
- `systemctl enable --now mumps-io`
- `journalctl -u mumps-io -f`

5) Reverse proxy
Use Nginx/Caddy recipes in `../nginx` or `../caddy`.

## Stop / restart
- `systemctl stop mumps-io` triggers graceful shutdown via `stop^MIO`.
- `systemctl restart mumps-io` is safe for rolling updates if you keep a proxy in front.

