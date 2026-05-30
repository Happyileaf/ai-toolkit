---
name: batch-skill-installer
description: Quickly install a maintained list of skills with `npx skills add <repo> --skill <name>`. Use when a user asks to batch install a fixed skill pack, refresh that pack, or update the predefined install list.
---

# Batch Skill Installer

Maintain and install a predefined skill list from a JSON file.

## Maintained Skill List (JSON)

Maintain list in `skill-list.json` in the same folder:

```json
{
  "skills": [
    {
      "script": "npx skills add https://github.com/vercel-labs/skills --skill find-skills",
      "repo": "https://github.com/vercel-labs/skills",
      "skill": "find-skills"
    },
  ]
}
```

Field rules:

- `script`: full install command (preferred)
- `repo` + `skill`: fallback source when `script` fails

Keep both for each item whenever possible.

## Install Workflow

1. Read and parse `skill-list.json`.
2. For each item, run `script` first when present.
3. If `script` fails, fallback to:

```bash
npx skills add <repo> --skill <skill>
```

4. If one item still fails, continue installing the rest and report failures clearly.
5. At the end, summarize installed and failed items.

## PowerShell Batch Command Template (Read JSON)

Use this template for fast execution:

```powershell
$skillListPath = Join-Path (Get-Location) "skill-list.json"
$config = Get-Content -Raw -LiteralPath $skillListPath | ConvertFrom-Json
$skillList = $config.skills

$ok = @()
$failed = @()

foreach ($item in $skillList) {
  $itemId = if ($item.skill) { "$($item.repo)#$($item.skill)" } else { "$($item.script)" }
  $installed = $false

  if ($item.script) {
    try {
      Invoke-Expression $item.script
      if ($LASTEXITCODE -eq 0) {
        $ok += $itemId
        $installed = $true
      }
    } catch {
      # fallback below
    }
  }

  if ($installed) { continue }

  if (-not $item.repo -or -not $item.skill) {
    $failed += $itemId
    continue
  }

  try {
    npx skills add $item.repo --skill $item.skill
    if ($LASTEXITCODE -eq 0) {
      $ok += $itemId
    } else {
      $failed += $itemId
    }
  } catch {
    $failed += $itemId
  }
}

Write-Host "Installed:" ($ok -join ", ")
Write-Host "Failed:" ($failed -join ", ")
```
