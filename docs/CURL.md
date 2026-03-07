# Curl cookbook

This document provides practical curl examples.

It is designed for day-to-day use.

It assumes the server listens on `127.0.0.1:9080`.

Adjust the host and port as needed.

---

## Health

### GET /healthz

This endpoint always returns 200.

```bash
curl -i http://127.0.0.1:9080/healthz
```

### GET /readyz

This endpoint returns 200 when the server is ready.

This endpoint returns 503 when the server is not ready.

```bash
curl -i http://127.0.0.1:9080/readyz
```

---

## Metrics

### GET /metrics

This endpoint returns metrics.

It is streamed.

It should be protected by auth.

```bash
curl -i http://127.0.0.1:9080/metrics
```

---

## Debug endpoints

These endpoints are usually protected.

They are under `/debug/`.

### GET /debug/errors

```bash
curl -i http://127.0.0.1:9080/debug/errors
```

Limit results:

```bash
curl -i "http://127.0.0.1:9080/debug/errors?limit=50"
```

Read from a sequence number:

```bash
curl -i "http://127.0.0.1:9080/debug/errors?from=1000&limit=50"
```

### GET /debug/config

This endpoint returns redacted configuration.

```bash
curl -i http://127.0.0.1:9080/debug/config
```

---

## Static files

Static files are usually mounted under `/static`.

### GET a file

```bash
curl -i http://127.0.0.1:9080/static/app.js
```

### HEAD a file

A HEAD response has no body.

```bash
curl -I http://127.0.0.1:9080/static/app.js
```

### ETag revalidation

First request:

```bash
curl -i http://127.0.0.1:9080/static/app.js
```

Second request with `If-None-Match`:

```bash
curl -i http://127.0.0.1:9080/static/app.js -H 'If-None-Match: W/"...paste..."'
```

### Range request

```bash
curl -i http://127.0.0.1:9080/static/big.bin -H 'Range: bytes=0-99'
```

### Precompressed assets

If precompressed support is enabled, try Brotli:

```bash
curl -I http://127.0.0.1:9080/static/app.js -H 'Accept-Encoding: br'
```

Try gzip:

```bash
curl -I http://127.0.0.1:9080/static/app.js -H 'Accept-Encoding: gzip'
```

---

## CORS

CORS behavior is controlled by middleware.

A preflight request looks like this:

```bash
curl -i -X OPTIONS http://127.0.0.1:9080/api/me \
  -H 'Origin: http://example.com' \
  -H 'Access-Control-Request-Method: GET'
```

---

## Auth

Auth is enforced by middleware.

Most deployments use prefix mode.

### API key auth

```bash
curl -i http://127.0.0.1:9080/api/me -H 'X-Api-Key: change-me'
```

### JWT auth

```bash
curl -i http://127.0.0.1:9080/api/me -H 'Authorization: Bearer <token>'
```

---

## Multipart upload example

Your app must define an upload route.

A common path is `POST /api/upload`.

```bash
curl -i -X POST http://127.0.0.1:9080/api/upload \
  -H 'X-Api-Key: change-me' \
  -F "file=@./big.bin" \
  -F "name=test"
```

---

## Rate limiting

If rate limiting is enabled, you may see 429 responses.

This script sends many requests quickly:

```bash
for i in $(seq 1 200); do
  curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:9080/healthz
done
```

---

## Security headers

Security headers should appear on most responses.

```bash
curl -I http://127.0.0.1:9080/healthz
```

Look for headers like:
- `X-Content-Type-Options`
- `Referrer-Policy`
- `Permissions-Policy`

If CSP is enabled, look for:
- `Content-Security-Policy`
- or `Content-Security-Policy-Report-Only`
