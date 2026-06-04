#!/usr/bin/env bash
set -euo pipefail

VERIFY_CHECKS=""
VERIFY_FAIL_COUNT=0

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
  if [ "$status" != "pass" ]; then
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
  local duplicate_count=0
  duplicate_count="$(printf '%s' "${PATH}" | tr ':' '\n' | awk 'seen[$0]++ == 1 {count++} END {print count+0}')"
  if [ "$duplicate_count" -eq 0 ]; then
    verify_add_check "path_duplicates" "pass" "PATH has no duplicate entries."
  else
    verify_add_check "path_duplicates" "warn" "PATH has ${duplicate_count} duplicate entries."
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
