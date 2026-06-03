# Example: macOS 幂等二次执行（M2）

```bash
cd skills/frontend-dev-env-bootstrap

TMP_HOME="$(mktemp -d)"
STATE_FILE="${TMP_HOME}/sim-state.txt"

env \
  HOME="${TMP_HOME}" \
  FDB_SIM_PLATFORM="macos" \
  FDB_SIM_DISTRIBUTION="macos-13" \
  FDB_SIM_NETWORK="online" \
  FDB_SIM_SUDO="available" \
  FDB_SIM_INITIAL_COMPONENTS="zsh,git" \
  ./scripts/bootstrap.sh --simulate --state-file "${STATE_FILE}"

env \
  HOME="${TMP_HOME}" \
  FDB_SIM_PLATFORM="macos" \
  FDB_SIM_DISTRIBUTION="macos-13" \
  FDB_SIM_NETWORK="online" \
  FDB_SIM_SUDO="available" \
  FDB_SIM_INITIAL_COMPONENTS="zsh,git" \
  ./scripts/bootstrap.sh --simulate --state-file "${STATE_FILE}"
```

预期：
- 第一次执行 `result=success`，`installed_components` 非空。
- 第二次执行 `result=success`，`installed_components=[]`，组件全部出现在 `skipped_components`。
- `${TMP_HOME}/.zshrc` 内 `export NVM_DIR="$HOME/.nvm"` 仅一行（无重复注入）。
