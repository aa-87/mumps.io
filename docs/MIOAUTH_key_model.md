# MIO Web Server Authentication Key Model

## Purpose

This document explains how the updated MIO authentication layer handles JWT signing and verification, with special attention to the difference between:

- **HS256**: shared-secret authentication
- **RS256**: private/public-key authentication

It also explains what changed in the updated implementation, what did **not** change, and how to configure each model in a production-ready way.

---

## Important clarification

The **updated HS256 client-secret support does not use private/public keys**.

HS256 is a **symmetric** algorithm. That means:

- the signer and verifier use the **same secret**
- there is **no public key**
- there is **no private key**

The private/public-key model in the current MIO authentication stack is the **RS256** path.

So the updated authentication system supports **two different key models**:

1. **HS256** → shared secret
2. **RS256** → private key to sign, public key to verify

---

## Where the key logic lives

The main logic is in `MIOAUTHJWT`.

High-level flow:

1. `MIOAUTH` decides whether a route requires authentication.
2. `MIOAUTH` calls `VERIFY^MIOAUTHJWT` for JWT validation.
3. `MIOAUTHJWT`:
   - reads the `Authorization` header
   - parses the JWT
   - decodes header and payload
   - checks claims like `exp`, `nbf`, `iss`, and `aud`
   - verifies the signature based on `alg`
4. If verification succeeds, claims are copied into `CTX("auth",...)`
5. `MIOAUTHZ` can then enforce route authorization rules such as roles

This design keeps the key-resolution logic isolated in one place and avoids changing the rest of the auth stack.

---

## Supported JWT algorithm models

### 1) HS256

HS256 uses HMAC-SHA256.

In this model:

- the token issuer signs with a shared secret
- the MIO server verifies with that same shared secret
- anyone who can verify can also generate valid signatures if they know the secret

This is fast and simple, but it requires careful secret handling.

### 2) RS256

RS256 uses RSA with SHA-256.

In this model:

- the issuer signs with a **private key**
- the MIO server verifies with a **public key**
- the verifier does not need the private key

This is useful when you want a stronger trust boundary between the token issuer and the web server.

---

## What changed in the updated implementation

Before the update, HS256 verification only supported one global secret:

```mumps
CONF("auth","jwt","hmacSecret")
```

That meant all HS256 tokens had to verify with the same secret.

After the update, HS256 still supports that original global secret first, but now it can also resolve a secret in additional ways.

### New HS256 secret resolution order

The verifier now checks secrets in this order:

1. `CONF("auth","jwt","hmacSecret")`
2. `CONF("auth","jwt","hmacSecretByKid",kid)`
3. `CONF("auth","jwt","hmacSecretByClient",clientClaimValue)`
4. `CONF("auth","jwt","hs256Resolve")="TAG^ROUTINE"`

This preserves backward compatibility because the old global secret path still has highest precedence.

---

## HS256 does not use public/private keys

The most important point is this:

**The new client-secret support is still HS256.**

That means the system is doing **secret lookup**, not public-key lookup.

The new code is resolving which **shared secret** to use for verification. It is not loading a private key or public key.

### Why this matters

If a client signs a JWT with HS256, the verifier must know the exact same secret used by that client.

The update allows that secret to vary by:

- JWT header `kid`
- payload claim such as `client_id`
- a pure-MUMPS resolver callback

That is useful for multi-tenant or per-client licensing/authentication models.

But it is still symmetric cryptography.

---

## How RS256 uses private/public keys in this design

The current code supports RS256 through this configuration entry:

```mumps
CONF("auth","jwt","rs256Verify")="TAG^ROUTINE"
```

When a JWT header contains:

```json
{"alg":"RS256"}
```

`MIOAUTHJWT` calls the configured verifier callback.

### What the callback receives

The verifier callback is called with:

- `DATA` → the `header.payload` string that was signed
- `SIGBIN` → the decoded binary signature
- `CONF`
- `CTX`
- `HOBJ` → decoded JWT header
- `POBJ` → decoded JWT payload
- `ERR`

The callback returns success or failure.

### What this means architecturally

The core MIO auth layer does **not** hard-code RSA parsing inside `MIOAUTHJWT`.
Instead, it delegates public-key verification to a callback.

That gives you flexibility to:

- keep RSA logic in a dedicated routine
- select keys by `kid`
- rotate public keys
- verify tokens issued by another service
- integrate with external key storage or a local key registry

### Private/public-key responsibilities

In a normal RS256 deployment:

- the **issuer** keeps the **private key**
- the **MIO server** holds or loads the **public key**
- the MIO server never needs the private key to verify

That is the real private/public-key path in the current design.

---

## Detailed HS256 secret resolution behavior

The updated `GETHSEC` logic works like this.

### 1) Global shared secret

```mumps
CONF("auth","jwt","hmacSecret")
```

If this exists and is non-empty, it is used immediately.

This preserves all existing tests and behavior.

### 2) Secret by `kid`

If the JWT header contains a `kid`, the verifier checks:

```mumps
CONF("auth","jwt","hmacSecretByKid",kid)
```

This lets you assign a different HS256 secret per client key id.

### 3) Secret by client claim

If `kid` does not resolve a secret, the verifier checks a payload claim.

Default claim name:

```mumps
client_id
```

Configurable claim name:

```mumps
CONF("auth","jwt","clientIdClaim")
```

Secret lookup:

```mumps
CONF("auth","jwt","hmacSecretByClient",claimValue)
```

This is useful when the client identity is embedded in the payload instead of the JWT header.

### 4) Resolver callback

If no static map resolves the secret, the verifier can call:

```mumps
CONF("auth","jwt","hs256Resolve")="TAG^ROUTINE"
```

This allows dynamic secret lookup in pure MUMPS.

Example uses:

- tenant license table
- client registry global
- per-install activation store
- offline license mapping

---

## Why the updated design is production-friendly

### Backward compatible

The original `hmacSecret` path still has highest priority.
That means existing installs and existing tests continue to work.

### Fast lookup path

The common resolution steps are direct global or local array lookups:

- one direct global secret lookup
- one `kid` lookup
- one claim-name lookup
- one client map lookup

Those are all O(1)-style associative lookups in M terms.

### Resolver is last

The dynamic callback is only used when static config did not resolve the secret.
That avoids extra work in the common case.

### No body buffering needed

JWT verification happens from request headers and decoded token text.
It does not require the request body.
That is friendly to a streaming request pipeline.

### Clean failure modes

The update includes explicit error cases for:

- missing secret
- bad resolver entry
- resolver exception
- bad signature
- unsupported algorithm
- RS256 missing verifier
- RS256 bad verifier entry
- RS256 verifier exception

That helps observability and predictable operations.

---

## Performance notes

The updated implementation is efficient for the JWT verification stage.

### HS256 path

The HS256 path does:

1. parse token once
2. decode header and payload once
3. check claims once
4. resolve secret through a short precedence chain
5. compute one HMAC-SHA256
6. compare one binary signature

The new logic adds only a few keyed lookups before HMAC execution.
The expensive part remains the HMAC itself, not the secret-selection logic.

### RS256 path

The RS256 path delegates the cryptographic verification to a callback.
That lets you optimize RSA verification separately from the auth pipeline.

For example, you can:

- cache parsed public keys
- cache key lookup by `kid`
- keep public keys in memory globals
- isolate heavier crypto code from routing/auth logic

---

## Streaming and MAXSTRING safety notes

The updated JWT changes are small and header-focused.

### What is safe here

- JWT extraction comes from the `Authorization` header
- secret selection uses short strings and small config lookups
- no request-body scanning is introduced
- no new file IO is introduced
- no shell calls are introduced

### What still matters operationally

JWTs themselves should remain reasonably sized.
Very large tokens can still increase memory pressure because JWT processing necessarily manipulates the token as a string.

In normal production usage, JWTs are small enough that this is not a concern.

For best results:

- keep JWT claim sets compact
- avoid embedding large objects in tokens
- prefer identifiers over bulky metadata
- keep role claims concise

---

## Example: HS256 per-client model

This is the updated symmetric model.

### Configuration

```mumps
SET CONF("auth","jwt","clientIdClaim")="client_id"
SET CONF("auth","jwt","hmacSecretByClient","acme")="acme-secret"
SET CONF("auth","jwt","hmacSecretByClient","beta")="beta-secret"
```

### Token payload example

```json
{
  "sub": "user-123",
  "client_id": "acme",
  "exp": 1770000000
}
```

### Verification result

If the token header says `alg=HS256`, the verifier:

1. sees there is no global `hmacSecret`
2. checks `kid`
3. checks `client_id`
4. loads `acme-secret`
5. verifies the HMAC signature

This is **not** private/public-key verification.
It is shared-secret verification selected by client identity.

---

## Example: HS256 by `kid`

### Configuration

```mumps
SET CONF("auth","jwt","hmacSecretByKid","client-a")="secret-a"
SET CONF("auth","jwt","hmacSecretByKid","client-b")="secret-b"
```

### Token header example

```json
{
  "alg": "HS256",
  "typ": "JWT",
  "kid": "client-a"
}
```

The verifier uses `kid` to select the shared secret.

Again, this is still HS256, not public-key crypto.

---

## Example: RS256 private/public-key model

### Configuration

```mumps
SET CONF("auth","jwt","rs256Verify")="VERIFYRSA^MYJWTKEYS"
```

### Token header example

```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "issuer-key-2026-01"
}
```

### Callback responsibilities

Your callback would typically:

1. read `kid` from `HOBJ`
2. load the matching public key
3. verify `SIGBIN` against `DATA`
4. return `1` or `0`

In this model:

- the token issuer uses the private key
- the MIO server verifies with the public key

This is the actual private/public-key flow.

---

## Recommended deployment choices

### Use HS256 when

- the issuer and verifier are under the same trust boundary
- you want a lightweight setup
- you are doing per-client shared-secret validation
- you want simple offline deployments

### Use RS256 when

- the issuer should keep the signing key private and separate
- the verifier should only hold public keys
- you want stronger separation of signing and verifying roles
- you expect external issuers or key rotation workflows

---

## Security guidance

### For HS256

- treat every HS256 secret like a signing key
- do not expose shared secrets to untrusted clients unless the design explicitly requires client-side signing
- rotate per-client secrets when possible
- prefer `kid` or client-id resolution to avoid one global secret for everyone
- keep the resolver pure and deterministic

### For RS256

- keep private keys outside the MIO verifier
- only store or load public keys in the web server verification layer
- select public keys by `kid`
- cache public keys for performance
- plan for key rotation and overlap windows

---

## Test coverage summary

The updated code now has separate client-secret tests in addition to the original auth suite.

The added tests cover:

- `kid` secret lookup
- `client_id` secret lookup
- custom claim-name lookup
- precedence of original `hmacSecret`
- dynamic resolver success and failure
- bad resolver entry
- resolver exception
- fallback order between `kid` and client claim
- short-circuit behavior when an earlier lookup succeeds
- bad signature on client-secret path
- auth context population
- RBAC behavior after successful client-secret verification

This helps protect both backward compatibility and the new HS256 secret-resolution model.

---

## Final summary

The updated MIO authentication system supports both symmetric and asymmetric JWT verification, but they are different paths.

### HS256 path

- uses **shared secrets**
- does **not** use public/private keys
- now supports global, per-`kid`, per-client, and callback-based secret lookup

### RS256 path

- uses **private/public keys**
- issuer signs with a private key
- MIO verifies with a public key through the `rs256Verify` callback

So if the question is:

**“Does the updated authentication use private/public keys?”**

The accurate answer is:

- **Yes for RS256**
- **No for the new HS256 client-secret support**

The new update improves how MIO finds the correct **shared secret** for HS256 tokens. It does not convert HS256 into a public-key system.

