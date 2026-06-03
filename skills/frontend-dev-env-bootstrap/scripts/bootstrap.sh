#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="1.0.0"

E_PLATFORM_UNSUPPORTED=10
E_PKG_MANAGER_UNAVAILABLE=11
E_NETWORK_OFFLINE=20
E_NO_PRIVILEGE=30
E_INSTALL_FAILED=40
E_VERIFY_FAILED=50

DEFAULT_COMPONENTS=("zsh" "nvm" "node_lts" "pnpm" "git")
TARGET_COMPONENTS=("zsh" "nvm" "node_lts" "pnpm" "git")

NODE_VERSION_POLICY="lts"
INSTALL_MISSING_BREW=true
SWITCH_DEFAULT_SHELL=false
FORCE_UPGRADE=false
DRY_RUN=false
ALLOW_SUDO=true
SIMULATE=false
SIM_STATE_FILE="${HOME}/.frontend-dev-env-bootstrap.simstate"

PLATFORM="unknown"
NETWORK_STATE="unknown"
PRIVILEGE_STATE="unknown"
BREW_AVAILABLE=false

RESULT="success"
ERROR_CODE_NAME=""
ERROR_CODE_VALUE=0
ERROR_MESSAGE=""
ERROR_FAILED_STEP=""
ERROR_ROOT_CAUSE=""
ERROR_REMEDIATION=""

STEP_RESULTS=()
INSTALLED_COMPONENTS=()
SKIPPED_COMPONENTS=()
MISSING_COMPONENTS=()

SIM_COMPONENTS=()
SIM_PLATFORM="${FDB_SIM_PLATFORM:-}"
SIM_DISTRIBUTION="${FDB_SIM_DISTRIBUTION:-}"
SIM_NETWORK="${FDB_SIM_NETWORK:-}"
SIM_SUDO="${FDB_SIM_SUDO:-}"
SIM_INITIAL_COMPONENTS="${FDB_SIM_INITIAL_COMPONENTS:-}"

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

to_lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

json_escape() {
  local value="${1:-}"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

json_array_strings() {
  local out="["
  local first=1
  local item
  for item in "$@"; do
    if [ $first -eq 0 ]; then
      out+=","
    fi
    out+="\"$(json_escape "$item")\""
    first=0
  done
  out+="]"
  printf '%s' "$out"
}

json_array_raw() {
  local out="["
  local first=1
  local item
  for item in "$@"; do
    if [ $first -eq 0 ]; then
      out+=","
    fi
    out+="$item"
    first=0
  done
  out+="]"
  printf '%s' "$out"
}

array_contains() {
  local needle="$1"
  shift || true
  local item
  for item in "$@"; do
    if [ "$item" = "$needle" ]; then
      return 0
    fi
  done
  return 1
}

array_add_unique_by_name() {
  local __name="$1"
  local value="$2"
  # shellcheck disable=SC1083
  eval "local current=(\"\${${__name}[@]:-}\")"
  if array_contains "$value" "${current[@]}"; then
    return 0
  fi
  # shellcheck disable=SC1083
  eval "${__name}+=(\"\$value\")"
}

usage() {
  cat <<'EOF'
Usage:
  ./bootstrap.sh [options]

Options:
  --components <csv>            Target components (default: zsh,nvm,node_lts,pnpm,git)
  --node-version-policy <value> Node policy (MVP supports: lts)
  --install-missing-brew <bool> Auto install Homebrew on macOS when missing (default: true)
  --switch-default-shell <bool> Switch default shell to zsh (default: false)
  --force-upgrade <bool>        Upgrade components even if installed (default: false)
  --dry-run                     Plan only, no changes
  --allow-sudo <bool>           Allow privileged actions (default: true)
  --simulate                    Use deterministic simulation mode for acceptance testing
  --state-file <path>           Simulation state file path
  -h, --help                    Show help

Simulation env vars:
  FDB_SIM_PLATFORM=macos|linux|windows
  FDB_SIM_DISTRIBUTION=macos-13|ubuntu|debian|...
  FDB_SIM_NETWORK=online|offline
  FDB_SIM_SUDO=available|unavailable
  FDB_SIM_INITIAL_COMPONENTS=zsh,nvm,node_lts,pnpm,git,brew
EOF
}

bool_normalize() {
  local raw
  raw="$(to_lower "${1:-}")"
  case "$raw" in
    true|1|yes|y|on) printf 'true' ;;
    false|0|no|n|off) printf 'false' ;;
    *)
      echo "invalid_bool"
      ;;
  esac
}

parse_bool_arg() {
  local key="$1"
  local raw="$2"
  local parsed
  parsed="$(bool_normalize "$raw")"
  if [ "$parsed" = "invalid_bool" ]; then
    echo "Invalid boolean for ${key}: ${raw}" >&2
    exit 2
  fi
  printf '%s' "$parsed"
}

parse_components() {
  local csv="$1"
  local parsed=()
  local value
  IFS=',' read -r -a parsed <<< "$csv"
  if [ "${#parsed[@]}" -eq 0 ]; then
    echo "components cannot be empty" >&2
    exit 2
  fi
  TARGET_COMPONENTS=()
  for value in "${parsed[@]}"; do
    value="$(to_lower "$value")"
    case "$value" in
      zsh|nvm|node_lts|pnpm|git)
        array_add_unique_by_name TARGET_COMPONENTS "$value"
        ;;
      *)
        echo "Unsupported component: $value" >&2
        exit 2
        ;;
    esac
  done
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --components)
        parse_components "${2:-}"
        shift 2
        ;;
      --node-version-policy)
        NODE_VERSION_POLICY="$(to_lower "${2:-}")"
        shift 2
        ;;
      --install-missing-brew)
        INSTALL_MISSING_BREW="$(parse_bool_arg "$1" "${2:-}")"
        shift 2
        ;;
      --switch-default-shell)
        SWITCH_DEFAULT_SHELL="$(parse_bool_arg "$1" "${2:-}")"
        shift 2
        ;;
      --force-upgrade)
        FORCE_UPGRADE="$(parse_bool_arg "$1" "${2:-}")"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift 1
        ;;
      --allow-sudo)
        ALLOW_SUDO="$(parse_bool_arg "$1" "${2:-}")"
        shift 2
        ;;
      --simulate)
        SIMULATE=true
        shift 1
        ;;
      --state-file)
        SIM_STATE_FILE="${2:-}"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
  done
}

add_step() {
  local step="$1"
  local status="$2"
  local message="$3"
  local obj
  obj="{\"step\":\"$(json_escape "$step")\",\"status\":\"$(json_escape "$status")\",\"message\":\"$(json_escape "$message")\",\"time\":\"$(timestamp_utc)\"}"
  STEP_RESULTS+=("$obj")
}

sim_state_load() {
  if [ -f "$SIM_STATE_FILE" ]; then
    while IFS= read -r line; do
      if [ -n "$line" ]; then
        array_add_unique_by_name SIM_COMPONENTS "$line"
      fi
    done < "$SIM_STATE_FILE"
  fi

  if [ -n "$SIM_INITIAL_COMPONENTS" ]; then
    local seed=()
    local item
    IFS=',' read -r -a seed <<< "$SIM_INITIAL_COMPONENTS"
    for item in "${seed[@]}"; do
      item="$(to_lower "$item")"
      if [ -n "$item" ]; then
        array_add_unique_by_name SIM_COMPONENTS "$item"
      fi
    done
  fi
}

sim_state_save() {
  if [ "$SIMULATE" != "true" ]; then
    return 0
  fi

  mkdir -p "$(dirname "$SIM_STATE_FILE")"
  : > "$SIM_STATE_FILE"
  local item
  if [ "${#SIM_COMPONENTS[@]}" -gt 0 ]; then
    for item in "${SIM_COMPONENTS[@]}"; do
      printf '%s\n' "$item" >> "$SIM_STATE_FILE"
    done
  fi
}

sim_has_component() {
  local name="$1"
  if [ "${#SIM_COMPONENTS[@]}" -eq 0 ]; then
    return 1
  fi
  array_contains "$name" "${SIM_COMPONENTS[@]}"
}

sim_mark_component() {
  local name="$1"
  array_add_unique_by_name SIM_COMPONENTS "$name"
}

is_target_component() {
  local name="$1"
  array_contains "$name" "${TARGET_COMPONENTS[@]}"
}

component_installed() {
  local name="$1"
  if [ "$SIMULATE" = "true" ]; then
    sim_has_component "$name"
    return $?
  fi

  case "$name" in
    zsh)
      command -v zsh >/dev/null 2>&1
      ;;
    nvm)
      local nvm_dir
      nvm_dir="${NVM_DIR:-$HOME/.nvm}"
      [ -s "${nvm_dir}/nvm.sh" ]
      ;;
    node_lts)
      command -v node >/dev/null 2>&1
      ;;
    pnpm)
      command -v pnpm >/dev/null 2>&1
      ;;
    git)
      command -v git >/dev/null 2>&1
      ;;
    brew)
      command -v brew >/dev/null 2>&1
      ;;
    *)
      return 1
      ;;
  esac
}

mark_installed_component() {
  local name="$1"
  array_add_unique_by_name INSTALLED_COMPONENTS "$name"
  if [ "$SIMULATE" = "true" ]; then
    sim_mark_component "$name"
  fi
}

mark_skipped_component() {
  local name="$1"
  array_add_unique_by_name SKIPPED_COMPONENTS "$name"
}

emit_result_json() {
  local installed_json
  local skipped_json
  local steps_json
  local error_json

  if [ "${#INSTALLED_COMPONENTS[@]}" -gt 0 ]; then
    installed_json="$(json_array_strings "${INSTALLED_COMPONENTS[@]}")"
  else
    installed_json="[]"
  fi

  if [ "${#SKIPPED_COMPONENTS[@]}" -gt 0 ]; then
    skipped_json="$(json_array_strings "${SKIPPED_COMPONENTS[@]}")"
  else
    skipped_json="[]"
  fi

  if [ "${#STEP_RESULTS[@]}" -gt 0 ]; then
    steps_json="$(json_array_raw "${STEP_RESULTS[@]}")"
  else
    steps_json="[]"
  fi

  if [ "$RESULT" = "failed" ]; then
    error_json="{\"code\":\"$(json_escape "$ERROR_CODE_NAME")\",\"code_value\":${ERROR_CODE_VALUE},\"message\":\"$(json_escape "$ERROR_MESSAGE")\",\"failed_step\":\"$(json_escape "$ERROR_FAILED_STEP")\",\"root_cause\":\"$(json_escape "$ERROR_ROOT_CAUSE")\",\"remediation\":\"$(json_escape "$ERROR_REMEDIATION")\"}"
  else
    error_json="null"
  fi

  printf '{"result":"%s","platform":"%s","installed_components":%s,"skipped_components":%s,"step_results":%s,"error":%s}\n' \
    "$(json_escape "$RESULT")" \
    "$(json_escape "$PLATFORM")" \
    "$installed_json" \
    "$skipped_json" \
    "$steps_json" \
    "$error_json"
}

emit_and_exit() {
  local code="$1"
  sim_state_save
  emit_result_json
  exit "$code"
}

fail_with() {
  local code_name="$1"
  local code_value="$2"
  local failed_step="$3"
  local root_cause="$4"
  local remediation="$5"

  RESULT="failed"
  ERROR_CODE_NAME="$code_name"
  ERROR_CODE_VALUE="$code_value"
  ERROR_MESSAGE="$root_cause"
  ERROR_FAILED_STEP="$failed_step"
  ERROR_ROOT_CAUSE="$root_cause"
  ERROR_REMEDIATION="$remediation"
  add_step "$failed_step" "failed" "$root_cause"
  emit_and_exit "$code_value"
}

run_with_privilege() {
  if [ "$SIMULATE" = "true" ]; then
    return 0
  fi

  if [ "$(id -u)" -eq 0 ]; then
    "$@"
    return $?
  fi

  if [ "$ALLOW_SUDO" != "true" ]; then
    return 1
  fi

  if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    sudo -n "$@"
    return $?
  fi

  return 1
}

detect_platform() {
  if [ "$SIMULATE" = "true" ] && [ -n "$SIM_PLATFORM" ]; then
    local p
    p="$(to_lower "$SIM_PLATFORM")"
    case "$p" in
      macos)
        PLATFORM="macos"
        ;;
      linux)
        local d
        d="$(to_lower "${SIM_DISTRIBUTION:-ubuntu}")"
        case "$d" in
          ubuntu|debian)
            PLATFORM="linux:${d}"
            ;;
          *)
            PLATFORM="linux:${d}"
            ;;
        esac
        ;;
      windows)
        PLATFORM="windows"
        ;;
      *)
        PLATFORM="unknown"
        ;;
    esac
    return 0
  fi

  local uname_s
  uname_s="$(uname -s | tr '[:upper:]' '[:lower:]')"

  case "$uname_s" in
    darwin)
      PLATFORM="macos"
      ;;
    linux)
      if [ -f /etc/os-release ]; then
        local distro
        distro="$(awk -F= '/^ID=/{gsub(/"/,"",$2);print tolower($2)}' /etc/os-release)"
        case "$distro" in
          ubuntu|debian)
            PLATFORM="linux:${distro}"
            ;;
          *)
            PLATFORM="linux:${distro}"
            ;;
        esac
      else
        PLATFORM="linux:unknown"
      fi
      ;;
    *)
      PLATFORM="unknown"
      ;;
  esac
}

detect_network_state() {
  if [ "$SIMULATE" = "true" ] && [ -n "$SIM_NETWORK" ]; then
    local n
    n="$(to_lower "$SIM_NETWORK")"
    if [ "$n" = "offline" ]; then
      NETWORK_STATE="offline"
    else
      NETWORK_STATE="online"
    fi
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    if curl -fsSI --connect-timeout 3 https://registry.npmjs.org >/dev/null 2>&1; then
      NETWORK_STATE="online"
      return 0
    fi
  fi

  NETWORK_STATE="offline"
}

detect_privilege_state() {
  if [ "$SIMULATE" = "true" ] && [ -n "$SIM_SUDO" ]; then
    local s
    s="$(to_lower "$SIM_SUDO")"
    case "$s" in
      available) PRIVILEGE_STATE="available" ;;
      *) PRIVILEGE_STATE="unavailable" ;;
    esac
    return 0
  fi

  if [ "$(id -u)" -eq 0 ]; then
    PRIVILEGE_STATE="available"
    return 0
  fi

  if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    PRIVILEGE_STATE="available"
    return 0
  fi

  PRIVILEGE_STATE="unavailable"
}

refresh_missing_components() {
  MISSING_COMPONENTS=()
  local c
  for c in "${TARGET_COMPONENTS[@]}"; do
    if ! component_installed "$c"; then
      MISSING_COMPONENTS+=("$c")
    fi
  done
}

needs_privilege_for_missing_components() {
  local c
  for c in "${MISSING_COMPONENTS[@]}"; do
    case "$c" in
      zsh|git)
        return 0
        ;;
    esac
  done

  if [ "$PLATFORM" = "macos" ] && ! component_installed brew; then
    return 0
  fi

  return 1
}

ensure_rc_line() {
  local file="$1"
  local line="$2"
  local dir
  dir="$(dirname "$file")"
  mkdir -p "$dir"
  touch "$file"
  if ! grep -Fq "$line" "$file"; then
    printf '%s\n' "$line" >> "$file"
  fi
}

ensure_package_manager() {
  if [ "${#MISSING_COMPONENTS[@]}" -eq 0 ]; then
    add_step "ensure_pkg_manager" "skipped" "All target components already installed."
    return 0
  fi

  if [ "$PLATFORM" = "macos" ]; then
    if component_installed brew; then
      BREW_AVAILABLE=true
      add_step "ensure_homebrew" "skipped" "Homebrew already installed."
      return 0
    fi

    if [ "$INSTALL_MISSING_BREW" != "true" ]; then
      fail_with "E_PKG_MANAGER_UNAVAILABLE" "$E_PKG_MANAGER_UNAVAILABLE" "ensure_homebrew" \
        "Homebrew is missing and auto-install is disabled." \
        "Enable --install-missing-brew true or install Homebrew manually, then rerun."
    fi

    if [ "$DRY_RUN" = "true" ]; then
      add_step "ensure_homebrew" "planned" "Dry-run: would install Homebrew."
      BREW_AVAILABLE=true
      return 0
    fi

    if [ "$SIMULATE" = "true" ]; then
      sim_mark_component "brew"
      BREW_AVAILABLE=true
      add_step "ensure_homebrew" "ok" "Installed Homebrew (simulated)."
      return 0
    fi

    if ! command -v curl >/dev/null 2>&1; then
      fail_with "E_INSTALL_FAILED" "$E_INSTALL_FAILED" "ensure_homebrew" \
        "curl is required to install Homebrew." \
        "Install curl and rerun."
    fi

    if ! NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1; then
      fail_with "E_INSTALL_FAILED" "$E_INSTALL_FAILED" "ensure_homebrew" \
        "Homebrew installation command failed." \
        "Check network access and rerun Homebrew installation manually."
    fi

    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    if [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    if ! command -v brew >/dev/null 2>&1; then
      fail_with "E_PKG_MANAGER_UNAVAILABLE" "$E_PKG_MANAGER_UNAVAILABLE" "ensure_homebrew" \
        "Homebrew installed but not available in PATH." \
        "Run brew shellenv initialization and rerun."
    fi

    BREW_AVAILABLE=true
    add_step "ensure_homebrew" "ok" "Installed Homebrew."
    return 0
  fi

  if [[ "$PLATFORM" == linux:* ]]; then
    local distro="${PLATFORM#linux:}"
    if [ "$distro" != "ubuntu" ] && [ "$distro" != "debian" ]; then
      fail_with "E_PLATFORM_UNSUPPORTED" "$E_PLATFORM_UNSUPPORTED" "detect_platform" \
        "Unsupported Linux distribution: ${distro}." \
        "Use Ubuntu/Debian for MVP or implement distro-specific installer."
    fi

    if [ "$SIMULATE" = "true" ]; then
      add_step "ensure_apt" "ok" "apt-get available (simulated)."
      return 0
    fi

    if ! command -v apt-get >/dev/null 2>&1; then
      fail_with "E_PKG_MANAGER_UNAVAILABLE" "$E_PKG_MANAGER_UNAVAILABLE" "ensure_apt" \
        "apt-get is not available on this Linux host." \
        "Use Ubuntu/Debian with apt-get available."
    fi

    if [ "$DRY_RUN" = "true" ]; then
      add_step "ensure_apt" "planned" "Dry-run: would run apt-get update."
      return 0
    fi

    if ! run_with_privilege apt-get update >/dev/null 2>&1; then
      fail_with "E_NO_PRIVILEGE" "$E_NO_PRIVILEGE" "ensure_apt" \
        "Privilege is required to run apt-get update." \
        "Provide sudo privileges or run as root."
    fi

    add_step "ensure_apt" "ok" "apt-get update completed."
    return 0
  fi

  fail_with "E_PLATFORM_UNSUPPORTED" "$E_PLATFORM_UNSUPPORTED" "detect_platform" \
    "Unsupported platform: ${PLATFORM}." \
    "Use macOS 13+ or Ubuntu/Debian in MVP."
}

install_with_pkg_manager() {
  local package_name="$1"

  if [ "$DRY_RUN" = "true" ]; then
    return 0
  fi

  if [ "$SIMULATE" = "true" ]; then
    return 0
  fi

  if [ "$PLATFORM" = "macos" ]; then
    if ! command -v brew >/dev/null 2>&1; then
      return 1
    fi
    brew install "$package_name" >/dev/null 2>&1
    return $?
  fi

  if [[ "$PLATFORM" == linux:* ]]; then
    if ! run_with_privilege apt-get install -y "$package_name" >/dev/null 2>&1; then
      return 1
    fi
    return 0
  fi

  return 1
}

ensure_zsh() {
  if ! is_target_component "zsh"; then
    return 0
  fi

  if component_installed zsh && [ "$FORCE_UPGRADE" != "true" ]; then
    mark_skipped_component "zsh"
    add_step "ensure_zsh" "skipped" "zsh already installed."
    return 0
  fi

  if [ "$DRY_RUN" = "true" ]; then
    add_step "ensure_zsh" "planned" "Dry-run: would install zsh."
    return 0
  fi

  if [ "$SIMULATE" = "true" ]; then
    mark_installed_component "zsh"
    add_step "ensure_zsh" "ok" "Installed zsh (simulated)."
  else
    if ! install_with_pkg_manager zsh; then
      fail_with "E_INSTALL_FAILED" "$E_INSTALL_FAILED" "ensure_zsh" \
        "Failed to install zsh." \
        "Check package manager access and privileges."
    fi
    mark_installed_component "zsh"
    add_step "ensure_zsh" "ok" "Installed zsh."
  fi

  if [ "$SWITCH_DEFAULT_SHELL" = "true" ]; then
    local zsh_path
    zsh_path="$(command -v zsh || true)"
    if [ -n "$zsh_path" ] && [ "$DRY_RUN" != "true" ] && [ "$SIMULATE" != "true" ]; then
      if [ "${SHELL:-}" != "$zsh_path" ]; then
        chsh -s "$zsh_path" >/dev/null 2>&1 || true
      fi
    fi
  fi
}

install_nvm_real() {
  if ! command -v curl >/dev/null 2>&1; then
    return 1
  fi
  local temp_script
  temp_script="$(mktemp)"
  if ! curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh -o "$temp_script"; then
    rm -f "$temp_script"
    return 1
  fi
  if ! bash "$temp_script" >/dev/null 2>&1; then
    rm -f "$temp_script"
    return 1
  fi
  rm -f "$temp_script"
  return 0
}

ensure_nvm() {
  if ! is_target_component "nvm"; then
    return 0
  fi

  if component_installed nvm && [ "$FORCE_UPGRADE" != "true" ]; then
    mark_skipped_component "nvm"
    add_step "ensure_nvm" "skipped" "nvm already installed."
    return 0
  fi

  if [ "$DRY_RUN" = "true" ]; then
    add_step "ensure_nvm" "planned" "Dry-run: would install nvm."
    return 0
  fi

  if [ "$SIMULATE" = "true" ]; then
    mark_installed_component "nvm"
  else
    if ! install_nvm_real; then
      fail_with "E_INSTALL_FAILED" "$E_INSTALL_FAILED" "ensure_nvm" \
        "Failed to install nvm." \
        "Check network and shell environment, then rerun."
    fi
    mark_installed_component "nvm"
  fi

  ensure_rc_line "$HOME/.zshrc" 'export NVM_DIR="$HOME/.nvm"'
  ensure_rc_line "$HOME/.zshrc" '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'
  ensure_rc_line "$HOME/.bashrc" 'export NVM_DIR="$HOME/.nvm"'
  ensure_rc_line "$HOME/.bashrc" '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'

  add_step "ensure_nvm" "ok" "Installed nvm and updated shell rc idempotently."
}

source_nvm_if_available() {
  local nvm_dir
  nvm_dir="${NVM_DIR:-$HOME/.nvm}"
  if [ -s "${nvm_dir}/nvm.sh" ]; then
    # shellcheck disable=SC1090
    . "${nvm_dir}/nvm.sh"
    return 0
  fi
  return 1
}

ensure_node_lts() {
  if ! is_target_component "node_lts"; then
    return 0
  fi

  if [ "$NODE_VERSION_POLICY" != "lts" ]; then
    fail_with "E_VERIFY_FAILED" "$E_VERIFY_FAILED" "ensure_node_lts" \
      "Unsupported node_version_policy: ${NODE_VERSION_POLICY}." \
      "Use node_version_policy=lts for MVP."
  fi

  if component_installed node_lts && [ "$FORCE_UPGRADE" != "true" ]; then
    mark_skipped_component "node_lts"
    add_step "ensure_node_lts" "skipped" "Node.js already installed."
    return 0
  fi

  if [ "$DRY_RUN" = "true" ]; then
    add_step "ensure_node_lts" "planned" "Dry-run: would install Node.js LTS."
    return 0
  fi

  if [ "$SIMULATE" = "true" ]; then
    mark_installed_component "node_lts"
    add_step "ensure_node_lts" "ok" "Installed Node.js LTS (simulated)."
    return 0
  fi

  if ! source_nvm_if_available; then
    fail_with "E_VERIFY_FAILED" "$E_VERIFY_FAILED" "ensure_node_lts" \
      "nvm is not available for Node.js installation." \
      "Ensure nvm is installed and shell rc is sourced."
  fi

  if ! nvm install --lts >/dev/null 2>&1; then
    fail_with "E_INSTALL_FAILED" "$E_INSTALL_FAILED" "ensure_node_lts" \
      "Failed to install Node.js LTS via nvm." \
      "Check nvm setup and retry."
  fi

  nvm alias default 'lts/*' >/dev/null 2>&1 || true

  if ! command -v node >/dev/null 2>&1; then
    fail_with "E_VERIFY_FAILED" "$E_VERIFY_FAILED" "ensure_node_lts" \
      "Node.js command is not available after install." \
      "Open a new shell session or source nvm before retry."
  fi

  mark_installed_component "node_lts"
  add_step "ensure_node_lts" "ok" "Installed Node.js LTS."
}

ensure_pnpm() {
  if ! is_target_component "pnpm"; then
    return 0
  fi

  if component_installed pnpm && [ "$FORCE_UPGRADE" != "true" ]; then
    mark_skipped_component "pnpm"
    add_step "ensure_pnpm" "skipped" "pnpm already installed."
    return 0
  fi

  if [ "$DRY_RUN" = "true" ]; then
    add_step "ensure_pnpm" "planned" "Dry-run: would install pnpm."
    return 0
  fi

  if [ "$SIMULATE" = "true" ]; then
    mark_installed_component "pnpm"
    add_step "ensure_pnpm" "ok" "Installed pnpm (simulated)."
    return 0
  fi

  if command -v corepack >/dev/null 2>&1; then
    if ! corepack enable >/dev/null 2>&1; then
      fail_with "E_INSTALL_FAILED" "$E_INSTALL_FAILED" "ensure_pnpm" \
        "Failed to enable corepack." \
        "Ensure corepack is available and retry."
    fi
    if ! corepack prepare pnpm@latest --activate >/dev/null 2>&1; then
      fail_with "E_INSTALL_FAILED" "$E_INSTALL_FAILED" "ensure_pnpm" \
        "Failed to prepare pnpm via corepack." \
        "Retry with a stable network connection."
    fi
  elif command -v npm >/dev/null 2>&1; then
    if ! npm install -g pnpm >/dev/null 2>&1; then
      fail_with "E_INSTALL_FAILED" "$E_INSTALL_FAILED" "ensure_pnpm" \
        "Failed to install pnpm using npm." \
        "Check npm global install permissions and retry."
    fi
  else
    fail_with "E_INSTALL_FAILED" "$E_INSTALL_FAILED" "ensure_pnpm" \
      "Neither corepack nor npm is available for pnpm installation." \
      "Install Node.js LTS first, then retry."
  fi

  if ! command -v pnpm >/dev/null 2>&1; then
    fail_with "E_VERIFY_FAILED" "$E_VERIFY_FAILED" "ensure_pnpm" \
      "pnpm command is unavailable after install." \
      "Open a new shell session and rerun."
  fi

  mark_installed_component "pnpm"
  add_step "ensure_pnpm" "ok" "Installed pnpm."
}

ensure_git() {
  if ! is_target_component "git"; then
    return 0
  fi

  if component_installed git && [ "$FORCE_UPGRADE" != "true" ]; then
    mark_skipped_component "git"
    add_step "ensure_git" "skipped" "git already installed."
    return 0
  fi

  if [ "$DRY_RUN" = "true" ]; then
    add_step "ensure_git" "planned" "Dry-run: would install git."
    return 0
  fi

  if [ "$SIMULATE" = "true" ]; then
    mark_installed_component "git"
    add_step "ensure_git" "ok" "Installed git (simulated)."
    return 0
  fi

  if ! install_with_pkg_manager git; then
    fail_with "E_INSTALL_FAILED" "$E_INSTALL_FAILED" "ensure_git" \
      "Failed to install git." \
      "Check package manager health and permissions."
  fi

  if ! command -v git >/dev/null 2>&1; then
    fail_with "E_VERIFY_FAILED" "$E_VERIFY_FAILED" "ensure_git" \
      "git command is unavailable after install." \
      "Verify PATH and rerun."
  fi

  mark_installed_component "git"
  add_step "ensure_git" "ok" "Installed git."
}

post_verify() {
  local missing_after=()
  local c
  for c in "${TARGET_COMPONENTS[@]}"; do
    if ! component_installed "$c"; then
      missing_after+=("$c")
    fi
  done

  if [ "${#missing_after[@]}" -gt 0 ]; then
    fail_with "E_VERIFY_FAILED" "$E_VERIFY_FAILED" "post_verify" \
      "Missing components after installation: ${missing_after[*]}." \
      "Review step_results and fix failed component installation."
  fi

  add_step "post_verify" "ok" "All target components are available."
}

check_scope_and_preflight() {
  detect_platform
  add_step "detect_platform" "ok" "Detected platform: ${PLATFORM}"

  case "$PLATFORM" in
    windows)
      fail_with "E_PLATFORM_UNSUPPORTED" "$E_PLATFORM_UNSUPPORTED" "detect_platform" \
        "Windows is outside MVP support scope." \
        "Use macOS 13+ or Ubuntu/Debian in this release."
      ;;
    macos)
      ;;
    linux:ubuntu|linux:debian)
      ;;
    linux:*)
      fail_with "E_PLATFORM_UNSUPPORTED" "$E_PLATFORM_UNSUPPORTED" "detect_platform" \
        "Unsupported Linux distribution: ${PLATFORM#linux:}." \
        "Use Ubuntu/Debian for MVP support."
      ;;
    *)
      fail_with "E_PLATFORM_UNSUPPORTED" "$E_PLATFORM_UNSUPPORTED" "detect_platform" \
        "Unsupported platform: ${PLATFORM}." \
        "Use macOS 13+ or Ubuntu/Debian in this release."
      ;;
  esac

  detect_network_state
  add_step "detect_network" "ok" "Network state: ${NETWORK_STATE}"

  detect_privilege_state
  add_step "detect_privilege" "ok" "Privilege state: ${PRIVILEGE_STATE} (allow_sudo=${ALLOW_SUDO})"

  refresh_missing_components

  if [ "${#MISSING_COMPONENTS[@]}" -eq 0 ]; then
    add_step "detect_existing_tools" "ok" "All target components already installed."
    return 0
  fi

  add_step "detect_existing_tools" "ok" "Missing components: ${MISSING_COMPONENTS[*]}"

  if [ "$NETWORK_STATE" = "offline" ]; then
    fail_with "E_NETWORK_OFFLINE" "$E_NETWORK_OFFLINE" "preflight" \
      "Network is offline but missing components require download." \
      "Connect to the network and rerun, or preinstall missing components."
  fi

  if needs_privilege_for_missing_components; then
    if [ "$ALLOW_SUDO" != "true" ] || [ "$PRIVILEGE_STATE" != "available" ]; then
      fail_with "E_NO_PRIVILEGE" "$E_NO_PRIVILEGE" "preflight" \
        "Privilege is required for pending system package operations." \
        "Grant sudo permission or rerun as root."
    fi
  fi
}

main() {
  parse_args "$@"

  if [ "$NODE_VERSION_POLICY" != "lts" ]; then
    fail_with "E_VERIFY_FAILED" "$E_VERIFY_FAILED" "parse_args" \
      "Unsupported node_version_policy: ${NODE_VERSION_POLICY}." \
      "Use node_version_policy=lts for MVP."
  fi

  if [ "$SIMULATE" = "true" ]; then
    sim_state_load
  fi

  check_scope_and_preflight
  ensure_package_manager
  ensure_zsh
  ensure_nvm
  ensure_node_lts
  ensure_pnpm
  ensure_git
  post_verify

  if [ "$DRY_RUN" = "true" ] && [ "${#MISSING_COMPONENTS[@]}" -gt 0 ]; then
    RESULT="partial"
  else
    RESULT="success"
  fi

  emit_and_exit 0
}

main "$@"
