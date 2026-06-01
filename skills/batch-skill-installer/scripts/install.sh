#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_LIST_PATH="${SCRIPT_DIR}/../skill-list.json"
LOG_FILE="${SCRIPT_DIR}/install.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $*" >> "$LOG_FILE"
}

info() { echo -e "${BLUE}[INFO]${NC} $*"; log "[INFO] $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; log "[OK] $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; log "[WARN] $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; log "[ERROR] $*"; }

check_dependencies() {
  local missing=()
  
  if ! command -v npx &>/dev/null; then
    missing+=("npx (Node.js)")
  fi
  
  if ! command -v jq &>/dev/null; then
    missing+=("jq")
  fi
  
  if [ ${#missing[@]} -gt 0 ]; then
    error "Missing dependencies: ${missing[*]}"
    echo ""
    info "Install instructions:"
    for dep in "${missing[@]}"; do
      case $dep in
        "npx (Node.js)")
          echo "  - Node.js: https://nodejs.org/ or 'brew install node'"
          ;;
        "jq")
          if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  - jq: brew install jq"
          else
            echo "  - jq: sudo apt install jq OR sudo yum install jq"
          fi
          ;;
      esac
    done
    exit 1
  fi
}

detect_os() {
  case "$OSTYPE" in
    darwin*)  echo "macos" ;;
    linux*)   echo "linux" ;;
    *)        echo "unknown" ;;
  esac
}

parse_skill_list() {
  if [ ! -f "$SKILL_LIST_PATH" ]; then
    error "skill-list.json not found at: $SKILL_LIST_PATH"
    exit 1
  fi
  
  if ! jq empty "$SKILL_LIST_PATH" 2>/dev/null; then
    error "Invalid JSON format in skill-list.json"
    exit 1
  fi
  
  jq -c '.skills[]' "$SKILL_LIST_PATH"
}

install_skill() {
  local item="$1"
  local script repo skill
  
  script=$(echo "$item" | jq -r '.script // empty')
  repo=$(echo "$item" | jq -r '.repo // empty')
  skill=$(echo "$item" | jq -r '.skill // empty')
  
  local item_id
  if [ -n "$skill" ]; then
    item_id="${repo}#${skill}"
  else
    item_id="$script"
  fi
  
  info "Installing: $item_id"
  
  if [ -n "$script" ]; then
    local global_script="${script} -g"
    if eval "$global_script" 2>> "$LOG_FILE"; then
      success "$item_id"
      return 0
    else
      warn "Script failed for $item_id, trying fallback..."
    fi
  fi
  
  if [ -n "$repo" ] && [ -n "$skill" ]; then
    if npx skills add "$repo" --skill "$skill" -g 2>> "$LOG_FILE"; then
      success "$item_id"
      return 0
    else
      error "Failed to install: $item_id"
      return 1
    fi
  else
    error "Missing repo or skill for fallback: $item_id"
    return 1
  fi
}

main() {
  local os
  os=$(detect_os)
  info "Detected OS: $os"
  
  info "Checking dependencies..."
  check_dependencies
  
  info "Reading skill list from: $SKILL_LIST_PATH"
  
  local total=0
  local ok=0
  local failed=0
  local failed_items=()
  
  while IFS= read -r item; do
    ((total++)) || true
    if install_skill "$item"; then
      ((ok++)) || true
    else
      ((failed++)) || true
      local skill_name
      skill_name=$(echo "$item" | jq -r '.skill // "unknown"')
      failed_items+=("$skill_name")
    fi
  done < <(parse_skill_list)
  
  echo ""
  echo "================================"
  info "Installation Summary"
  echo "================================"
  echo -e "  Total:   $total"
  echo -e "  ${GREEN}Success: $ok${NC}"
  echo -e "  ${RED}Failed:  $failed${NC}"
  
  if [ ${#failed_items[@]} -gt 0 ]; then
    echo ""
    warn "Failed items: ${failed_items[*]}"
  fi
  
  info "Log file: $LOG_FILE"
  
  if [ $failed -gt 0 ]; then
    exit 1
  fi
}

main "$@"