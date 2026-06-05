#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$ROOT_DIR/scripts/bootstrap/run.sh" \
  --platform linux \
  --target-platforms linux \
  --dry-run \
  --non-interactive \
  --shell-preference bash \
  --node-lts-policy latest_lts \
  --output-dir "$ROOT_DIR/out/linux-example"

echo "Artifacts written to: $ROOT_DIR/out/linux-example"
