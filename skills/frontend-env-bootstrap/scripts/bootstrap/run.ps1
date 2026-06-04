Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

param(
  [ValidateSet("auto", "windows")] [string]$Platform = "auto",
  [switch]$DryRun,
  [switch]$NonInteractive,
  [switch]$Strict,
  [ValidateSet("latest_lts")] [string]$NodeLtsPolicy = "latest_lts",
  [ValidateSet("public", "proxy")] [string]$NetworkMode = "public",
  [ValidateSet("strict", "best_effort")] [string]$IdempotentMode = "strict",
  [string]$OutputDir = ""
)

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

function To-StructuredError([string]$Code, [string]$Message, [string]$Stage, [bool]$Retryable, [string]$NextAction, [string]$RawError) {
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

. (Join-Path $ScriptDir "windows\adapter.ps1")

$stages = New-Object System.Collections.Generic.List[object]
$finalStatus = "success"
$structuredError = $null

function Add-Stage([string]$Name, [string]$Status, [string]$Detail) {
  $stages.Add(@{ stage = $Name; status = $Status; detail = $Detail }) | Out-Null
}

try {
  Invoke-PlatformDetect
  Add-Stage "detect" "ok" "Stage completed."

  Invoke-PlatformPreflight -NetworkMode $NetworkMode -ProxyUrl $env:FEB_PROXY_URL
  Add-Stage "preflight" "ok" "Stage completed."

  $pmResult = Invoke-PlatformBootstrapPm -DryRun:$DryRun
  Add-Stage "bootstrap_pm" "ok" $pmResult

  $installResult = Invoke-PlatformInstallCore -DryRun:$DryRun
  Add-Stage "install_core" "ok" $installResult

  $configResult = Invoke-PlatformConfigureShell -DryRun:$DryRun
  Add-Stage "configure_shell" "ok" $configResult

  $verifyScript = Join-Path $SkillRoot "scripts\verify\run.ps1"
  $verifyArgs = @{
    Platform = "windows"
    OutputDir = $OutputDir
  }
  if ($NonInteractive) { $verifyArgs["NonInteractive"] = $true }
  if ($Strict) { $verifyArgs["Strict"] = $true }
  & $verifyScript @verifyArgs
  Add-Stage "verify" "ok" "verification_report.json generated."
} catch {
  $finalStatus = "failed"
  $parts = $_.Exception.Message.Split("|", 2)
  if ($parts.Count -eq 2 -and $parts[0].StartsWith("FEB-")) {
    $structuredError = To-StructuredError -Code $parts[0] -Message $parts[1] -Stage "runtime" -Retryable:$true -NextAction "Inspect logs and rerun." -RawError $_.Exception.Message
  } else {
    $structuredError = To-StructuredError -Code "FEB-INSTALL-003" -Message "Windows bootstrap failed." -Stage "runtime" -Retryable:$true -NextAction "Inspect logs and rerun." -RawError $_.Exception.Message
  }
  Add-Stage "runtime" "failed" "$($structuredError.code): $($structuredError.message)"
}

Add-Stage "finalize" ($finalStatus -eq "success" ? "ok" : "failed") "Bootstrap finalized."

$signatureInput = "windows|$($DryRun.IsPresent)|$($NonInteractive.IsPresent)|$NodeLtsPolicy|$NetworkMode|$IdempotentMode|$(($stages | ConvertTo-Json -Depth 8 -Compress))|$($structuredError.code)"
$signatureBytes = [Text.Encoding]::UTF8.GetBytes($signatureInput)
$sha = [System.Security.Cryptography.SHA256]::Create()
$signature = [BitConverter]::ToString($sha.ComputeHash($signatureBytes)).Replace("-", "").ToLowerInvariant()

$summary = @{
  platform              = "windows"
  dry_run               = $DryRun.IsPresent
  non_interactive       = $NonInteractive.IsPresent
  strict                = $Strict.IsPresent
  node_lts_policy       = $NodeLtsPolicy
  network_mode          = $NetworkMode
  idempotent_mode       = $IdempotentMode
  stages                = $stages
  fallback_chain        = @()
  error                 = $structuredError
  final_status          = $finalStatus
  idempotency_signature = $signature
}

($summary | ConvertTo-Json -Depth 8) | Set-Content -Path $ExecutionSummary -Encoding utf8
Add-HumanLog "INFO" "execution summary written to $ExecutionSummary"

if ($finalStatus -ne "success") {
  exit 35
}
