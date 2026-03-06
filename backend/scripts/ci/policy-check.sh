#!/usr/bin/env bash
set -euo pipefail

# Enforce project conventions for production routines.
# By default we treat files ending in *T.m as tests and skip them.

ROOT="backend/routines"

# No ZSYSTEM in any routine (prod or test).
if grep -R --line-number -E "\bZSYSTEM\b" "$ROOT"/*.m >/dev/null; then
  echo "Policy violation: ZSYSTEM found in routines:"
  grep -R --line-number -E "\bZSYSTEM\b" "$ROOT"/*.m || true
  exit 1
fi

# No GOTO in production routines.
shopt -s nullglob
for f in "$ROOT"/*.m; do
  bn="$(basename "$f")"
  if [[ "$bn" =~ T\.m$ ]]; then
    continue
  fi
  if grep -n -E "\bGOTO\b" "$f" >/dev/null; then
    echo "Policy violation: GOTO found in production routine $bn:"
    grep -n -E "\bGOTO\b" "$f" || true
    exit 1
  fi
done

echo "Policy checks passed."
