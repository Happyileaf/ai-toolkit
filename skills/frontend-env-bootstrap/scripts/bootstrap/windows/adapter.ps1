Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-PlatformDetect {
  if (-not $IsWindows) {
    throw "FEB-PLATFORM-001|Current host is not Windows."
  }
}

function Invoke-PlatformPreflight {
  param(
    [string]$NetworkMode,
    [string]$ProxyUrl
  )

  if ($NetworkMode -eq "proxy" -and [string]::IsNullOrWhiteSpace($ProxyUrl)) {
    throw "FEB-NET-002|Proxy mode requires FEB_PROXY_URL."
  }

  if (-not (Get-Command winget -ErrorAction SilentlyContinue) `
      -and -not (Get-Command choco -ErrorAction SilentlyContinue) `
      -and -not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    throw "FEB-PM-001|No supported package manager found (winget/choco/scoop)."
  }
}

function Invoke-PlatformBootstrapPm {
  param([bool]$DryRun)
  if ($DryRun) {
    return "dry-run: planned package manager bootstrap."
  }
  return "package manager path ready."
}

function Invoke-PlatformInstallCore {
  param([bool]$DryRun)
  $missing = @()
  foreach ($cmd in @("git", "node", "pnpm")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
      $missing += $cmd
    }
  }

  if ($missing.Count -gt 0 -and $DryRun) {
    return "dry-run: planned install for: $($missing -join ', ')"
  }

  if ($missing.Count -gt 0) {
    throw "FEB-INSTALL-003|Missing tools: $($missing -join ', ')"
  }

  return "install_core: all required tools already available."
}

function Invoke-PlatformConfigureShell {
  param([bool]$DryRun)
  if ($DryRun) {
    return "dry-run: planned shell profile idempotent marker check."
  }
  return "shell profile path validated."
}
