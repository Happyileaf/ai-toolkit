# Example: Linux 离线失败（L4）

```bash
cd skills/frontend-dev-env-bootstrap

env \
  FDB_SIM_PLATFORM="linux" \
  FDB_SIM_DISTRIBUTION="ubuntu" \
  FDB_SIM_NETWORK="offline" \
  FDB_SIM_SUDO="available" \
  ./scripts/bootstrap.sh --simulate
echo "$?"
```

预期：
- 退出码为 `20`。
- 输出 JSON 中：
  - `result` 为 `failed`
  - `error.code` 为 `E_NETWORK_OFFLINE`
  - `error.remediation` 包含可执行恢复建议。
