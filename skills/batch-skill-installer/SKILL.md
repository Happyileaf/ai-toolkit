---
name: batch-skill-installer
description: Quickly install a maintained list of skills with `npx skills add <repo> --skill <name>`. Use when a user asks to batch install a fixed skill pack, refresh that pack, or update the predefined install list.
---

# Batch Skill Installer

Maintain and install a predefined skill list from a JSON file.

## Quick Start

Choose the appropriate script for your platform:

| Platform | Script | Command |
|----------|--------|---------|
| macOS / Linux | Bash/Zsh | `./scripts/install.sh` |
| Windows | PowerShell | `.\scripts\install.ps1` |

## Maintained Skill List (JSON)

Maintain list in `skill-list.json`:

```json
{
  "skills": [
    {
      "script": "npx skills add https://github.com/vercel-labs/skills --skill find-skills",
      "repo": "https://github.com/vercel-labs/skills",
      "skill": "find-skills"
    }
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

## Scripts

Scripts are located in the `scripts/` folder:

- `install.sh` - Bash/Zsh script for macOS and Linux
- `install.ps1` - PowerShell script for Windows

Both scripts include:

- Dependency checking (npx, jq)
- Colored output
- Detailed logging
- Error handling with fallback
