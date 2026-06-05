#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP="$ROOT_DIR/scripts/bootstrap/run.sh"
TMP_DIR="$ROOT_DIR/tests/.tmp/test-cli"
FAILURE_DIR="$ROOT_DIR/tests/.tmp/test-cli-failure"
WINDOWS_FAILURE_DIR="$ROOT_DIR/tests/.tmp/test-cli-windows-failure"

rm -rf "$TMP_DIR"
rm -rf "$FAILURE_DIR"
rm -rf "$WINDOWS_FAILURE_DIR"
mkdir -p "$TMP_DIR"
mkdir -p "$FAILURE_DIR"
mkdir -p "$WINDOWS_FAILURE_DIR"

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
  --target-platforms "$detected_platform" \
  --dry-run \
  --non-interactive \
  --shell-preference bash \
  --output-dir "$TMP_DIR"

test -f "$TMP_DIR/execution_summary.json"
test -f "$TMP_DIR/verification_report.json"
test -f "$TMP_DIR/human_log.txt"

grep -q '"dry_run": true' "$TMP_DIR/execution_summary.json"
grep -q '"non_interactive": true' "$TMP_DIR/execution_summary.json"
grep -q '"stages":' "$TMP_DIR/execution_summary.json"
grep -q '"checks":' "$TMP_DIR/verification_report.json"

# failure path must still output the three required artifacts
set +e
FEB_SIMULATE_ERROR_CODE="FEB-INSTALL-003" "$BOOTSTRAP" \
  --platform "$detected_platform" \
  --target-platforms "$detected_platform" \
  --dry-run \
  --non-interactive \
  --output-dir "$FAILURE_DIR"
status=$?
set -e
if [ "$status" -eq 0 ]; then
  echo "Expected non-zero status for simulated failure path."
  exit 1
fi

test -f "$FAILURE_DIR/execution_summary.json"
test -f "$FAILURE_DIR/verification_report.json"
test -f "$FAILURE_DIR/human_log.txt"
grep -q '"final_status": "failed"' "$FAILURE_DIR/execution_summary.json"

# detect-stage failure must still keep three artifacts complete
set +e
"$BOOTSTRAP" \
  --platform windows \
  --target-platforms windows \
  --dry-run \
  --non-interactive \
  --output-dir "$WINDOWS_FAILURE_DIR"
status=$?
set -e
if [ "$status" -eq 0 ]; then
  echo "Expected non-zero status for windows detect failure."
  exit 1
fi

test -f "$WINDOWS_FAILURE_DIR/execution_summary.json"
test -f "$WINDOWS_FAILURE_DIR/verification_report.json"
test -f "$WINDOWS_FAILURE_DIR/human_log.txt"
grep -q '"code":"FEB-PLATFORM-001"' "$WINDOWS_FAILURE_DIR/last_error.json"
grep -q '"name":"error_code_expected","status":"pass"' "$WINDOWS_FAILURE_DIR/verification_report.json"

echo "PASS test-cli"
