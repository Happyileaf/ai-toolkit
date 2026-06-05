#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP_PS1="$ROOT_DIR/scripts/bootstrap/run.ps1"
TMP_BASE="$ROOT_DIR/tests/.tmp/windows-entry"

if ! command -v pwsh >/dev/null 2>&1; then
  echo "SKIP test-windows-entry (pwsh not found)"
  exit 0
fi

rm -rf "$TMP_BASE"
mkdir -p "$TMP_BASE"

# Case 1: main path (winget) simulation + non-interactive contract
FEB_TEST_MODE=1 FEB_WINDOWS_PM_AVAILABLE="winget,curl,Invoke-WebRequest" \
pwsh -NoProfile -File "$BOOTSTRAP_PS1" \
  -Platform windows \
  -TargetPlatforms windows \
  -DryRun \
  -NonInteractive \
  -NodeLtsPolicy latest_lts \
  -InstallGit true \
  -InstallZsh skip \
  -ShellPreference powershell \
  -NetworkMode public \
  -AllowElevation false \
  -IdempotentMode strict \
  -OutputDir "$TMP_BASE/main"

test -f "$TMP_BASE/main/execution_summary.json"
test -f "$TMP_BASE/main/verification_report.json"
test -f "$TMP_BASE/main/human_log.txt"
grep -Eq '"non_interactive"[[:space:]]*:[[:space:]]*true' "$TMP_BASE/main/execution_summary.json"
grep -Eq 'selected package manager path = winget' "$TMP_BASE/main/execution_summary.json"

# Case 2: fallback chain simulation + idempotent rerun(3x)
signatures=""
for i in 1 2 3; do
  run_dir="$TMP_BASE/fallback-$i"
  FEB_TEST_MODE=1 FEB_WINDOWS_PM_AVAILABLE="curl,Invoke-WebRequest" \
  pwsh -NoProfile -File "$BOOTSTRAP_PS1" \
    -Platform windows \
    -TargetPlatforms windows \
    -DryRun \
    -NonInteractive \
    -NodeLtsPolicy latest_lts \
    -InstallGit true \
    -InstallZsh skip \
    -ShellPreference powershell \
    -NetworkMode public \
    -AllowElevation false \
    -IdempotentMode strict \
    -OutputDir "$run_dir"
  sig="$(sed -n 's/.*"idempotency_signature": "\([^"]*\)".*/\1/p' "$run_dir/execution_summary.json")"
  if [ -z "$sig" ]; then
    echo "Missing idempotency_signature in windows run $i"
    exit 1
  fi
  signatures="${signatures}${sig}"$'\n'
done

unique_count="$(printf '%s' "$signatures" | sort | uniq | wc -l | tr -d ' ')"
if [ "$unique_count" -ne 1 ]; then
  echo "Expected 1 unique windows idempotency_signature across 3 runs, got $unique_count"
  printf '%s' "$signatures"
  exit 1
fi

grep -Eq 'official-installer' "$TMP_BASE/fallback-1/execution_summary.json"

echo "PASS test-windows-entry"
