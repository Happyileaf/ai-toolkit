#!/usr/bin/env bash
set -euo pipefail

verify_platform_checks() {
  verify_cmd_version "git" "git"
  verify_cmd_version "node" "node"
  verify_cmd_version "pnpm" "pnpm"
  verify_nvm
  verify_node_policy "$VERIFY_NODE_LTS_POLICY"
  verify_path_duplicates
}
