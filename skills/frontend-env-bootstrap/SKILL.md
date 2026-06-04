---
name: frontend-env-bootstrap
description: 一键搭建 Windows/macOS/Linux 前端开发基础环境（git、nvm、Node LTS、pnpm、zsh），提供统一入口、结构化错误码、verify 验收与三件套产物。
version: 1.0.0
entry: SKILL.md
status: active
type: skill
category: environment-bootstrap
tags:
  - frontend
  - bootstrap
  - windows
  - macos
  - linux
dependencies: []
inputs:
  - target_platforms
  - shell_preference
  - node_lts_policy
  - install_git
  - install_zsh
  - network_mode
  - allow_elevation
  - idempotent_mode
outputs:
  - execution_summary.json
  - verification_report.json
  - human_log.txt
requires_tools: []
---

# Frontend Env Bootstrap

该 skill 提供统一入口与平台分发能力，按阶段执行：

1. `detect`
2. `preflight`
3. `bootstrap_pm`
4. `install_core`
5. `configure_shell`
6. `verify`
7. `finalize`

## 目录结构

```text
skills/frontend-env-bootstrap/
├── SKILL.md
├── _meta.json
├── docs/acceptance/frontend-env-bootstrap.md
├── scripts/
│   ├── bootstrap/
│   │   ├── run.sh
│   │   ├── run.ps1
│   │   ├── common.sh
│   │   ├── linux/adapter.sh
│   │   ├── macos/adapter.sh
│   │   └── windows/adapter.ps1
│   └── verify/
│       ├── run.sh
│       ├── run.ps1
│       ├── common.sh
│       ├── linux.sh
│       ├── macos.sh
│       └── windows.ps1
├── examples/
│   ├── linux-dry-run.sh
│   └── macos-dry-run.sh
└── tests/
    ├── test-cli.sh
    ├── test-error-codes.sh
    └── test-idempotency.sh
```

## 快速执行

macOS / Linux:

```bash
./skills/frontend-env-bootstrap/scripts/bootstrap/run.sh \
  --dry-run \
  --non-interactive \
  --platform auto \
  --output-dir ./skills/frontend-env-bootstrap/out
```

Windows PowerShell:

```powershell
.\skills\frontend-env-bootstrap\scripts\bootstrap\run.ps1 `
  -DryRun `
  -NonInteractive `
  -Platform auto `
  -OutputDir .\skills\frontend-env-bootstrap\out
```

## 核心能力

- 统一入口 + 平台分发（`run.(sh|ps1)`）
- 16 类标准错误码 + 结构化 JSON 错误输出
- verify 脚本（支持 `--format`、`--strict`、`--non-interactive`）
- 三件套产物：
  - `execution_summary.json`
  - `verification_report.json`
  - `human_log.txt`
- 支持 `dry-run` 与幂等复跑（3 次一致）

## 验收与测试

见 `docs/acceptance/frontend-env-bootstrap.md` 与 `tests/`。
