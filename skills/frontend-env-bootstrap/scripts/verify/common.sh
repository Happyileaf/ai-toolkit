#!/usr/bin/env bash
set -euo pipefail

VERIFY_CHECKS=""
VERIFY_FAIL_COUNT=0

verify_all_error_codes() {
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

verify_json_escape() {
  printf '%s' "$1" | tr '\n' ' ' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

verify_add_check() {
  local name="$1"
  local status="$2"
  local detail="$3"
  local item
  item="{\"name\":\"$(verify_json_escape "$name")\",\"status\":\"$status\",\"detail\":\"$(verify_json_escape "$detail")\"}"
  if [ -n "$VERIFY_CHECKS" ]; then
    VERIFY_CHECKS="${VERIFY_CHECKS},${item}"
  else
    VERIFY_CHECKS="$item"
  fi
  if [ "$status" = "fail" ]; then
    VERIFY_FAIL_COUNT=$((VERIFY_FAIL_COUNT + 1))
  fi
}

verify_cmd_version() {
  local name="$1"
  local cmd="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    local value
    value="$("$cmd" --version 2>/dev/null | head -n 1 || true)"
    if [ -z "$value" ]; then
      value="$("$cmd" -v 2>/dev/null | head -n 1 || true)"
    fi
    verify_add_check "$name" "pass" "${value:-detected}"
  else
    verify_add_check "$name" "fail" "command not found: $cmd"
  fi
}

verify_nvm() {
  if command -v nvm >/dev/null 2>&1; then
    verify_add_check "nvm" "pass" "nvm detected in current shell."
    return
  fi
  if [ -n "${NVM_DIR:-}" ] && [ -s "${NVM_DIR}/nvm.sh" ]; then
    verify_add_check "nvm" "pass" "nvm detected via NVM_DIR."
    return
  fi
  if [ -s "${HOME}/.nvm/nvm.sh" ]; then
    verify_add_check "nvm" "pass" "nvm script exists at ~/.nvm/nvm.sh."
    return
  fi
  verify_add_check "nvm" "fail" "nvm not found."
}

verify_node_policy() {
  local policy="$1"
  if ! command -v node >/dev/null 2>&1; then
    verify_add_check "node_policy" "fail" "node not found; cannot validate policy."
    return
  fi
  local node_version
  node_version="$(node -v 2>/dev/null | sed 's/^v//')"

  case "$policy" in
    latest_lts)
      if [ "$(node -p "process.release && process.release.lts ? 'yes' : 'no'" 2>/dev/null || echo no)" = "yes" ]; then
        verify_add_check "node_policy" "pass" "node ${node_version} reports LTS."
      else
        verify_add_check "node_policy" "warn" "node ${node_version} does not report LTS."
      fi
      ;;
    fixed:*)
      local fixed_version
      fixed_version="${policy#fixed:}"
      if [ "$node_version" = "$fixed_version" ]; then
        verify_add_check "node_policy" "pass" "node version matches fixed policy ${fixed_version}."
      else
        verify_add_check "node_policy" "fail" "node version ${node_version} != fixed policy ${fixed_version}."
      fi
      ;;
    *)
      verify_add_check "node_policy" "fail" "invalid node_lts_policy: ${policy}."
      ;;
  esac
}

verify_path_duplicates() {
  local delimiter=":"
  [ "${VERIFY_PLATFORM:-}" = "windows" ] && delimiter=";"
  local duplicate_count=0
  duplicate_count="$(printf '%s' "${PATH}" | tr "$delimiter" '\n' | awk 'seen[$0]++ == 1 {count++} END {print count+0}')"
  if [ "$duplicate_count" -eq 0 ]; then
    verify_add_check "path_duplicates" "pass" "PATH has no duplicate entries."
  else
    verify_add_check "path_duplicates" "warn" "PATH has ${duplicate_count} duplicate entries."
  fi
}

verify_known_error_code() {
  local code="$1"
  verify_all_error_codes | grep -Fx "$code" >/dev/null 2>&1
}

verify_error_code_file() {
  local error_file="$1"
  local expected_code="$2"

  if [ ! -f "$error_file" ]; then
    verify_add_check "error_file_exists" "fail" "error file not found: $error_file"
    return
  fi

  verify_add_check "error_file_exists" "pass" "error file detected: $error_file"
  local code
  code="$(sed -n 's/.*"code"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$error_file" | head -n 1)"
  if [ -z "$code" ]; then
    verify_add_check "error_code_parse" "fail" "failed to parse error code from $error_file"
    return
  fi

  verify_add_check "error_code_parse" "pass" "parsed error code: $code"
  if verify_known_error_code "$code"; then
    verify_add_check "error_code_known" "pass" "$code is part of 16-code catalog."
  else
    verify_add_check "error_code_known" "fail" "$code is outside 16-code catalog."
  fi

  if [ -n "$expected_code" ]; then
    if [ "$code" = "$expected_code" ]; then
      verify_add_check "error_code_expected" "pass" "expected code matched: $expected_code"
    else
      verify_add_check "error_code_expected" "fail" "expected $expected_code but got $code"
    fi
  fi
}

verify_write_report() {
  local platform="$1"
  local output_file="$2"
  local fail_count="$3"
  local strict="$4"
  local overall="PASS"
  if [ "$fail_count" -gt 0 ]; then
    overall="FAIL"
  fi
  cat >"$output_file" <<EOF
{
  "platform": "$(verify_json_escape "$platform")",
  "overall": "$overall",
  "strict": $strict,
  "failed_checks": $fail_count,
  "checks": [${VERIFY_CHECKS}]
}
EOF
}
