#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BOOTSTRAP_SH="${ROOT_DIR}/scripts/bootstrap.sh"
BOOTSTRAP_PS1="${ROOT_DIR}/scripts/bootstrap.ps1"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PASS_COUNT=0

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local label="$3"
  if ! printf '%s' "$haystack" | grep -Fq "$needle"; then
    echo "[FAIL] ${label} -> missing '${needle}'"
    echo "$haystack"
    exit 1
  fi
}

run_case() {
  local label="$1"
  local expected_exit="$2"
  shift 2

  local output_file="${TMP_DIR}/${label}.json"
  local error_file="${TMP_DIR}/${label}.stderr"

  set +e
  "$@" >"$output_file" 2>"$error_file"
  local rc=$?
  set -e

  if [ "$rc" -ne "$expected_exit" ]; then
    echo "[FAIL] ${label} -> expected exit ${expected_exit}, got ${rc}"
    echo "stdout:"
    cat "$output_file"
    echo "stderr:"
    cat "$error_file"
    exit 1
  fi

  cat "$output_file"
}

echo "Running acceptance matrix: M2/L2/M3/M4/L3/L4/W1"

# M2: macOS half-new machine idempotence
M2_HOME="${TMP_DIR}/m2-home"
M2_STATE="${TMP_DIR}/m2-state.txt"
mkdir -p "$M2_HOME"

m2_first="$(run_case "M2-first" 0 env \
  HOME="$M2_HOME" \
  FDB_SIM_PLATFORM="macos" \
  FDB_SIM_DISTRIBUTION="macos-13" \
  FDB_SIM_NETWORK="online" \
  FDB_SIM_SUDO="available" \
  FDB_SIM_INITIAL_COMPONENTS="zsh,git" \
  "$BOOTSTRAP_SH" --simulate --state-file "$M2_STATE")"
assert_contains "$m2_first" '"result":"success"' "M2 first success"
assert_contains "$m2_first" '"installed_components":[' "M2 first install list"

m2_second="$(run_case "M2-second" 0 env \
  HOME="$M2_HOME" \
  FDB_SIM_PLATFORM="macos" \
  FDB_SIM_DISTRIBUTION="macos-13" \
  FDB_SIM_NETWORK="online" \
  FDB_SIM_SUDO="available" \
  FDB_SIM_INITIAL_COMPONENTS="zsh,git" \
  "$BOOTSTRAP_SH" --simulate --state-file "$M2_STATE")"
assert_contains "$m2_second" '"result":"success"' "M2 second success"
assert_contains "$m2_second" '"installed_components":[]' "M2 second no new install"

nvm_line_count="$(grep -F -c 'export NVM_DIR="$HOME/.nvm"' "${M2_HOME}/.zshrc")"
if [ "$nvm_line_count" -ne 1 ]; then
  echo "[FAIL] M2 idempotence -> expected one NVM_DIR line, got ${nvm_line_count}"
  cat "${M2_HOME}/.zshrc"
  exit 1
fi
PASS_COUNT=$((PASS_COUNT + 1))

# L2: Linux half-new machine idempotence
L2_HOME="${TMP_DIR}/l2-home"
L2_STATE="${TMP_DIR}/l2-state.txt"
mkdir -p "$L2_HOME"

l2_first="$(run_case "L2-first" 0 env \
  HOME="$L2_HOME" \
  FDB_SIM_PLATFORM="linux" \
  FDB_SIM_DISTRIBUTION="ubuntu" \
  FDB_SIM_NETWORK="online" \
  FDB_SIM_SUDO="available" \
  FDB_SIM_INITIAL_COMPONENTS="git" \
  "$BOOTSTRAP_SH" --simulate --state-file "$L2_STATE")"
assert_contains "$l2_first" '"result":"success"' "L2 first success"

l2_second="$(run_case "L2-second" 0 env \
  HOME="$L2_HOME" \
  FDB_SIM_PLATFORM="linux" \
  FDB_SIM_DISTRIBUTION="ubuntu" \
  FDB_SIM_NETWORK="online" \
  FDB_SIM_SUDO="available" \
  FDB_SIM_INITIAL_COMPONENTS="git" \
  "$BOOTSTRAP_SH" --simulate --state-file "$L2_STATE")"
assert_contains "$l2_second" '"result":"success"' "L2 second success"
assert_contains "$l2_second" '"installed_components":[]' "L2 second no new install"
PASS_COUNT=$((PASS_COUNT + 1))

# M3: macOS no sudo
m3_out="$(run_case "M3" 30 env \
  FDB_SIM_PLATFORM="macos" \
  FDB_SIM_DISTRIBUTION="macos-13" \
  FDB_SIM_NETWORK="online" \
  FDB_SIM_SUDO="unavailable" \
  "$BOOTSTRAP_SH" --simulate --allow-sudo false)"
assert_contains "$m3_out" '"result":"failed"' "M3 failed"
assert_contains "$m3_out" '"code":"E_NO_PRIVILEGE"' "M3 error code"
PASS_COUNT=$((PASS_COUNT + 1))

# M4: macOS offline
m4_out="$(run_case "M4" 20 env \
  FDB_SIM_PLATFORM="macos" \
  FDB_SIM_DISTRIBUTION="macos-13" \
  FDB_SIM_NETWORK="offline" \
  FDB_SIM_SUDO="available" \
  "$BOOTSTRAP_SH" --simulate)"
assert_contains "$m4_out" '"result":"failed"' "M4 failed"
assert_contains "$m4_out" '"code":"E_NETWORK_OFFLINE"' "M4 error code"
PASS_COUNT=$((PASS_COUNT + 1))

# L3: Linux no sudo
l3_out="$(run_case "L3" 30 env \
  FDB_SIM_PLATFORM="linux" \
  FDB_SIM_DISTRIBUTION="ubuntu" \
  FDB_SIM_NETWORK="online" \
  FDB_SIM_SUDO="unavailable" \
  "$BOOTSTRAP_SH" --simulate --allow-sudo false)"
assert_contains "$l3_out" '"result":"failed"' "L3 failed"
assert_contains "$l3_out" '"code":"E_NO_PRIVILEGE"' "L3 error code"
PASS_COUNT=$((PASS_COUNT + 1))

# L4: Linux offline
l4_out="$(run_case "L4" 20 env \
  FDB_SIM_PLATFORM="linux" \
  FDB_SIM_DISTRIBUTION="debian" \
  FDB_SIM_NETWORK="offline" \
  FDB_SIM_SUDO="available" \
  "$BOOTSTRAP_SH" --simulate)"
assert_contains "$l4_out" '"result":"failed"' "L4 failed"
assert_contains "$l4_out" '"code":"E_NETWORK_OFFLINE"' "L4 error code"
PASS_COUNT=$((PASS_COUNT + 1))

# W1: Windows unsupported
w1_out="$(run_case "W1" 10 env \
  FDB_SIM_PLATFORM="windows" \
  "$BOOTSTRAP_SH" --simulate)"
assert_contains "$w1_out" '"result":"failed"' "W1 failed"
assert_contains "$w1_out" '"code":"E_PLATFORM_UNSUPPORTED"' "W1 error code"
PASS_COUNT=$((PASS_COUNT + 1))

if command -v pwsh >/dev/null 2>&1; then
  ps_out="$(run_case "W1-ps1" 10 pwsh "$BOOTSTRAP_PS1")"
  assert_contains "$ps_out" '"code":"E_PLATFORM_UNSUPPORTED"' "W1 PowerShell contract"
fi

echo "[PASS] acceptance matrix passed (${PASS_COUNT}/7 core cases)."
