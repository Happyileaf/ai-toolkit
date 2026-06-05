Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FEBKnownErrorCodes {
  return @(
    "FEB-PLATFORM-001",
    "FEB-PLATFORM-002",
    "FEB-PERM-001",
    "FEB-NET-001",
    "FEB-NET-002",
    "FEB-PM-001",
    "FEB-PM-002",
    "FEB-DL-001",
    "FEB-DL-002",
    "FEB-INSTALL-001",
    "FEB-INSTALL-002",
    "FEB-INSTALL-003",
    "FEB-INSTALL-004",
    "FEB-CONFIG-001",
    "FEB-VERIFY-001",
    "FEB-IDEMP-001"
  )
}

function Invoke-WindowsVerifyChecks {
  param(
    [string]$NodeLtsPolicy = "latest_lts"
  )
  $checks = @()

  foreach ($cmd in @("git", "node", "pnpm")) {
    $found = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($found) {
      $version = ""
      try {
        $version = & $cmd --version 2>$null | Select-Object -First 1
      } catch {
        try {
          $version = & $cmd -v 2>$null | Select-Object -First 1
        } catch {
          $version = "detected"
        }
      }
      $checks += @{
        name = $cmd
        status = "pass"
        detail = "$version"
      }
    } else {
      $checks += @{
        name = $cmd
        status = "fail"
        detail = "command not found: $cmd"
      }
    }
  }

  $nvmFound = $false
  if (Get-Command nvm -ErrorAction SilentlyContinue) {
    $nvmFound = $true
  }
  $checks += @{
    name = "nvm"
    status = ($nvmFound ? "pass" : "fail")
    detail = ($nvmFound ? "nvm detected." : "nvm not found.")
  }

  if ($NodeLtsPolicy -eq "latest_lts") {
    $checks += @{
      name = "node_policy"
      status = "pass"
      detail = "latest_lts policy accepted for Windows verify baseline."
    }
  } elseif ($NodeLtsPolicy -match "^fixed:\d+\.\d+\.\d+$") {
    $checks += @{
      name = "node_policy"
      status = "warn"
      detail = "fixed policy provided; exact version assertion is not enforced on this baseline."
    }
  } else {
    $checks += @{
      name = "node_policy"
      status = "fail"
      detail = "invalid node_lts_policy: $NodeLtsPolicy"
    }
  }

  $pathEntries = ($env:Path -split ";") | Where-Object { $_ -ne "" }
  $duplicateCount = @($pathEntries | Group-Object | Where-Object { $_.Count -gt 1 }).Count
  $checks += @{
    name = "path_duplicates"
    status = ($duplicateCount -eq 0 ? "pass" : "warn")
    detail = ($duplicateCount -eq 0 ? "PATH has no duplicate entries." : "PATH has duplicate entries: $duplicateCount")
  }

  return $checks
}

function Invoke-WindowsErrorCodeChecks {
  param(
    [string]$ErrorFile = "",
    [string]$ExpectErrorCode = ""
  )

  $checks = @()
  if ([string]::IsNullOrWhiteSpace($ErrorFile)) {
    if (-not [string]::IsNullOrWhiteSpace($ExpectErrorCode)) {
      $checks += @{
        name = "error_code_expected"
        status = "fail"
        detail = "Expected error code was provided but error file is missing."
      }
    }
    return $checks
  }

  if (-not (Test-Path $ErrorFile)) {
    $checks += @{
      name = "error_file_exists"
      status = "fail"
      detail = "error file not found: $ErrorFile"
    }
    return $checks
  }

  $checks += @{
    name = "error_file_exists"
    status = "pass"
    detail = "error file detected: $ErrorFile"
  }

  $payload = $null
  try {
    $payload = Get-Content -Path $ErrorFile -Raw | ConvertFrom-Json
  } catch {
    $checks += @{
      name = "error_code_parse"
      status = "fail"
      detail = "failed to parse JSON from $ErrorFile"
    }
    return $checks
  }

  if (-not $payload.code) {
    $checks += @{
      name = "error_code_parse"
      status = "fail"
      detail = "missing code field in $ErrorFile"
    }
    return $checks
  }

  $checks += @{
    name = "error_code_parse"
    status = "pass"
    detail = "parsed error code: $($payload.code)"
  }

  if ((Get-FEBKnownErrorCodes) -contains $payload.code) {
    $checks += @{
      name = "error_code_known"
      status = "pass"
      detail = "$($payload.code) is part of 16-code catalog."
    }
  } else {
    $checks += @{
      name = "error_code_known"
      status = "fail"
      detail = "$($payload.code) is outside 16-code catalog."
    }
  }

  if (-not [string]::IsNullOrWhiteSpace($ExpectErrorCode)) {
    if ($payload.code -eq $ExpectErrorCode) {
      $checks += @{
        name = "error_code_expected"
        status = "pass"
        detail = "expected code matched: $ExpectErrorCode"
      }
    } else {
      $checks += @{
        name = "error_code_expected"
        status = "fail"
        detail = "expected $ExpectErrorCode but got $($payload.code)"
      }
    }
  }

  return $checks
}
