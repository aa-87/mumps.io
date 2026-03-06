#!/usr/bin/env bash
set -euo pipefail

# Workspace layout assumption:
# - backend/routines contains *.m routines and tests
# We copy routines into the active ydb_dir routine directory to keep gtmroutines simple.

if [[ -z "${ydb_dir:-}" ]]; then
  export ydb_dir="$PWD/.yottadb"
fi

# Source YottaDB env (Docker images typically provide this path)
if [[ -f /opt/yottadb/current/ydb_env_set ]]; then
  # shellcheck disable=SC1091
  source /opt/yottadb/current/ydb_env_set
elif [[ -f /usr/local/etc/ydb_env_set ]]; then
  # shellcheck disable=SC1091
  source /usr/local/etc/ydb_env_set
else
  echo "ERROR: ydb_env_set not found. Is YottaDB installed in this runner/container?"
  exit 2
fi

mkdir -p "$ydb_dir/r"
cp -a backend/routines/*.m "$ydb_dir/r/"

# Run tests (quiet on success). Fail CI if we see FAIL/ERR or YDB errors.
OUT="$(mktemp)"
set +e
yottadb -direct <<'EOF' >"$OUT" 2>&1
ZL "MIOTESTS.m"
D ^MIOTESTS
HALT
EOF
RC=$?
set -e

cat "$OUT"

# If yottadb itself returned non-zero, fail.
if [[ "$RC" -ne 0 ]]; then
  echo "CI: yottadb returned non-zero exit code: $RC"
  exit "$RC"
fi

# Fail on known failure markers.
if grep -E "^(FAIL:|ERR |%YDB-E-|%GTM-E-)" -n "$OUT" >/dev/null; then
  echo "CI: detected test failures or runtime errors."
  exit 1
fi

echo "CI: tests passed."
