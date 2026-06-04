#!/usr/bin/env bash
set -euo pipefail

FEB_LAST_ERROR_CODE=""
FEB_LAST_ERROR_MESSAGE=""
FEB_LAST_ERROR_STAGE=""
FEB_LAST_ERROR_RETRYABLE="false"
FEB_LAST_ERROR_NEXT_ACTION=""
FEB_LAST_ERROR_RAW=""
FEB_STAGE_ENTRIES=""
FEB_FALLBACK_ENTRIES=""

feb_all_error_codes() {
  cat <<'EOF'
FEB-PLATFORM-001
FEB-PLATFORM-002
FEB-PERM-001
FEB-NET-001
FEB-NET-002
FEB-PM-001
FEB-PM-002
FEB-DL-001
FEB-DL-002
FEB-INSTALL-001
FEB-INSTALL-002
FEB-INSTALL-003
FEB-INSTALL-004
FEB-CONFIG-001
FEB-VERIFY-001
FEB-IDEMP-001
EOF
}

feb_error_to_exit_code() {
  case "$1" in
    FEB-PLATFORM-001) echo 21 ;;
    FEB-PLATFORM-002) echo 22 ;;
    FEB-PERM-001) echo 23 ;;
    FEB-NET-001) echo 24 ;;
    FEB-NET-002) echo 25 ;;
    FEB-PM-001) echo 26 ;;
    FEB-PM-002) echo 27 ;;
    FEB-DL-001) echo 28 ;;
    FEB-DL-002) echo 29 ;;
    FEB-INSTALL-001) echo 30 ;;
    FEB-INSTALL-002) echo 31 ;;
    FEB-INSTALL-003) echo 32 ;;
    FEB-INSTALL-004) echo 33 ;;
    FEB-CONFIG-001) echo 34 ;;
    FEB-VERIFY-001) echo 35 ;;
    FEB-IDEMP-001) echo 36 ;;
    *) echo 1 ;;
  esac
}

feb_json_escape() {
  printf '%s' "$1" | tr '\n' ' ' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

feb_log() {
  local level="$1"
  local msg="$2"
  mkdir -p "$(dirname "$FEB_HUMAN_LOG")"
  printf '[%s] %s\n' "$level" "$msg" | tee -a "$FEB_HUMAN_LOG" >/dev/null
}

feb_add_fallback() {
  local msg="$1"
  local item
  item="{\"step\":\"$(feb_json_escape "$msg")\"}"
  if [ -n "$FEB_FALLBACK_ENTRIES" ]; then
    FEB_FALLBACK_ENTRIES="${FEB_FALLBACK_ENTRIES},${item}"
  else
    FEB_FALLBACK_ENTRIES="$item"
  fi
}

feb_record_stage() {
  local stage="$1"
  local status="$2"
  local detail="$3"
  local item
  item="{\"stage\":\"$(feb_json_escape "$stage")\",\"status\":\"$status\",\"detail\":\"$(feb_json_escape "$detail")\"}"
  if [ -n "$FEB_STAGE_ENTRIES" ]; then
    FEB_STAGE_ENTRIES="${FEB_STAGE_ENTRIES},${item}"
  else
    FEB_STAGE_ENTRIES="$item"
  fi
}

feb_set_error() {
  local code="$1"
  local message="$2"
  local stage="$3"
  local retryable="$4"
  local next_action="$5"
  local raw_error="$6"
  FEB_LAST_ERROR_CODE="$code"
  FEB_LAST_ERROR_MESSAGE="$message"
  FEB_LAST_ERROR_STAGE="$stage"
  FEB_LAST_ERROR_RETRYABLE="$retryable"
  FEB_LAST_ERROR_NEXT_ACTION="$next_action"
  FEB_LAST_ERROR_RAW="$raw_error"
}

feb_emit_structured_error() {
  [ -n "$FEB_LAST_ERROR_CODE" ] || return 0
  local json
  json=$(cat <<EOF
{"code":"$(feb_json_escape "$FEB_LAST_ERROR_CODE")","message":"$(feb_json_escape "$FEB_LAST_ERROR_MESSAGE")","stage":"$(feb_json_escape "$FEB_LAST_ERROR_STAGE")","platform":"$(feb_json_escape "$FEB_PLATFORM")","retryable":$FEB_LAST_ERROR_RETRYABLE,"next_action":"$(feb_json_escape "$FEB_LAST_ERROR_NEXT_ACTION")","raw_error":"$(feb_json_escape "$FEB_LAST_ERROR_RAW")"}
EOF
)
  printf '%s\n' "$json" | tee "$FEB_LAST_ERROR_FILE" >&2 >/dev/null
  feb_log "ERROR" "$FEB_LAST_ERROR_CODE $FEB_LAST_ERROR_MESSAGE"
}

feb_hash() {
  if command -v openssl >/dev/null 2>&1; then
    printf '%s' "$1" | openssl dgst -sha256 -r | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    LC_ALL=C printf '%s' "$1" | LC_ALL=C shasum -a 256 | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    printf '%s' "$1" | sha256sum | awk '{print $1}'
  else
    printf '%s' "$1" | cksum | awk '{print $1}'
  fi
}

feb_write_execution_summary() {
  local final_status="$1"
  local strict_mode="$2"
  local signature_input
  local signature
  local error_json="null"

  if [ -n "$FEB_LAST_ERROR_CODE" ]; then
    error_json=$(cat <<EOF
{"code":"$(feb_json_escape "$FEB_LAST_ERROR_CODE")","message":"$(feb_json_escape "$FEB_LAST_ERROR_MESSAGE")","stage":"$(feb_json_escape "$FEB_LAST_ERROR_STAGE")","platform":"$(feb_json_escape "$FEB_PLATFORM")","retryable":$FEB_LAST_ERROR_RETRYABLE,"next_action":"$(feb_json_escape "$FEB_LAST_ERROR_NEXT_ACTION")","raw_error":"$(feb_json_escape "$FEB_LAST_ERROR_RAW")"}
EOF
)
  fi

  signature_input="${FEB_PLATFORM}|${FEB_DRY_RUN}|${FEB_NON_INTERACTIVE}|${FEB_NODE_LTS_POLICY}|${FEB_INSTALL_GIT}|${FEB_INSTALL_ZSH}|${FEB_NETWORK_MODE}|${FEB_ALLOW_ELEVATION}|${FEB_IDEMPOTENT_MODE}|${FEB_STAGE_ENTRIES}|${FEB_FALLBACK_ENTRIES}|${FEB_LAST_ERROR_CODE}"
  signature="$(feb_hash "$signature_input")"

  cat >"$FEB_EXECUTION_SUMMARY" <<EOF
{
  "platform": "$(feb_json_escape "$FEB_PLATFORM")",
  "dry_run": $FEB_DRY_RUN,
  "non_interactive": $FEB_NON_INTERACTIVE,
  "strict": $strict_mode,
  "node_lts_policy": "$(feb_json_escape "$FEB_NODE_LTS_POLICY")",
  "install_git": $FEB_INSTALL_GIT,
  "install_zsh": "$(feb_json_escape "$FEB_INSTALL_ZSH")",
  "network_mode": "$(feb_json_escape "$FEB_NETWORK_MODE")",
  "allow_elevation": $FEB_ALLOW_ELEVATION,
  "idempotent_mode": "$(feb_json_escape "$FEB_IDEMPOTENT_MODE")",
  "stages": [${FEB_STAGE_ENTRIES}],
  "fallback_chain": [${FEB_FALLBACK_ENTRIES}],
  "error": $error_json,
  "final_status": "$(feb_json_escape "$final_status")",
  "idempotency_signature": "$(feb_json_escape "$signature")"
}
EOF
}

feb_detect_platform() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) echo "unsupported" ;;
  esac
}

feb_prepare_outputs() {
  mkdir -p "$FEB_OUTPUT_DIR"
  FEB_EXECUTION_SUMMARY="$FEB_OUTPUT_DIR/execution_summary.json"
  FEB_VERIFICATION_REPORT="$FEB_OUTPUT_DIR/verification_report.json"
  FEB_HUMAN_LOG="$FEB_OUTPUT_DIR/human_log.txt"
  FEB_LAST_ERROR_FILE="$FEB_OUTPUT_DIR/last_error.json"
  : >"$FEB_HUMAN_LOG"
}
