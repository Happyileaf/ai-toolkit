#!/usr/bin/env bash
set -euo pipefail

macos_has_nvm() {
  if command -v nvm >/dev/null 2>&1; then
    return 0
  fi
  if [ -n "${NVM_DIR:-}" ] && [ -s "${NVM_DIR}/nvm.sh" ]; then
    return 0
  fi
  [ -s "${HOME}/.nvm/nvm.sh" ]
}

macos_network_probe() {
  curl -fsS -I --max-time 5 https://registry.npmjs.org >/dev/null 2>&1
}

feb_platform_detect() {
  feb_maybe_simulate_error "FEB-PLATFORM-002" "detect" "Simulated unsupported macOS architecture." "Disable simulation and rerun." "false" || return 1

  if [ "$(uname -s)" != "Darwin" ]; then
    feb_set_error "FEB-PLATFORM-001" "Current host is not macOS." "detect" "false" "Run on macOS or pass --platform matching host." ""
    return 1
  fi

  case "$(uname -m)" in
    x86_64|arm64) ;;
    *)
      feb_set_error "FEB-PLATFORM-002" "Unsupported macOS architecture." "detect" "false" "Use x86_64 or arm64 host." "$(uname -m)"
      return 1
      ;;
  esac
}

feb_platform_preflight() {
  feb_maybe_simulate_error "FEB-PERM-001" "preflight" "Simulated permission check failure." "Disable simulation and rerun with allow_elevation=true." "false" || return 1
  feb_maybe_simulate_error "FEB-NET-001" "preflight" "Simulated network unreachable." "Disable simulation and verify outbound connectivity." "true" || return 1
  feb_maybe_simulate_error "FEB-NET-002" "preflight" "Simulated invalid proxy configuration." "Disable simulation or provide valid proxy." "false" || return 1
  feb_maybe_simulate_error "FEB-DL-001" "preflight" "Simulated downloader missing." "Disable simulation and install curl." "true" || return 1
  feb_maybe_simulate_error "FEB-PM-001" "preflight" "Simulated package manager missing." "Disable simulation and install brew or Command Line Tools." "false" || return 1

  if [ "$FEB_DRY_RUN" != "true" ] && [ "$FEB_ALLOW_ELEVATION" = "false" ] && [ "$(id -u)" -ne 0 ]; then
    feb_set_error "FEB-PERM-001" "Non-dry-run installation requires elevation, but allow_elevation=false." "preflight" "false" "Set --allow-elevation true or run with elevated privileges." ""
    return 1
  fi

  if [ "$FEB_NETWORK_MODE" = "proxy" ] && [ -z "${FEB_PROXY_URL:-}" ]; then
    feb_set_error "FEB-NET-002" "Proxy mode requires FEB_PROXY_URL." "preflight" "false" "Export FEB_PROXY_URL and rerun." ""
    return 1
  fi

  if [ "${FEB_ENFORCE_NETWORK_CHECK:-false}" = "true" ] && ! macos_network_probe; then
    feb_set_error "FEB-NET-001" "Network probe to npm registry failed." "preflight" "true" "Check network/firewall and retry." ""
    return 1
  fi

  if ! command -v curl >/dev/null 2>&1; then
    feb_set_error "FEB-DL-001" "curl is required on macOS path." "preflight" "true" "Install curl or enable Command Line Tools." ""
    return 1
  fi
}

feb_platform_bootstrap_pm() {
  feb_maybe_simulate_error "FEB-PM-002" "bootstrap_pm" "Simulated package manager refresh failure." "Disable simulation and retry package manager refresh." "true" || return 1

  if command -v brew >/dev/null 2>&1; then
    FEB_SELECTED_PM="brew"
  else
    FEB_SELECTED_PM="command-line-tools"
    feb_add_fallback "brew not found; fallback to Command Line Tools bootstrap path."
  fi

  if [ "$FEB_DRY_RUN" = "true" ]; then
    feb_log "INFO" "dry-run: would bootstrap package manager path via ${FEB_SELECTED_PM}."
    return 0
  fi

  if [ "$FEB_SELECTED_PM" = "brew" ] && [ "${FEB_RUN_PM_REFRESH:-false}" = "true" ]; then
    if ! brew update >/dev/null 2>&1; then
      feb_set_error "FEB-PM-002" "Homebrew refresh failed." "bootstrap_pm" "true" "Check brew source and retry." "brew update"
      return 1
    fi
  fi

  if [ "$FEB_SELECTED_PM" = "command-line-tools" ]; then
    feb_log "WARN" "brew missing; install Homebrew manually before non-dry-run execution."
  fi
}

feb_platform_install_core() {
  feb_maybe_simulate_error "FEB-INSTALL-001" "install_core" "Simulated git installation failure." "Disable simulation and rerun." "true" || return 1
  feb_maybe_simulate_error "FEB-INSTALL-002" "install_core" "Simulated nvm installation failure." "Disable simulation and rerun." "true" || return 1
  feb_maybe_simulate_error "FEB-INSTALL-003" "install_core" "Simulated node installation failure." "Disable simulation and rerun." "true" || return 1
  feb_maybe_simulate_error "FEB-INSTALL-004" "install_core" "Simulated pnpm installation failure." "Disable simulation and rerun." "true" || return 1
  feb_maybe_simulate_error "FEB-DL-002" "install_core" "Simulated checksum validation failure." "Disable simulation and verify checksum configuration." "false" || return 1

  if [ -n "${FEB_EXPECTED_CHECKSUM:-}" ] && [ -n "${FEB_ACTUAL_CHECKSUM:-}" ] && [ "$FEB_EXPECTED_CHECKSUM" != "$FEB_ACTUAL_CHECKSUM" ]; then
    feb_set_error "FEB-DL-002" "Checksum validation failed for downloaded artifact." "install_core" "false" "Update checksum or redownload artifact." "expected=${FEB_EXPECTED_CHECKSUM},actual=${FEB_ACTUAL_CHECKSUM}"
    return 1
  fi

  local missing=()
  if [ "$FEB_INSTALL_GIT" = "true" ] && ! command -v git >/dev/null 2>&1; then
    missing+=("git")
  fi
  if ! macos_has_nvm; then
    missing+=("nvm")
  fi
  if ! command -v node >/dev/null 2>&1; then
    missing+=("node")
  fi
  if ! command -v pnpm >/dev/null 2>&1; then
    missing+=("pnpm")
  fi
  if [ "$FEB_INSTALL_ZSH" = "force" ] && ! command -v zsh >/dev/null 2>&1; then
    missing+=("zsh")
  fi

  if [ "${#missing[@]}" -gt 0 ] && [ "$FEB_DRY_RUN" = "true" ]; then
    feb_add_fallback "macOS install_core missing:${missing[*]}; dry-run planned install via brew/curl+nvm/corepack."
    feb_log "INFO" "dry-run: planned install for:${missing[*]}."
    return 0
  fi

  if [ "${#missing[@]}" -gt 0 ]; then
    case "${missing[0]}" in
      git)
        feb_set_error "FEB-INSTALL-001" "Git installation is required but unavailable." "install_core" "true" "Install git via brew and rerun." "${missing[*]}"
        ;;
      nvm)
        feb_set_error "FEB-INSTALL-002" "NVM installation is required but unavailable." "install_core" "true" "Install nvm and rerun." "${missing[*]}"
        ;;
      node)
        feb_set_error "FEB-INSTALL-003" "Node runtime is missing." "install_core" "true" "Install Node LTS and rerun." "${missing[*]}"
        ;;
      pnpm)
        feb_set_error "FEB-INSTALL-004" "pnpm is missing." "install_core" "true" "Install pnpm and rerun." "${missing[*]}"
        ;;
      zsh)
        feb_set_error "FEB-INSTALL-004" "zsh force-install path is unavailable." "install_core" "true" "Install zsh or change --install-zsh auto|skip." "${missing[*]}"
        ;;
    esac
    return 1
  fi

  feb_log "INFO" "install_core: all required tools already available."
}

feb_platform_configure_shell() {
  feb_maybe_simulate_error "FEB-CONFIG-001" "configure_shell" "Simulated shell configuration write failure." "Disable simulation and check shell profile permissions." "false" || return 1
  feb_maybe_simulate_error "FEB-IDEMP-001" "configure_shell" "Simulated idempotency conflict." "Disable simulation and rerun from a clean shell profile." "false" || return 1

  local rc_file marker
  rc_file="${HOME}/.zshrc"
  [ "$FEB_SHELL_PREFERENCE" = "bash" ] && rc_file="${HOME}/.bashrc"
  marker="# frontend-env-bootstrap-marker"

  if [ "$FEB_DRY_RUN" = "true" ]; then
    feb_log "INFO" "dry-run: would ensure shell marker in ${rc_file}."
    return 0
  fi

  touch "$rc_file" || {
    feb_set_error "FEB-CONFIG-001" "Cannot access shell rc file." "configure_shell" "false" "Check file permission for shell rc file." "$rc_file"
    return 1
  }

  local before_count=0
  before_count="$(grep -F -c "$marker" "$rc_file" || true)"
  if [ "$before_count" -gt 1 ] && [ "$FEB_IDEMPOTENT_MODE" = "strict" ]; then
    feb_set_error "FEB-IDEMP-001" "Shell marker appears multiple times before update." "configure_shell" "false" "Deduplicate marker lines in shell profile." "$rc_file"
    return 1
  fi

  if [ "$before_count" -eq 0 ]; then
    printf '%s\n' "$marker" >>"$rc_file"
  fi

  local after_count=0
  after_count="$(grep -F -c "$marker" "$rc_file" || true)"
  if [ "$after_count" -gt 1 ] && [ "$FEB_IDEMPOTENT_MODE" = "strict" ]; then
    feb_set_error "FEB-IDEMP-001" "Shell marker duplicated after update." "configure_shell" "false" "Deduplicate marker lines in shell profile." "$rc_file"
    return 1
  fi
}
