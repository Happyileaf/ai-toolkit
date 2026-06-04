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

usage() {
  cat <<'EOF'
Usage: run.sh [options]
  --platform <auto|linux|macos|windows>
  --format <json|text|both>
  --strict
  --non-interactive
  --node-lts-policy <latest_lts|fixed:x.y.z>
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
    printf 'Use scripts/verify/run.ps1 on Windows.\n' >&2
    exit 2
    ;;
  *)
    printf 'Unsupported platform for verify: %s\n' "$VERIFY_PLATFORM" >&2
    exit 2
    ;;
esac

verify_platform_checks
verify_write_report "$VERIFY_PLATFORM" "$VERIFY_REPORT_FILE" "$VERIFY_FAIL_COUNT" "$VERIFY_STRICT"

if [ "$VERIFY_FORMAT" = "text" ] || [ "$VERIFY_FORMAT" = "both" ]; then
  {
    printf '[VERIFY] platform=%s strict=%s non_interactive=%s\n' "$VERIFY_PLATFORM" "$VERIFY_STRICT" "$VERIFY_NON_INTERACTIVE"
    printf '[VERIFY] failed_checks=%s\n' "$VERIFY_FAIL_COUNT"
  } >>"$VERIFY_HUMAN_LOG"
fi

if [ "$VERIFY_STRICT" = "true" ] && [ "$VERIFY_FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
