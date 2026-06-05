#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

FEB_PLATFORM="auto"
FEB_TARGET_PLATFORMS="auto"
FEB_DRY_RUN="false"
FEB_NON_INTERACTIVE="false"
FEB_STRICT="false"
FEB_NODE_LTS_POLICY="latest_lts"
FEB_INSTALL_GIT="true"
FEB_INSTALL_ZSH="auto"
FEB_SHELL_PREFERENCE="bash"
FEB_NETWORK_MODE="public"
FEB_ALLOW_ELEVATION="false"
FEB_IDEMPOTENT_MODE="strict"
FEB_PROXY_URL="${FEB_PROXY_URL:-}"
FEB_OUTPUT_DIR="$SKILL_ROOT/out"

usage() {
  cat <<'EOF'
Usage: run.sh [options]
  --platform <auto|linux|macos|windows>
  --target-platforms <auto|linux|macos|windows|linux,macos,...>
  --dry-run
  --non-interactive
  --strict
  --node-lts-policy <latest_lts|fixed:x.y.z>
  --install-git <true|false>
  --install-zsh <auto|force|skip>
  --shell-preference <powershell|bash|zsh>
  --network-mode <public|proxy>
  --allow-elevation <true|false>
  --idempotent-mode <strict|best_effort>
  --output-dir <path>
  --help
EOF
}

normalize_bool() {
  case "$1" in
    true|false) printf '%s' "$1" ;;
    *) return 1 ;;
  esac
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --platform) FEB_PLATFORM="$2"; shift 2 ;;
    --target-platforms) FEB_TARGET_PLATFORMS="$2"; shift 2 ;;
    --dry-run) FEB_DRY_RUN="true"; shift ;;
    --non-interactive) FEB_NON_INTERACTIVE="true"; shift ;;
    --strict) FEB_STRICT="true"; shift ;;
    --node-lts-policy) FEB_NODE_LTS_POLICY="$2"; shift 2 ;;
    --install-git) FEB_INSTALL_GIT="$2"; shift 2 ;;
    --install-zsh) FEB_INSTALL_ZSH="$2"; shift 2 ;;
    --shell-preference) FEB_SHELL_PREFERENCE="$2"; shift 2 ;;
    --network-mode) FEB_NETWORK_MODE="$2"; shift 2 ;;
    --allow-elevation) FEB_ALLOW_ELEVATION="$2"; shift 2 ;;
    --idempotent-mode) FEB_IDEMPOTENT_MODE="$2"; shift 2 ;;
    --output-dir) FEB_OUTPUT_DIR="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! normalize_bool "$FEB_INSTALL_GIT" >/dev/null 2>&1 || ! normalize_bool "$FEB_ALLOW_ELEVATION" >/dev/null 2>&1; then
  printf 'install-git and allow-elevation must be true|false\n' >&2
  exit 2
fi

case "$FEB_INSTALL_ZSH" in
  auto|force|skip) ;;
  *)
    printf 'install-zsh must be auto|force|skip\n' >&2
    exit 2
    ;;
esac

case "$FEB_SHELL_PREFERENCE" in
  powershell|bash|zsh) ;;
  *)
    printf 'shell-preference must be powershell|bash|zsh\n' >&2
    exit 2
    ;;
esac

case "$FEB_NETWORK_MODE" in
  public|proxy) ;;
  *)
    printf 'network-mode must be public|proxy\n' >&2
    exit 2
    ;;
esac

case "$FEB_IDEMPOTENT_MODE" in
  strict|best_effort) ;;
  *)
    printf 'idempotent-mode must be strict|best_effort\n' >&2
    exit 2
    ;;
esac

if ! feb_validate_node_lts_policy "$FEB_NODE_LTS_POLICY"; then
  printf 'node-lts-policy must be latest_lts or fixed:x.y.z\n' >&2
  exit 2
fi

if [ "$FEB_TARGET_PLATFORMS" = "auto" ]; then
  FEB_TARGET_PLATFORMS="$FEB_PLATFORM"
fi

if [ "$FEB_PLATFORM" = "auto" ]; then
  FEB_PLATFORM="$(printf '%s' "$FEB_TARGET_PLATFORMS" | cut -d',' -f1)"
fi

if [ "$FEB_PLATFORM" = "auto" ]; then
  FEB_PLATFORM="$(feb_detect_platform)"
fi

if [ "$FEB_PLATFORM" = "unsupported" ]; then
  FEB_OUTPUT_DIR="$SKILL_ROOT/out"
fi
feb_prepare_outputs

FAILED=0
STOP_PIPELINE=0

run_stage() {
  local stage="$1"
  local fn_name="$2"
  if [ "$STOP_PIPELINE" -eq 1 ]; then
    feb_record_stage "$stage" "skipped" "Skipped because previous stage failed in strict dependency path."
    return 0
  fi

  if "$fn_name"; then
    feb_record_stage "$stage" "ok" "Stage completed."
  else
    FAILED=1
    feb_emit_structured_error
    feb_record_stage "$stage" "failed" "${FEB_LAST_ERROR_CODE}: ${FEB_LAST_ERROR_MESSAGE}"
    STOP_PIPELINE=1
    return 1
  fi
}

if ! printf '%s\n' "linux macos windows" | grep -w "$FEB_PLATFORM" >/dev/null 2>&1; then
  feb_set_error "FEB-PLATFORM-001" "Unsupported platform selection." "detect" "false" "Choose linux|macos|windows|auto." "$FEB_PLATFORM"
  feb_emit_structured_error
  feb_record_stage "detect" "failed" "${FEB_LAST_ERROR_CODE}: ${FEB_LAST_ERROR_MESSAGE}"
  FAILED=1
  STOP_PIPELINE=1
fi

if [ "$STOP_PIPELINE" -eq 0 ] && [ "$FEB_PLATFORM" = "windows" ]; then
  feb_add_fallback "shell entry is Unix; use scripts/bootstrap/run.ps1 for Windows execution."
  feb_set_error "FEB-PLATFORM-001" "Windows execution requires PowerShell entrypoint." "detect" "false" "Run scripts/bootstrap/run.ps1 on Windows." ""
  feb_emit_structured_error
  feb_record_stage "detect" "failed" "${FEB_LAST_ERROR_CODE}: ${FEB_LAST_ERROR_MESSAGE}"
  FAILED=1
  STOP_PIPELINE=1
fi

if [ "$STOP_PIPELINE" -eq 0 ]; then
  ADAPTER="$SCRIPT_DIR/$FEB_PLATFORM/adapter.sh"
  # shellcheck disable=SC1090
  source "$ADAPTER"
  run_stage "detect" feb_platform_detect || true
  run_stage "preflight" feb_platform_preflight || true
  run_stage "bootstrap_pm" feb_platform_bootstrap_pm || true
  run_stage "install_core" feb_platform_install_core || true
  run_stage "configure_shell" feb_platform_configure_shell || true
fi

VERIFY_SCRIPT="$SKILL_ROOT/scripts/verify/run.sh"
VERIFY_ARGS=(
  --platform "$FEB_PLATFORM"
  --node-lts-policy "$FEB_NODE_LTS_POLICY"
  --output-dir "$FEB_OUTPUT_DIR"
)
[ "$FEB_NON_INTERACTIVE" = "true" ] && VERIFY_ARGS+=(--non-interactive)
[ "$FEB_STRICT" = "true" ] && VERIFY_ARGS+=(--strict)

if [ -f "$FEB_LAST_ERROR_FILE" ]; then
  VERIFY_ARGS+=(--error-file "$FEB_LAST_ERROR_FILE")
fi

if [ "$STOP_PIPELINE" -eq 1 ]; then
  VERIFY_ARGS+=(--skip-tool-checks)
fi

if [ -n "$FEB_LAST_ERROR_CODE" ]; then
  VERIFY_ARGS+=(--expect-error-code "$FEB_LAST_ERROR_CODE")
fi

if "$VERIFY_SCRIPT" "${VERIFY_ARGS[@]}"; then
  feb_record_stage "verify" "ok" "verification_report.json generated."
else
  FAILED=1
  if [ -z "$FEB_LAST_ERROR_CODE" ]; then
    feb_set_error "FEB-VERIFY-001" "Verification failed." "verify" "true" "Inspect verification_report.json and human_log.txt." ""
    feb_emit_structured_error

    # For FEB-VERIFY-001 we rerun verify in error-recognition mode so the report
    # still contains deterministic error_code_known/error_code_expected assertions.
    VERIFY_RECOVERY_ARGS=(
      --platform "$FEB_PLATFORM"
      --node-lts-policy "$FEB_NODE_LTS_POLICY"
      --output-dir "$FEB_OUTPUT_DIR"
      --non-interactive
      --skip-tool-checks
      --error-file "$FEB_LAST_ERROR_FILE"
      --expect-error-code "$FEB_LAST_ERROR_CODE"
    )
    if ! "$VERIFY_SCRIPT" "${VERIFY_RECOVERY_ARGS[@]}"; then
      feb_write_failure_verification_report_placeholder "verify recovery pass failed while asserting FEB-VERIFY-001 recognition."
    fi
  fi
  feb_record_stage "verify" "failed" "${FEB_LAST_ERROR_CODE:-FEB-VERIFY-001}: ${FEB_LAST_ERROR_MESSAGE:-Verification failed.}"
fi

feb_ensure_verification_report_exists

if [ "$FAILED" -eq 1 ] && [ "$FEB_IDEMPOTENT_MODE" = "strict" ] && [ "$FEB_DRY_RUN" = "true" ] && [ -z "$FEB_LAST_ERROR_CODE" ]; then
  feb_set_error "FEB-IDEMP-001" "Strict idempotent mode failed but no explicit error code was produced." "finalize" "false" "Inspect execution_summary and verify logs." ""
  feb_emit_structured_error
fi

if [ "$FAILED" -eq 0 ]; then
  feb_record_stage "finalize" "ok" "All requested stages completed."
  feb_write_execution_summary "success" "$FEB_STRICT"
  feb_log "INFO" "bootstrap finished successfully."
  exit 0
fi

feb_record_stage "finalize" "failed" "One or more stages failed."
feb_write_execution_summary "failed" "$FEB_STRICT"
exit "$(feb_error_to_exit_code "${FEB_LAST_ERROR_CODE:-FEB-VERIFY-001}")"
