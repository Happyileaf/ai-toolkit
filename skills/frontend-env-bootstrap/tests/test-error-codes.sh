#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP="$ROOT_DIR/scripts/bootstrap/run.sh"
TMP_DIR="$ROOT_DIR/tests/.tmp/test-error-codes"

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

catalog_count="$(
  bash -c "source '$ROOT_DIR/scripts/bootstrap/common.sh'; feb_all_error_codes | wc -l | tr -d ' '"
)"
if [ "$catalog_count" -ne 16 ]; then
  echo "Expected 16 error codes, got: $catalog_count"
  exit 1
fi

missing_codes=(
  FEB-PERM-001
  FEB-NET-001
  FEB-PM-002
  FEB-DL-002
  FEB-INSTALL-001
  FEB-INSTALL-002
  FEB-INSTALL-004
  FEB-IDEMP-001
)

for code in "${missing_codes[@]}"; do
  run_dir="$TMP_DIR/$code"
  mkdir -p "$run_dir"
  set +e
  FEB_SIMULATE_ERROR_CODE="$code" "$BOOTSTRAP" \
    --platform "$detected_platform" \
    --dry-run \
    --non-interactive \
    --output-dir "$run_dir"
  status=$?
  set -e
  if [ "$status" -eq 0 ]; then
    echo "Expected non-zero exit status for simulated code: $code"
    exit 1
  fi

  test -f "$run_dir/execution_summary.json"
  test -f "$run_dir/verification_report.json"
  test -f "$run_dir/human_log.txt"
  test -f "$run_dir/last_error.json"

  grep -q "\"code\":\"$code\"" "$run_dir/last_error.json"
  grep -q "\"name\":\"error_code_known\",\"status\":\"pass\"" "$run_dir/verification_report.json"
  grep -q "\"name\":\"error_code_expected\",\"status\":\"pass\"" "$run_dir/verification_report.json"
done

echo "PASS test-error-codes"
