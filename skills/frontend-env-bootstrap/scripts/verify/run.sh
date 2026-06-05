#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

VERIFY_PLATFORM="auto"
VERIFY_FORMAT="both"
VERIFY_STRICT="false"
VERIFY_NON_INTERACTIVE="false"
VERIFY_NODE_LTS_POLICY="latest_lts"
VERIFY_OUTPUT_DIR="$SKILL_ROOT/out"
VERIFY_ERROR_FILE=""
VERIFY_EXPECT_ERROR_CODE=""
VERIFY_SKIP_TOOL_CHECKS="false"

usage() {
  cat <<'EOF'
Usage: run.sh [options]
  --platform <auto|linux|macos|windows>
  --format <json|text|both>
  --strict
  --non-interactive
  --node-lts-policy <latest_lts|fixed:x.y.z>
  --error-file <path-to-last_error.json>
  --expect-error-code <FEB-...>
  --skip-tool-checks
  --output-dir <path>
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --platform) VERIFY_PLATFORM="$2"; shift 2 ;;
    --format) VERIFY_FORMAT="$2"; shift 2 ;;
    --strict) VERIFY_STRICT="true"; shift ;;
    --non-interactive) VERIFY_NON_INTERACTIVE="true"; shift ;;
    --node-lts-policy) VERIFY_NODE_LTS_POLICY="$2"; shift 2 ;;
    --error-file) VERIFY_ERROR_FILE="$2"; shift 2 ;;
    --expect-error-code) VERIFY_EXPECT_ERROR_CODE="$2"; shift 2 ;;
    --skip-tool-checks) VERIFY_SKIP_TOOL_CHECKS="true"; shift ;;
    --output-dir) VERIFY_OUTPUT_DIR="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ "$VERIFY_PLATFORM" = "auto" ]; then
  case "$(uname -s)" in
    Darwin) VERIFY_PLATFORM="macos" ;;
    Linux) VERIFY_PLATFORM="linux" ;;
    *) VERIFY_PLATFORM="unsupported" ;;
  esac
fi

mkdir -p "$VERIFY_OUTPUT_DIR"
VERIFY_REPORT_FILE="$VERIFY_OUTPUT_DIR/verification_report.json"
VERIFY_HUMAN_LOG="$VERIFY_OUTPUT_DIR/human_log.txt"
touch "$VERIFY_HUMAN_LOG"

if [ "$VERIFY_SKIP_TOOL_CHECKS" != "true" ]; then
  case "$VERIFY_PLATFORM" in
    linux)
      # shellcheck disable=SC1091
      source "$SCRIPT_DIR/linux.sh"
      ;;
    macos)
      # shellcheck disable=SC1091
      source "$SCRIPT_DIR/macos.sh"
      ;;
    windows)
      verify_add_check "platform_dispatch" "fail" "Use scripts/verify/run.ps1 for Windows full tool checks."
      ;;
    *)
      verify_add_check "platform_dispatch" "fail" "Unsupported platform for verify: $VERIFY_PLATFORM"
      ;;
  esac

  if declare -F verify_platform_checks >/dev/null 2>&1; then
    verify_platform_checks
  fi
else
  verify_add_check "tool_checks_skipped" "pass" "Tool checks skipped due to bootstrap failure path."
fi

if [ -n "$VERIFY_ERROR_FILE" ]; then
  verify_error_code_file "$VERIFY_ERROR_FILE" "$VERIFY_EXPECT_ERROR_CODE"
elif [ -n "$VERIFY_EXPECT_ERROR_CODE" ]; then
  verify_add_check "error_code_expected" "fail" "Expected error code was provided but error file is missing."
fi

verify_write_report "$VERIFY_PLATFORM" "$VERIFY_REPORT_FILE" "$VERIFY_FAIL_COUNT" "$VERIFY_STRICT"

if [ "$VERIFY_FORMAT" = "text" ] || [ "$VERIFY_FORMAT" = "both" ]; then
  {
    printf '[VERIFY] platform=%s strict=%s non_interactive=%s skip_tool_checks=%s\n' "$VERIFY_PLATFORM" "$VERIFY_STRICT" "$VERIFY_NON_INTERACTIVE" "$VERIFY_SKIP_TOOL_CHECKS"
    printf '[VERIFY] failed_checks=%s\n' "$VERIFY_FAIL_COUNT"
  } >>"$VERIFY_HUMAN_LOG"
fi

if [ "$VERIFY_STRICT" = "true" ] && [ "$VERIFY_FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
