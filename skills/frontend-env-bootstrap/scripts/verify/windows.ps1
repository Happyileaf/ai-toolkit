Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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
  } else {
    $checks += @{
      name = "node_policy"
      status = "warn"
      detail = "custom node policy validation is limited on Windows baseline."
    }
  }

  $pathEntries = ($env:Path -split ";") | Where-Object { $_ -ne "" }
  $duplicateCount = ($pathEntries | Group-Object | Where-Object { $_.Count -gt 1 }).Count
  $checks += @{
    name = "path_duplicates"
    status = ($duplicateCount -eq 0 ? "pass" : "warn")
    detail = ($duplicateCount -eq 0 ? "PATH has no duplicate entries." : "PATH has duplicate entries: $duplicateCount")
  }

  return $checks
}
