#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP="$ROOT_DIR/scripts/bootstrap/run.sh"
TMP_BASE="$ROOT_DIR/tests/.tmp/idempotency"

rm -rf "$TMP_BASE"
mkdir -p "$TMP_BASE"

detected_platform="$(uname -s)"
case "$detected_platform" in
  Darwin) detected_platform="macos" ;;
  Linux) detected_platform="linux" ;;
  *)
    echo "Unsupported test host: $(uname -s)"
    exit 2
    ;;
esac

signatures=""

for i in 1 2 3; do
  run_dir="$TMP_BASE/run-$i"
  mkdir -p "$run_dir"
  "$BOOTSTRAP" \
    --platform "$detected_platform" \
    --target-platforms "$detected_platform" \
    --dry-run \
    --non-interactive \
    --shell-preference bash \
    --output-dir "$run_dir"
  sig="$(sed -n 's/.*"idempotency_signature": "\(.*\)".*/\1/p' "$run_dir/execution_summary.json")"
  if [ -z "$sig" ]; then
    echo "Missing idempotency_signature in run $i"
    exit 1
  fi
  signatures="${signatures}${sig}"$'\n'
done

unique_count="$(printf '%s' "$signatures" | sort | uniq | wc -l | tr -d ' ')"
if [ "$unique_count" -ne 1 ]; then
  echo "Expected 1 unique idempotency_signature across 3 runs, got $unique_count"
  printf '%s' "$signatures"
  exit 1
fi

echo "PASS test-idempotency"
