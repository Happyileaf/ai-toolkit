#!/usr/bin/env bash
set -euo pipefail

feb_platform_detect() {
  if [ "$(uname -s)" != "Linux" ]; then
    feb_set_error "FEB-PLATFORM-001" "Current host is not Linux." "detect" "false" "Run on Linux or pass --platform matching host." ""
    return 1
  fi

  case "$(uname -m)" in
    x86_64|aarch64|arm64) ;;
    *)
      feb_set_error "FEB-PLATFORM-002" "Unsupported Linux architecture." "detect" "false" "Use x86_64 or arm64 host." "$(uname -m)"
      return 1
      ;;
  esac

  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-unknown}" in
      ubuntu|debian|rhel|centos|fedora|rocky|almalinux) ;;
      *)
        feb_add_fallback "Unsupported distro ID=${ID:-unknown}; planned fallback to generic Linux path."
        ;;
    esac
  fi
}

feb_platform_preflight() {
  if [ "$FEB_NETWORK_MODE" = "proxy" ] && [ -z "${FEB_PROXY_URL:-}" ]; then
    feb_set_error "FEB-NET-002" "Proxy mode requires FEB_PROXY_URL." "preflight" "false" "Export FEB_PROXY_URL and rerun." ""
    return 1
  fi

  if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    feb_set_error "FEB-DL-001" "No downloader found (curl/wget)." "preflight" "true" "Install curl or wget first." ""
    return 1
  fi

  if ! command -v apt-get >/dev/null 2>&1 && ! command -v dnf >/dev/null 2>&1 && ! command -v yum >/dev/null 2>&1; then
    feb_set_error "FEB-PM-001" "No supported package manager found (apt-get/dnf/yum)." "preflight" "false" "Use a supported Linux distribution." ""
    return 1
  fi
}

feb_platform_bootstrap_pm() {
  if command -v apt-get >/dev/null 2>&1; then
    FEB_SELECTED_PM="apt-get"
  elif command -v dnf >/dev/null 2>&1; then
    FEB_SELECTED_PM="dnf"
  else
    FEB_SELECTED_PM="yum"
  fi

  if [ "$FEB_DRY_RUN" = "true" ]; then
    feb_log "INFO" "dry-run: would bootstrap package manager path via ${FEB_SELECTED_PM}."
    return 0
  fi

  feb_log "INFO" "package manager selected: ${FEB_SELECTED_PM}."
}

feb_platform_install_core() {
  local missing=""
  command -v git >/dev/null 2>&1 || missing="${missing} git"
  command -v node >/dev/null 2>&1 || missing="${missing} node"
  command -v pnpm >/dev/null 2>&1 || missing="${missing} pnpm"

  if [ -n "$missing" ] && [ "$FEB_DRY_RUN" = "true" ]; then
    feb_add_fallback "Linux install_core missing:${missing}; dry-run planned install via ${FEB_SELECTED_PM}."
    feb_log "INFO" "dry-run: planned install for:${missing}."
  elif [ -n "$missing" ]; then
    feb_add_fallback "Linux install_core missing:${missing}; manual install required."
    feb_set_error "FEB-INSTALL-003" "Required runtime tools are missing." "install_core" "true" "Install missing tools and rerun." "$missing"
    return 1
  else
    feb_log "INFO" "install_core: all required tools already available."
  fi
}

feb_platform_configure_shell() {
  local rc_file
  rc_file="${HOME}/.bashrc"
  if [ -n "${ZSH_VERSION:-}" ]; then
    rc_file="${HOME}/.zshrc"
  fi

  local marker="# frontend-env-bootstrap-marker"
  if [ "$FEB_DRY_RUN" = "true" ]; then
    feb_log "INFO" "dry-run: would ensure shell marker in ${rc_file}."
    return 0
  fi

  touch "$rc_file" || {
    feb_set_error "FEB-CONFIG-001" "Cannot access shell rc file." "configure_shell" "false" "Check file permission for shell rc file." "$rc_file"
    return 1
  }

  if ! grep -F "$marker" "$rc_file" >/dev/null 2>&1; then
    printf '%s\n' "$marker" >>"$rc_file"
  fi
}
