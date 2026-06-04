#!/usr/bin/env bash
set -euo pipefail

feb_platform_detect() {
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
  if [ "$FEB_NETWORK_MODE" = "proxy" ] && [ -z "${FEB_PROXY_URL:-}" ]; then
    feb_set_error "FEB-NET-002" "Proxy mode requires FEB_PROXY_URL." "preflight" "false" "Export FEB_PROXY_URL and rerun." ""
    return 1
  fi

  if ! command -v curl >/dev/null 2>&1; then
    feb_set_error "FEB-DL-001" "curl is required on macOS path." "preflight" "true" "Install curl or enable Command Line Tools." ""
    return 1
  fi
}

feb_platform_bootstrap_pm() {
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

  if [ "$FEB_SELECTED_PM" = "command-line-tools" ]; then
    feb_log "WARN" "brew missing; install Homebrew manually before non-dry-run execution."
  fi
}

feb_platform_install_core() {
  local missing=""
  if [ "$FEB_INSTALL_GIT" = "true" ] && ! command -v git >/dev/null 2>&1; then
    missing="${missing} git"
  fi
  command -v node >/dev/null 2>&1 || missing="${missing} node"
  command -v pnpm >/dev/null 2>&1 || missing="${missing} pnpm"
  if [ "$FEB_INSTALL_ZSH" = "force" ] && ! command -v zsh >/dev/null 2>&1; then
    missing="${missing} zsh"
  fi

  if [ -n "$missing" ] && [ "$FEB_DRY_RUN" = "true" ]; then
    feb_add_fallback "macOS install_core missing:${missing}; dry-run planned install via brew/curl+nvm."
    feb_log "INFO" "dry-run: planned install for:${missing}."
  elif [ -n "$missing" ]; then
    feb_add_fallback "macOS install_core missing:${missing}; manual install required."
    feb_set_error "FEB-INSTALL-003" "Required runtime tools are missing." "install_core" "true" "Install missing tools and rerun." "$missing"
    return 1
  else
    feb_log "INFO" "install_core: all required tools already available."
  fi
}

feb_platform_configure_shell() {
  local rc_file marker
  rc_file="${HOME}/.zshrc"
  marker="# frontend-env-bootstrap-marker"

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
