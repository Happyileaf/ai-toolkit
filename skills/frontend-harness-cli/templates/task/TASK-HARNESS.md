# {{项目名称}} - TASK-HARNESS 任务层执行规则

本文件是任务层契约，负责“任务拆分与进度追踪”。  
根目录 `AGENTS.md` 管理 `Plan -> Build -> Verify` 主闭环，两者必须同时遵循。

## 工件定位（技术方案 / 测试计划 / 验证结果）

- 技术方案：`spec_path`（通常 `.harness/docs/specs/<task-id>.md`）
- 测试计划与验收标准：`contract_path`（通常 `.harness/docs/contracts/<task-id>.md`）
- 测试结果：`qa_report_path`（通常 `.harness/docs/qa/<task-id>.md`）

## 会话启动（必须按顺序）

1. 运行 `bash .harness/scripts/init.sh`
2. 阅读 `AGENTS.md` / `CLAUDE.md`
3. 阅读 `.harness/docs/TASK-HARNESS.md`
4. 阅读 `.harness/task-harness/index.json`
5. 阅读目标单任务文件
6. 阅读 `.harness/task-harness/progress/YYYY-MM/*.md`
7. 选择优先级最高且 `passes=false` 的 1 个任务

## 闭环执行契约

针对选中的单个任务，严格按顺序执行：

1. `read task`
2. `plan`
3. `build`
4. `qa gate`
5. `fix`（最多 3 轮）
6. `mark_pass`

`mark_pass` 前提：
- required 门禁通过
- `spec_path` / `contract_path` 文件真实存在
- required Agent Review（如启用）无 accepted/actionable finding

## 前端专项门禁

- 响应式：桌面与移动关键断点可用
- 交互流：加载态、空态、错误态覆盖
- 可访问性：键盘可达、语义标签、图片 alt
- 样式一致性：优先 token/CSS 变量，避免散落魔法值
- QA 命令链：`convention-check + lint + typecheck + unit + build + e2e + agent review`

## Quick Fix 分流（明确小 bug）

先运行分类器：

```bash
python3 .harness/scripts/quick_fix_classifier.py --target-dir . --prompt "<bug 描述>"
```

规则：
- `recommended_mode=quick_fix` 且 `confidence=high`：可轻量修复
- `confidence=medium`：自动回标准闭环
- `recommended_mode=standard_feature` 或 `confidence=low`：必须回标准闭环

quick-fix 约束：
- 修改不超过 3 个文件
- post-diff 不超过 100 行
- 不涉及高风险路径（安全、计费、核心鉴权、公共契约、数据一致性）
- quick-fix 仅写进度日志，不得直接改 `passes=true`

## 任务清单修改规则

任务 JSON 仅允许修改：
- `status: todo|doing|done`
- `passes: false -> true`（必须满足门禁）

禁止修改：
- `id/category/priority/description/file/spec_path/contract_path/qa_report_path/steps/verification`

## 会话结束前必须完成

1. 写入进度日志：`.harness/task-harness/progress/YYYY-MM/<timestamp>-<feature-id>.md`
2. 门禁通过后更新 `passes=true`
3. 执行 `session_close.py`
4. 输出下一步建议

## 续跑

```bash
python3 .harness/scripts/task_switch.py continue --target-dir .
```

## 项目信息

- 项目：`{{项目名称}}`
- 描述：`{{项目描述，一句话概括目标和范围}}`
