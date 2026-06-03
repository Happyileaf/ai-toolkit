# Acceptance Tests

运行命令：

```bash
cd skills/frontend-dev-env-bootstrap
./tests/acceptance.sh
```

覆盖矩阵：`M2/L2/M3/M4/L3/L4/W1`。

说明：
- 默认通过 `--simulate` 执行，可在任意开发机稳定复现验收结果。
- 若本机有 `pwsh`，会额外校验 `scripts/bootstrap.ps1` 的 Windows 边界输出契约。
