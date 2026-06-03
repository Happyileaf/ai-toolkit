#!/usr/bin/env pwsh
param()

$ErrorActionPreference = "Stop"
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$result = [ordered]@{
  result = "failed"
  platform = "windows"
  installed_components = @()
  skipped_components = @()
  step_results = @(
    @{
      step = "detect_platform"
      status = "failed"
      message = "Windows is outside MVP support scope."
      time = $timestamp
    }
  )
  error = @{
    code = "E_PLATFORM_UNSUPPORTED"
    code_value = 10
    message = "Windows is not supported in frontend-dev-env-bootstrap MVP."
    failed_step = "detect_platform"
    root_cause = "MVP scope only includes macOS 13+ and Ubuntu/Debian."
    remediation = "Use macOS 13+ or Ubuntu/Debian for automatic bootstrap in this release."
  }
}

$result | ConvertTo-Json -Depth 6 -Compress
exit 10
