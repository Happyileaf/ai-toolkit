#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP="$ROOT_DIR/scripts/bootstrap/run.sh"
TMP_DIR="$ROOT_DIR/tests/.tmp/test-cli"

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

detected_platform="$(uname -s)"
case "$detected_platform" in
  Darwin) detected_platform="macos" ;;
  Linux) detected_platform="linux" ;;
  *)
    echo "Unsupported test host: $(uname -s)"
    exit 2
    ;;
esac

"$BOOTSTRAP" \
  --platform "$detected_platform" \
  --dry-run \
  --non-interactive \
  --output-dir "$TMP_DIR"

test -f "$TMP_DIR/execution_summary.json"
test -f "$TMP_DIR/verification_report.json"
test -f "$TMP_DIR/human_log.txt"

grep -q '"dry_run": true' "$TMP_DIR/execution_summary.json"
grep -q '"non_interactive": true' "$TMP_DIR/execution_summary.json"
grep -q '"stages":' "$TMP_DIR/execution_summary.json"
grep -q '"checks":' "$TMP_DIR/verification_report.json"

echo "PASS test-cli"
