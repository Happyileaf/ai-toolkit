# {{PROJECT_NAME}} Agent 指南

本项目采用 Frontend Harness 工作流。在 Codex 中，请将此文件视为 `Plan -> Build -> Verify` 的执行契约。

## 快速开始（Codex）

可使用以下任一意图：

1. `plan <功能描述>`
2. `build <spec 文件或最新 spec>`
3. `qa <contract 文件或最新 contract>`
4. `sprint <功能描述>`（完整周期）

## Codex 意图路由

| 意图 | 触发示例 | 必要动作 | 必要输出 |
|---|---|---|---|
| `plan` | “plan checkout ui”, “write spec for X” | 自动归纳假设/歧义、检查相关代码、编写 spec | `.harness/docs/specs/<feature>.md` |
| `build` | “build latest spec”, “implement header redesign” | 读取 spec+contract，按范围实现并自检 | 代码改动 + 冲刺报告 |
| `qa` | “qa latest contract”, “evaluate feature X” | 读取 contract，执行 QA Gate、Agent Review Closeout 并逐条评分 | 结构化 QA 报告 + result JSON + 分数 |
| `sprint` | “sprint build dashboard filters” | 依次执行 plan+contract+build+qa+fix | spec + contract + 实现 + 报告 |
| `quick-fix` | “修一个明确小 bug”, “quick fix hydration 报错” | 先运行 quick-fix 分类器；high 走轻量修复，medium/low 自动回到 sprint | 代码改动 + 定向验证 + quick close 日志 |

## 执行契约

### 行为门禁

- 开始 plan/build/qa 前，必须显式列出本轮的假设、歧义、取舍和范围外事项；默认用户输入已确认，不反复澄清。
- 默认选择满足验收标准的最小实现；禁止隐式扩范围、顺手重构、相邻格式化。
- 每个改动文件都必须能追溯到 spec/contract 的范围、验收标准或修复项。
- 只清理本次改动制造的问题，不主动处理无关历史问题。

### Plan 契约

- 不允许编写实现代码。
- Spec 至少包含：
  - 假设、歧义、取舍、范围外事项
  - 问题陈述、用户故事、组件边界
  - 可机器验证的验收标准
  - 依赖与风险
  - 至少 3 个边界场景
  - 响应式、可访问性、性能预算要求（如适用）
- 保存路径：`.harness/docs/specs/<feature-name>.md`

### Build 契约

- 读取 `.harness/docs/specs/` 与 `.harness/docs/contracts/`。
- 若 contract 缺失或关键信息不全，先补齐再实现。
- 只允许实现 contract 范围内内容。
- 前端实现前确认：
  - 设计 token / 变量复用策略
  - 加载态、空态、错误态
  - 断点与响应式策略
  - 关键交互可键盘访问
- 交付前必须自检：
  - lint/typecheck/unit/build/e2e（按 contract 要求）
  - 验收标准逐条核对
  - 无调试残留

### QA 契约

- 评分只依据 contract 标准。
- 每条标准状态仅允许：`PASS` / `FAIL` / `PARTIAL`。
- 评分公式：`score = (pass + 0.5 * partial) / total * 100`
- QA 结果按门禁级别生效：`required` 阻塞通过，`advisory` / `manual` 用于质量跟踪与人工确认。
- 若 contract 含 required 集成矩阵，必须运行：

```bash
python3 .harness/scripts/qa_runner.py --target-dir . --contract <contract-file>
```

- QA Runner 默认在 convention-check 与前端检查后触发 Agent Review Closeout（`auto`）。

### Sprint 契约

- 顺序必须严格遵守：
  1. Plan
  2. Contract
  3. Build
  4. QA
  5. Fix loop（必要时）
  6. 文档新鲜度检查
- Fix loop 最大迭代：`3`。
- 若 3 轮后仍失败：记录失败项，保持 `passes=false`，继续下一个任务。

### Quick Fix 契约

- 进入前必须运行：

```bash
python3 .harness/scripts/quick_fix_classifier.py --target-dir . --prompt "<bug 描述>"
```

- 仅允许明确、小、可验证修复，且 diff 受控（文件数/行数阈值）。
- quick-fix 不得把 feature 的 `passes` 置为 `true`。

## 操作规则

- 先 spec 后代码，先 contract 后 build。
- `passes=true` 前必须有真实的 `spec_path` 与 `contract_path`。
- 一次只做一个 sprint。
- 可用命令自动续跑下个任务（当前分支）：

```bash
python3 .harness/scripts/task_switch.py continue --target-dir .
```

## 与 Task Harness 的集成（可选）

- 优先选择 `passes=false` 且优先级最高的任务。
- 严格执行 `plan -> contract -> build -> qa -> fix`。
- required 门禁通过后才可更新 `passes=true`。
- 通过 `.harness/scripts/session_close.py` 写入独立进度日志。

## 项目布局

- `AGENTS.md`：Codex 执行入口
- `CLAUDE.md`：Claude 执行入口
- `.codex/hooks/`：Codex hooks
- `.claude/hooks/`：Claude hooks
- `.harness/docs/specs/`：功能规格
- `.harness/docs/contracts/`：冲刺契约
- `.harness/docs/qa/`：QA 报告与结果
- `.harness/task-harness/tasks/`：v3 权威任务目录
- `.harness/scripts/qa_runner.py`：前端 QA 主入口

## 技术栈

- 项目：`{{PROJECT_NAME}}`
- 类型：`{{PROJECT_TYPE}}`
- 技术栈：`{{TECH_STACK}}`
