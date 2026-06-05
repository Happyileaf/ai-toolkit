Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-SimulatedError {
  param([string]$Code)
  $codes = @()
  if ($env:FEB_SIMULATE_ERROR_CODES) {
    $codes += ($env:FEB_SIMULATE_ERROR_CODES -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
  }
  if ($env:FEB_SIMULATE_ERROR_CODE) {
    $codes += ($env:FEB_SIMULATE_ERROR_CODE -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
  }
  return $codes -contains $Code
}

function New-StructuredError {
  param([string]$Code, [string]$Message)
  return "$Code|$Message"
}

function Test-IsAdmin {
  if ($env:FEB_TEST_MODE -eq "1") {
    return $true
  }
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]::new($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-WindowsCommand {
  param([string]$Name)
  if ($env:FEB_TEST_MODE -eq "1" -and $env:FEB_WINDOWS_PM_AVAILABLE) {
    $mock = ($env:FEB_WINDOWS_PM_AVAILABLE -split "," | ForEach-Object { $_.Trim() })
    if ($mock -contains $Name) {
      return $true
    }
  }
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-PlatformDetect {
  param(
    [string]$TargetPlatforms = "windows"
  )

  if (Test-SimulatedError "FEB-PLATFORM-002") {
    throw (New-StructuredError "FEB-PLATFORM-002" "Simulated unsupported Windows architecture.")
  }

  if ($env:FEB_TEST_MODE -ne "1" -and -not $IsWindows) {
    throw (New-StructuredError "FEB-PLATFORM-001" "Current host is not Windows.")
  }

  if ($TargetPlatforms -notmatch "(^|,)windows(,|$)") {
    throw (New-StructuredError "FEB-PLATFORM-001" "Target platforms does not include windows.")
  }
}

function Invoke-PlatformPreflight {
  param(
    [string]$NetworkMode,
    [string]$ProxyUrl,
    [bool]$DryRun,
    [bool]$AllowElevation,
    [bool]$InstallGit
  )

  foreach ($code in @("FEB-PERM-001", "FEB-NET-001", "FEB-NET-002", "FEB-DL-001", "FEB-PM-001")) {
    if (Test-SimulatedError $code) {
      throw (New-StructuredError $code "Simulated failure for $code.")
    }
  }

  if (-not $DryRun -and -not $AllowElevation -and -not (Test-IsAdmin)) {
    throw (New-StructuredError "FEB-PERM-001" "Non-dry-run installation requires elevation, but allow_elevation=false.")
  }

  if ($NetworkMode -eq "proxy" -and [string]::IsNullOrWhiteSpace($ProxyUrl)) {
    throw (New-StructuredError "FEB-NET-002" "Proxy mode requires FEB_PROXY_URL.")
  }

  if ($env:FEB_ENFORCE_NETWORK_CHECK -eq "true") {
    try {
      Invoke-WebRequest -Uri "https://registry.npmjs.org" -Method Head -TimeoutSec 5 | Out-Null
    } catch {
      throw (New-StructuredError "FEB-NET-001" "Network probe to npm registry failed.")
    }
  }

  $pmFound = Test-WindowsCommand "winget" -or Test-WindowsCommand "choco" -or Test-WindowsCommand "scoop"
  if (-not $pmFound -and -not $DryRun -and -not $AllowElevation) {
    throw (New-StructuredError "FEB-PM-001" "No supported package manager found and official installer path requires elevation.")
  }

  if (-not (Test-WindowsCommand "curl") -and -not (Test-WindowsCommand "Invoke-WebRequest")) {
    throw (New-StructuredError "FEB-DL-001" "No downloader available (curl/Invoke-WebRequest).")
  }
}

function Resolve-PackageManagerPath {
  $fallback = New-Object System.Collections.Generic.List[string]
  if (Test-WindowsCommand "winget") {
    return @{ selected = "winget"; fallback = $fallback }
  }

  $fallback.Add("winget unavailable, fallback to choco.") | Out-Null
  if (Test-WindowsCommand "choco") {
    return @{ selected = "choco"; fallback = $fallback }
  }

  $fallback.Add("choco unavailable, fallback to scoop.") | Out-Null
  if (Test-WindowsCommand "scoop") {
    return @{ selected = "scoop"; fallback = $fallback }
  }

  $fallback.Add("scoop unavailable, fallback to official-installer.") | Out-Null
  return @{ selected = "official-installer"; fallback = $fallback }
}

function Invoke-PlatformBootstrapPm {
  param(
    [bool]$DryRun,
    [bool]$AllowElevation
  )

  if (Test-SimulatedError "FEB-PM-002") {
    throw (New-StructuredError "FEB-PM-002" "Simulated package manager refresh failure.")
  }

  $result = Resolve-PackageManagerPath
  $selected = $result.selected
  $fallback = $result.fallback

  if (-not $DryRun -and $selected -eq "official-installer" -and -not $AllowElevation) {
    throw (New-StructuredError "FEB-PM-001" "Official installer fallback requires allow_elevation=true.")
  }

  if (-not $DryRun -and $env:FEB_RUN_PM_REFRESH -eq "true" -and $selected -ne "official-installer") {
    throw (New-StructuredError "FEB-PM-002" "Package manager refresh failed.")
  }

  if ($DryRun) {
    return @{
      message = "dry-run: selected package manager path = $selected"
      selected = $selected
      fallback = $fallback
    }
  }

  return @{
    message = "package manager selected: $selected"
    selected = $selected
    fallback = $fallback
  }
}

function Test-NvmAvailable {
  if (Get-Command nvm -ErrorAction SilentlyContinue) { return $true }
  if (Test-Path "$env:ProgramFiles\nodejs\nodevars.bat") { return $true }
  return $false
}

function Invoke-PlatformInstallCore {
  param(
    [bool]$DryRun,
    [bool]$InstallGit,
    [string]$NodeLtsPolicy,
    [string]$InstallZsh
  )

  foreach ($code in @("FEB-INSTALL-001", "FEB-INSTALL-002", "FEB-INSTALL-003", "FEB-INSTALL-004", "FEB-DL-002")) {
    if (Test-SimulatedError $code) {
      throw (New-StructuredError $code "Simulated failure for $code.")
    }
  }

  if ($env:FEB_EXPECTED_CHECKSUM -and $env:FEB_ACTUAL_CHECKSUM -and $env:FEB_EXPECTED_CHECKSUM -ne $env:FEB_ACTUAL_CHECKSUM) {
    throw (New-StructuredError "FEB-DL-002" "Checksum validation failed for downloaded artifact.")
  }

  $missing = @()
  if ($InstallGit -and -not (Get-Command git -ErrorAction SilentlyContinue)) { $missing += "git" }
  if (-not (Test-NvmAvailable)) { $missing += "nvm" }
  if (-not (Get-Command node -ErrorAction SilentlyContinue)) { $missing += "node" }
  if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) { $missing += "pnpm" }
  if ($InstallZsh -eq "force" -and -not (Get-Command zsh -ErrorAction SilentlyContinue)) { $missing += "zsh" }

  if ($missing.Count -gt 0 -and $DryRun) {
    return "dry-run: planned install for: $($missing -join ', ')"
  }

  if ($missing.Count -gt 0) {
    switch ($missing[0]) {
      "git" { throw (New-StructuredError "FEB-INSTALL-001" "Git installation is required but unavailable.") }
      "nvm" { throw (New-StructuredError "FEB-INSTALL-002" "NVM installation is required but unavailable.") }
      "node" { throw (New-StructuredError "FEB-INSTALL-003" "Node runtime is missing.") }
      "pnpm" { throw (New-StructuredError "FEB-INSTALL-004" "pnpm is missing.") }
      "zsh" { throw (New-StructuredError "FEB-INSTALL-004" "zsh force-install path is unavailable.") }
    }
  }

  return "install_core: all required tools already available."
}

function Invoke-PlatformConfigureShell {
  param(
    [bool]$DryRun,
    [string]$IdempotentMode
  )

  if (Test-SimulatedError "FEB-CONFIG-001") {
    throw (New-StructuredError "FEB-CONFIG-001" "Simulated shell profile write failure.")
  }
  if (Test-SimulatedError "FEB-IDEMP-001") {
    throw (New-StructuredError "FEB-IDEMP-001" "Simulated idempotency conflict.")
  }

  $profilePath = $PROFILE.CurrentUserAllHosts
  $marker = "# frontend-env-bootstrap-marker"
  if ($DryRun) {
    return "dry-run: planned shell profile idempotent marker check."
  }

  if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
  }

  $content = Get-Content -Path $profilePath -ErrorAction SilentlyContinue
  $beforeCount = @($content | Where-Object { $_ -eq $marker }).Count
  if ($beforeCount -gt 1 -and $IdempotentMode -eq "strict") {
    throw (New-StructuredError "FEB-IDEMP-001" "Shell marker appears multiple times before update.")
  }

  if ($beforeCount -eq 0) {
    Add-Content -Path $profilePath -Value $marker
  }

  $afterContent = Get-Content -Path $profilePath -ErrorAction SilentlyContinue
  $afterCount = @($afterContent | Where-Object { $_ -eq $marker }).Count
  if ($afterCount -gt 1 -and $IdempotentMode -eq "strict") {
    throw (New-StructuredError "FEB-IDEMP-001" "Shell marker duplicated after update.")
  }

  return "shell profile path validated."
}
