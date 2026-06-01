#!/usr/bin/env pwsh
param(
  [string]$SkillListPath = "",
  [switch]$Help
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($SkillListPath -eq "") {
  $SkillListPath = Join-Path $ScriptDir "..\skill-list.json"
}

$LogFile = Join-Path $ScriptDir "install.log"

function Write-Log {
  param([string]$Message)
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  "[$timestamp] $Message" | Out-File -FilePath $LogFile -Append
}

function Write-Info { param([string]$Message) Write-Host "`e[34m[INFO]`e[0m $Message"; Write-Log "[INFO] $Message" }
function Write-Success { param([string]$Message) Write-Host "`e[32m[OK]`e[0m $Message"; Write-Log "[OK] $Message" }
function Write-Warning { param([string]$Message) Write-Host "`e[33m[WARN]`e[0m $Message"; Write-Log "[WARN] $Message" }
function Write-Error { param([string]$Message) Write-Host "`e[31m[ERROR]`e[0m $Message"; Write-Log "[ERROR] $Message" }

function Test-Dependencies {
  $missing = @()
  
  if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    $missing += "npx (Node.js)"
  }
  
  if ($missing.Count -gt 0) {
    Write-Error "Missing dependencies: $($missing -join ', ')"
    Write-Info "Install Node.js from: https://nodejs.org/"
    exit 1
  }
}

function Test-SkillList {
  if (-not (Test-Path $SkillListPath)) {
    Write-Error "skill-list.json not found at: $SkillListPath"
    exit 1
  }
  
  try {
    $null = Get-Content $SkillListPath -Raw | ConvertFrom-Json
  } catch {
    Write-Error "Invalid JSON format in skill-list.json"
    exit 1
  }
}

function Install-Skill {
  param([pscustomobject]$Item)
  
  $script = $Item.script
  $repo = $Item.repo
  $skill = $Item.skill
  
  $itemId = if ($skill) { "$repo#$skill" } else { "$script" }
  
  Write-Info "Installing: $itemId"
  
  if ($script) {
    try {
      Invoke-Expression "$script -g"
      if ($LASTEXITCODE -eq 0) {
        Write-Success $itemId
        return $true
      }
    } catch {
      Write-Warning "Script failed for $itemId, trying fallback..."
    }
  }
  
  if ($repo -and $skill) {
    try {
      npx skills add $repo --skill $skill -g
      if ($LASTEXITCODE -eq 0) {
        Write-Success $itemId
        return $true
      } else {
        Write-Error "Failed to install: $itemId"
        return $false
      }
    } catch {
      Write-Error "Failed to install: $itemId"
      return $false
    }
  } else {
    Write-Error "Missing repo or skill for fallback: $itemId"
    return $false
  }
}

if ($Help) {
  Write-Host "Usage: .\install.ps1 [-SkillListPath <path>]"
  Write-Host ""
  Write-Host "Options:"
  Write-Host "  -SkillListPath  Path to skill-list.json (default: ..\skill-list.json)"
  Write-Host "  -Help           Show this help message"
  exit 0
}

$os = if ($IsWindows -or ($env:OS -match "Windows")) { "windows" } else { "unknown" }
Write-Info "Detected OS: $os"

Write-Info "Checking dependencies..."
Test-Dependencies

Write-Info "Reading skill list from: $SkillListPath"
Test-SkillList

$config = Get-Content $SkillListPath -Raw | ConvertFrom-Json
$skillList = $config.skills

$total = 0
$ok = 0
$failed = 0
$failedItems = @()

foreach ($item in $skillList) {
  $total++
  if (Install-Skill -Item $item) {
    $ok++
  } else {
    $failed++
    $skillName = if ($item.skill) { $item.skill } else { "unknown" }
    $failedItems += $skillName
  }
}

Write-Host ""
Write-Host "================================"
Write-Info "Installation Summary"
Write-Host "================================"
Write-Host "  Total:   $total"
Write-Host "  `e[32mSuccess: $ok`e[0m"
Write-Host "  `e[31mFailed:  $failed`e[0m"

if ($failedItems.Count -gt 0) {
  Write-Host ""
  Write-Warning "Failed items: $($failedItems -join ', ')"
}

Write-Info "Log file: $LogFile"

if ($failed -gt 0) {
  exit 1
}