# Frontend Env Bootstrap 验收标准

## 1. 目标范围

- 平台：Windows 10+/11、macOS 12+、Linux（Debian/Ubuntu、RHEL 系）
- 工具：`git`、`nvm`、`Node LTS`、`pnpm`、`zsh`（Windows 默认 skip）
- 执行形态：统一入口 + 平台分发 + verify + 三件套产物

## 2. 必测命令

### 2.1 Dry-run 非交互执行

```bash
./skills/frontend-env-bootstrap/scripts/bootstrap/run.sh \
  --dry-run \
  --non-interactive \
  --platform auto \
  --output-dir ./skills/frontend-env-bootstrap/out
```

### 2.2 Verify 严格模式

```bash
./skills/frontend-env-bootstrap/scripts/verify/run.sh \
  --platform auto \
  --strict \
  --non-interactive \
  --output-dir ./skills/frontend-env-bootstrap/out
```

## 3. 验收检查项

1. 统一入口与平台分发可执行。
2. 16 类错误码完整可枚举，且失败时输出结构化 JSON 错误对象。
3. 产物三件套齐全：
   - `execution_summary.json`
   - `verification_report.json`
   - `human_log.txt`
4. `--dry-run` 与 `--non-interactive` 可组合执行。
5. 连续 3 次 dry-run 复跑，`idempotency_signature` 一致。
6. verify 报告包含 git/node/pnpm/nvm/PATH 检查结果。

## 4. 已知限制（首版）

1. 非 dry-run 的真实安装依赖系统权限、网络与平台包管理器状态。
2. Windows 运行路径需 PowerShell 7+，并执行 `.ps1` 入口。
3. 首版对 Linux 发行版仅承诺 Debian/Ubuntu 与 RHEL 系主路径。
