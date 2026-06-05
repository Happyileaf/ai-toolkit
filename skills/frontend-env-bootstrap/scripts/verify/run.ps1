param(
  [ValidateSet("auto", "windows")] [string]$Platform = "auto",
  [ValidateSet("json", "text", "both")] [string]$Format = "both",
  [switch]$Strict,
  [switch]$NonInteractive,
  [string]$NodeLtsPolicy = "latest_lts",
  [string]$ErrorFile = "",
  [string]$ExpectErrorCode = "",
  [switch]$SkipToolChecks,
  [string]$OutputDir = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
  $OutputDir = Join-Path $SkillRoot "out"
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$ReportFile = Join-Path $OutputDir "verification_report.json"
$HumanLog = Join-Path $OutputDir "human_log.txt"
if (-not (Test-Path $HumanLog)) {
  Set-Content -Path $HumanLog -Encoding utf8 -Value ""
}

if ($Platform -eq "auto") {
  $Platform = "windows"
}
if ($Platform -ne "windows") {
  throw "Use run.sh for non-Windows verify execution."
}

. (Join-Path $ScriptDir "windows.ps1")

$checks = @()
if ($SkipToolChecks) {
  $checks += @{
    name = "tool_checks_skipped"
    status = "pass"
    detail = "Tool checks skipped due to bootstrap failure path."
  }
} else {
  $checks += Invoke-WindowsVerifyChecks -NodeLtsPolicy $NodeLtsPolicy
}

$checks += Invoke-WindowsErrorCodeChecks -ErrorFile $ErrorFile -ExpectErrorCode $ExpectErrorCode
$failedChecks = @($checks | Where-Object { $_.status -eq "fail" }).Count
$overall = ($failedChecks -eq 0 ? "PASS" : "FAIL")

$report = @{
  platform = "windows"
  overall = $overall
  strict = $Strict.IsPresent
  failed_checks = $failedChecks
  checks = $checks
}
($report | ConvertTo-Json -Depth 10) | Set-Content -Path $ReportFile -Encoding utf8

if ($Format -eq "text" -or $Format -eq "both") {
  Add-Content -Path $HumanLog -Encoding utf8 -Value "[VERIFY] platform=windows strict=$($Strict.IsPresent) non_interactive=$($NonInteractive.IsPresent) skip_tool_checks=$($SkipToolChecks.IsPresent)"
  Add-Content -Path $HumanLog -Encoding utf8 -Value "[VERIFY] failed_checks=$failedChecks"
}

if ($Strict -and $failedChecks -gt 0) {
  exit 1
}
