param(
  [ValidateSet("auto", "windows")] [string]$Platform = "auto",
  [string]$TargetPlatforms = "windows",
  [switch]$DryRun,
  [switch]$NonInteractive,
  [switch]$Strict,
  [string]$NodeLtsPolicy = "latest_lts",
  [ValidateSet("true", "false")] [string]$InstallGit = "true",
  [ValidateSet("auto", "force", "skip")] [string]$InstallZsh = "skip",
  [ValidateSet("powershell", "bash", "zsh")] [string]$ShellPreference = "powershell",
  [ValidateSet("public", "proxy")] [string]$NetworkMode = "public",
  [ValidateSet("true", "false")] [string]$AllowElevation = "false",
  [ValidateSet("strict", "best_effort")] [string]$IdempotentMode = "strict",
  [string]$OutputDir = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-NodePolicy {
  param([string]$Policy)
  if ($Policy -eq "latest_lts") { return $true }
  if ($Policy -match "^fixed:\d+\.\d+\.\d+$") { return $true }
  return $false
}

function Get-ExitCode {
  param([string]$ErrorCode)
  switch ($ErrorCode) {
    "FEB-PLATFORM-001" { return 21 }
    "FEB-PLATFORM-002" { return 22 }
    "FEB-PERM-001" { return 23 }
    "FEB-NET-001" { return 24 }
    "FEB-NET-002" { return 25 }
    "FEB-PM-001" { return 26 }
    "FEB-PM-002" { return 27 }
    "FEB-DL-001" { return 28 }
    "FEB-DL-002" { return 29 }
    "FEB-INSTALL-001" { return 30 }
    "FEB-INSTALL-002" { return 31 }
    "FEB-INSTALL-003" { return 32 }
    "FEB-INSTALL-004" { return 33 }
    "FEB-CONFIG-001" { return 34 }
    "FEB-VERIFY-001" { return 35 }
    "FEB-IDEMP-001" { return 36 }
    default { return 1 }
  }
}

if (-not (Test-NodePolicy -Policy $NodeLtsPolicy)) {
  Write-Error "node-lts-policy must be latest_lts or fixed:x.y.z"
  exit 2
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
  $OutputDir = Join-Path $SkillRoot "out"
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$ExecutionSummary = Join-Path $OutputDir "execution_summary.json"
$VerificationReport = Join-Path $OutputDir "verification_report.json"
$HumanLog = Join-Path $OutputDir "human_log.txt"
$LastErrorJson = Join-Path $OutputDir "last_error.json"

Set-Content -Path $HumanLog -Value "" -Encoding utf8

function Add-HumanLog([string]$Level, [string]$Message) {
  Add-Content -Path $HumanLog -Encoding utf8 -Value "[$Level] $Message"
}

function Write-StructuredError {
  param(
    [string]$Code,
    [string]$Message,
    [string]$Stage,
    [bool]$Retryable,
    [string]$NextAction,
    [string]$RawError
  )
  $payload = @{
    code        = $Code
    message     = $Message
    stage       = $Stage
    platform    = "windows"
    retryable   = $Retryable
    next_action = $NextAction
    raw_error   = $RawError
  }
  ($payload | ConvertTo-Json -Depth 5) | Set-Content -Path $LastErrorJson -Encoding utf8
  Add-HumanLog "ERROR" "$Code $Message"
  return $payload
}

function Add-Stage([System.Collections.Generic.List[object]]$StageList, [string]$Name, [string]$Status, [string]$Detail) {
  $StageList.Add([ordered]@{ stage = $Name; status = $Status; detail = $Detail }) | Out-Null
}

. (Join-Path $ScriptDir "windows\adapter.ps1")

$stages = New-Object System.Collections.Generic.List[object]
$fallbackChain = New-Object System.Collections.Generic.List[object]
$finalStatus = "success"
$structuredError = $null
$stopPipeline = $false

try {
  if ($Platform -eq "auto") {
    $Platform = "windows"
  }
  if ($Platform -ne "windows") {
    throw "FEB-PLATFORM-001|Unsupported platform selection for PowerShell entrypoint."
  }

  Invoke-PlatformDetect -TargetPlatforms $TargetPlatforms
  Add-Stage $stages "detect" "ok" "Stage completed."

  Invoke-PlatformPreflight -NetworkMode $NetworkMode -ProxyUrl $env:FEB_PROXY_URL -DryRun:$DryRun -AllowElevation:($AllowElevation -eq "true") -InstallGit:($InstallGit -eq "true")
  Add-Stage $stages "preflight" "ok" "Stage completed."

  $pmResult = Invoke-PlatformBootstrapPm -DryRun:$DryRun -AllowElevation:($AllowElevation -eq "true")
  foreach ($step in $pmResult.fallback) {
    $fallbackChain.Add(@{ step = $step }) | Out-Null
  }
  Add-Stage $stages "bootstrap_pm" "ok" $pmResult.message

  $installResult = Invoke-PlatformInstallCore -DryRun:$DryRun -InstallGit:($InstallGit -eq "true") -NodeLtsPolicy $NodeLtsPolicy -InstallZsh $InstallZsh
  Add-Stage $stages "install_core" "ok" $installResult

  $configResult = Invoke-PlatformConfigureShell -DryRun:$DryRun -IdempotentMode $IdempotentMode
  Add-Stage $stages "configure_shell" "ok" $configResult
} catch {
  $finalStatus = "failed"
  $stopPipeline = $true
  $parts = $_.Exception.Message.Split("|", 2)
  if ($parts.Count -eq 2 -and $parts[0].StartsWith("FEB-")) {
    $structuredError = Write-StructuredError -Code $parts[0] -Message $parts[1] -Stage "runtime" -Retryable:$true -NextAction "Inspect logs and rerun." -RawError $_.Exception.Message
  } else {
    $structuredError = Write-StructuredError -Code "FEB-INSTALL-003" -Message "Windows bootstrap failed." -Stage "runtime" -Retryable:$true -NextAction "Inspect logs and rerun." -RawError $_.Exception.Message
  }
  Add-Stage $stages "runtime" "failed" "$($structuredError.code): $($structuredError.message)"
}

$verifyScript = Join-Path $SkillRoot "scripts\verify\run.ps1"
$verifyArgs = @{
  Platform = "windows"
  OutputDir = $OutputDir
  NodeLtsPolicy = $NodeLtsPolicy
}
if ($NonInteractive) { $verifyArgs["NonInteractive"] = $true }
if ($Strict) { $verifyArgs["Strict"] = $true }
if (Test-Path $LastErrorJson) { $verifyArgs["ErrorFile"] = $LastErrorJson }
if ($structuredError) { $verifyArgs["ExpectErrorCode"] = $structuredError.code }
if ($stopPipeline) { $verifyArgs["SkipToolChecks"] = $true }

try {
  & $verifyScript @verifyArgs
  Add-Stage $stages "verify" "ok" "verification_report.json generated."
} catch {
  $finalStatus = "failed"
  if (-not $structuredError) {
    $structuredError = Write-StructuredError -Code "FEB-VERIFY-001" -Message "Verification failed." -Stage "verify" -Retryable:$true -NextAction "Inspect verification_report.json and retry." -RawError $_.Exception.Message
  }
  Add-Stage $stages "verify" "failed" "$($structuredError.code): $($structuredError.message)"
}

if (-not (Test-Path $VerificationReport)) {
  @{
    platform = "windows"
    overall = "FAIL"
    strict = $Strict.IsPresent
    failed_checks = 1
    checks = @(@{
      name = "placeholder_failure_report"
      status = "fail"
      detail = "verification_report.json missing; placeholder generated by bootstrap finalize."
    })
  } | ConvertTo-Json -Depth 8 | Set-Content -Path $VerificationReport -Encoding utf8
}

Add-Stage $stages "finalize" ($finalStatus -eq "success" ? "ok" : "failed") "Bootstrap finalized."

$errorCodeForSignature = ""
if ($structuredError -and $structuredError.code) {
  $errorCodeForSignature = $structuredError.code
}
$signatureInput = "windows|$TargetPlatforms|$ShellPreference|$($DryRun.IsPresent)|$($NonInteractive.IsPresent)|$NodeLtsPolicy|$InstallGit|$InstallZsh|$NetworkMode|$AllowElevation|$IdempotentMode|$(($stages | ConvertTo-Json -Depth 10 -Compress))|$(($fallbackChain | ConvertTo-Json -Depth 8 -Compress))|$errorCodeForSignature"
$signatureBytes = [Text.Encoding]::UTF8.GetBytes($signatureInput)
$sha = [System.Security.Cryptography.SHA256]::Create()
$signature = [BitConverter]::ToString($sha.ComputeHash($signatureBytes)).Replace("-", "").ToLowerInvariant()

$summary = @{
  platform              = "windows"
  target_platforms      = $TargetPlatforms
  shell_preference      = $ShellPreference
  dry_run               = $DryRun.IsPresent
  non_interactive       = $NonInteractive.IsPresent
  strict                = $Strict.IsPresent
  node_lts_policy       = $NodeLtsPolicy
  install_git           = ($InstallGit -eq "true")
  install_zsh           = $InstallZsh
  network_mode          = $NetworkMode
  allow_elevation       = ($AllowElevation -eq "true")
  idempotent_mode       = $IdempotentMode
  stages                = $stages
  fallback_chain        = $fallbackChain
  error                 = $structuredError
  final_status          = $finalStatus
  idempotency_signature = $signature
}

($summary | ConvertTo-Json -Depth 10) | Set-Content -Path $ExecutionSummary -Encoding utf8
Add-HumanLog "INFO" "execution summary written to $ExecutionSummary"

if ($finalStatus -ne "success") {
  exit (Get-ExitCode -ErrorCode $structuredError.code)
}
