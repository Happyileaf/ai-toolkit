#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$ROOT_DIR/scripts/bootstrap/run.sh" \
  --platform macos \
  --dry-run \
  --non-interactive \
  --node-lts-policy latest_lts \
  --output-dir "$ROOT_DIR/out/macos-example"

echo "Artifacts written to: $ROOT_DIR/out/macos-example"
