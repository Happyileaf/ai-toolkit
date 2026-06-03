---
name: frontend-dev-env-bootstrap
description: 一键式搭建现代前端开发环境（macOS 13+ / Ubuntu/Debian），自动完成 zsh、nvm、Node.js LTS、pnpm、Git 的检测、安装、校验与结构化结果输出。
version: 1.0.0
entry: SKILL.md
status: active
type: skill
category: environment-setup
tags:
  - frontend
  - bootstrap
  - environment
  - macos
  - linux
dependencies: []
inputs:
  - target_components
  - node_version_policy
  - install_missing_brew
  - switch_default_shell
  - force_upgrade
  - dry_run
  - allow_sudo
outputs:
  - result
  - platform
  - installed_components
  - skipped_components
  - step_results
  - error
requires_tools: []
---

# Frontend Dev Env Bootstrap

用于在新机器或半新机器上幂等补齐前端开发环境。MVP 支持 `macOS 13+` 与 `Ubuntu/Debian (apt)`；Windows 在 MVP 中明确返回不支持。

## Triggers

- 用户要求“一键初始化前端开发环境”。
- 检测到 `zsh / nvm / node / pnpm / git` 任一缺失。
- 需要在新机器上批量复用同一套前端环境基线。

## Platform Scope (MVP)

- 支持: `macOS 13+`
- 支持: `Ubuntu 22.04+ / Debian 12+`（`apt` 路径）
- 不支持: `Windows`（返回 `E_PLATFORM_UNSUPPORTED`）

## Inputs

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|---|---|---|---|---|
| `target_components` | `array<string>` | 否 | `["zsh","nvm","node_lts","pnpm","git"]` | 目标组件清单 |
| `node_version_policy` | `string` | 否 | `lts` | Node 版本策略（MVP 仅支持 `lts`） |
| `install_missing_brew` | `boolean` | 否 | `true` | macOS 下缺少 brew 时是否自动安装 |
| `switch_default_shell` | `boolean` | 否 | `false` | 是否切换默认 shell 为 zsh |
| `force_upgrade` | `boolean` | 否 | `false` | 已安装组件是否强制升级 |
| `dry_run` | `boolean` | 否 | `false` | 仅输出计划，不做实际变更 |
| `allow_sudo` | `boolean` | 否 | `true` | 是否允许使用 sudo 执行提权步骤 |

## Outputs

| 输出 | 类型 | 说明 |
|---|---|---|
| `result` | `string` | `success \| partial \| failed` |
| `platform` | `string` | 检测到的平台与发行版 |
| `installed_components` | `array<string>` | 本次实际安装的组件 |
| `skipped_components` | `array<string>` | 已存在或按策略跳过的组件 |
| `step_results` | `array<object>` | 每一步状态、消息与时间戳 |
| `error` | `object \| null` | 失败时输出错误对象（code/message/remediation 等） |

## Error Codes

| Name | Code | 场景 |
|---|---:|---|
| `E_PLATFORM_UNSUPPORTED` | 10 | Windows 或非 MVP Linux 发行版 |
| `E_PKG_MANAGER_UNAVAILABLE` | 11 | 包管理器不可用且无法补齐 |
| `E_NETWORK_OFFLINE` | 20 | 需要下载时网络不可达 |
| `E_NO_PRIVILEGE` | 30 | 需要提权但无 sudo 或 `allow_sudo=false` |
| `E_INSTALL_FAILED` | 40 | 安装命令执行失败 |
| `E_VERIFY_FAILED` | 50 | 安装后命令/版本校验失败 |

## Workflow

1. 预检：平台、发行版、网络、权限、已有组件。
2. 按顺序执行：`pkg-manager -> zsh -> nvm -> node_lts -> pnpm -> git`。
3. 写入并去重 shell 配置（`NVM_DIR` 与 `nvm.sh` source 行）。
4. 执行 post-verify，输出结构化 JSON 结果。
5. 失败时输出 `failed_step/root_cause/remediation`，并返回对应错误码。

## Implementation Files

- 主脚本: `scripts/bootstrap.sh`
- Windows MVP 边界脚本: `scripts/bootstrap.ps1`
- 输出契约样例: `contracts/output.example.json`
- 验收脚本: `tests/acceptance.sh`
- 示例: `examples/`

## Acceptance Mapping

`tests/acceptance.sh` 覆盖并可验证以下场景：

- `M2`: macOS 半新机幂等
- `L2`: Linux 半新机幂等
- `M3`: macOS 无 sudo 失败（`E_NO_PRIVILEGE`）
- `M4`: macOS 离线失败（`E_NETWORK_OFFLINE`）
- `L3`: Linux 无 sudo 失败（`E_NO_PRIVILEGE`）
- `L4`: Linux 离线失败（`E_NETWORK_OFFLINE`）
- `W1`: Windows 明确失败（`E_PLATFORM_UNSUPPORTED`）

## Quick Start

```bash
cd skills/frontend-dev-env-bootstrap
./scripts/bootstrap.sh
```

仅演练不改动系统：

```bash
./scripts/bootstrap.sh --dry-run
```

运行验收（模拟模式）：

```bash
./tests/acceptance.sh
```

## Constraints

- 不安装 IDE，不安装项目依赖（`pnpm install` 不在本 skill 范围）。
- 不支持 Windows 自动安装（MVP 边界外）。
- 仅支持 `node_version_policy=lts`。

## Metadata

- Version: 1.0.0
- Owner: Skills Team
- Last Updated: 2026-06-03
- Tags: frontend, bootstrap, environment-setup, idempotent
