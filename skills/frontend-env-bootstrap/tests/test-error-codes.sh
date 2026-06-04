#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

count="$(
  bash -c "source '$ROOT_DIR/scripts/bootstrap/common.sh'; feb_all_error_codes | wc -l | tr -d ' '"
)"

if [ "$count" -ne 16 ]; then
  echo "Expected 16 error codes, got: $count"
  exit 1
fi

echo "PASS test-error-codes"
