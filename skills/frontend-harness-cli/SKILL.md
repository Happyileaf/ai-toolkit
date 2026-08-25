---
name: frontend-harness
description: 初始化、维护和执行 frontend-harness 工作流时必须使用本 skill。适用于用户提到 frontend-harness、harness、初始化、持续拆任务、执行 feat、plan/build/qa/fix、quick fix、session_close、自动续跑、runtime 升级，或需要下发前端工程门禁（lint/typecheck/unit/build/e2e/a11y/响应式）来约束模型编码的场景。该 skill 生成独立闭环脚手架、任务存储、快速修复分流、会话收口与运行时升级工具。
argument-hint: "[项目名称] [项目描述]"
disable-model-invocation: false
user-invocable: true
---

# frontend-harness

`frontend-harness` 是一个独立 skill，用来给目标仓库安装并运行一套前端工程闭环：

```text
read task -> plan -> build -> qa -> fix -> mark_pass -> session_close
```

## 1. 意图判断

| 用户意图 | 常见说法 | 主要动作 |
|---|---|---|
| 初始化 harness | “初始化”“用 frontend-harness 初始化这个仓库” | 运行 `scripts/scaffold.py`，再执行 `.harness/scripts/init.sh` |
| 持续拆任务 | “持续拆任务”“拆 5 个任务” | 运行 `scripts/decompose_tasks.py`，默认新增 v3 单任务文件 |
| 执行某个任务 | “执行某个任务 ID”“继续当前任务” | 读取任务，按 plan/build/qa/agent-review/fix/mark_pass 闭环推进 |
| 快速修复小 bug | “quick fix”“修一个明确小 bug” | 先运行 `.harness/scripts/quick_fix_classifier.py`；high 走 quick-fix，medium/low 自动回标准闭环 |
| 会话收口 | “收口”“保存进度” | 运行 `.harness/scripts/session_close.py` |
| 自动续跑 | “继续下个任务” | 运行 `.harness/scripts/task_switch.py continue --target-dir .` |
| 老仓库升级 | “升级 harness”“更新脚手架” | 运行 `scripts/update_runtime.py` |

用户发起 frontend-harness 指令后，默认输入背景已确认。不要反复澄清；能从仓库和既有 spec/contract 推断时，直接给出假设、取舍、风险和范围外事项并继续执行。

## 2. 初始化目标仓库

```bash
python3 {{SKILL_PATH}}/scripts/scaffold.py \
  --project-name "<项目名称>" \
  --description "<项目目标>" \
  --tech-stack "<技术栈，可选>" \
  --project-type "<项目类型，可选>" \
  --design-guidance "<设计约束，可选>" \
  --target-dir "<项目目录>"
```

初始化后会生成：

- 根目录入口：`AGENTS.md`、`CLAUDE.md`
- Codex / Claude 配置：`.codex/`、`.claude/`
- Harness 工作区：`.harness/config/`、`.harness/docs/`、`.harness/scripts/`、`.harness/task-harness/`
- 任务索引：`.harness/task-harness/index.json`
- 运行时版本：`.harness/config/runtime-version.json`
- 更新策略：`.harness/config/update-policy.json`

如果仓库已存在 `AGENTS.md` 或 `CLAUDE.md`，初始化与升级都必须保留原内容，仅替换 managed block。

## 3. 任务存储模型

默认使用 v3 单任务文件：

- `.harness/task-harness/index.json`：稳定索引
- `.harness/task-harness/tasks/*.json` 与 `.harness/task-harness/tasks/**/*.json`：权威任务源
- `.harness/task-harness/progress/YYYY-MM/*.md`：会话进度分片
- `.harness/task-harness/progress/latest.txt`：legacy 快照（非权威）

## 4. 持续拆任务

```bash
python3 {{SKILL_PATH}}/scripts/decompose_tasks.py \
  --target-dir "<项目目录>" \
  --item "<任务描述1>" \
  --item "<任务描述2>" \
  --category "feature"
```

原则：

- 任务要面向“完整可验证功能切片”，不要按技术层碎拆。
- 同一功能的页面、状态、接口对接、样式、测试，默认放在同一个任务 `steps`。
- 只有可独立发布/验证/回滚的子项才拆单独任务。

## 5. 执行任务闭环

1. 定位任务（优先任务 ID）
2. 读取任务定义（description/steps/spec_path/contract_path/qa_report_path）
3. Plan（生成/更新 spec）
4. Build（严格按 contract 实现）
5. QA Gate（`qa_runner.py` + convention-check + agent review）
6. Fix（最多 3 轮）
7. Mark pass（required 门禁通过且 spec/contract 落盘）
8. Session close（写进度分片）

## 6. Quick Fix 分流

进入前必须先分类：

```bash
python3 .harness/scripts/quick_fix_classifier.py --target-dir . --prompt "<bug 描述>"
```

- `high + quick_fix`：走 quick-fix
- `medium`：自动回标准闭环
- `low` 或 `standard_feature`：必须走标准闭环

执行后必须 post-diff 复核：

```bash
python3 .harness/scripts/quick_fix_classifier.py --target-dir . --phase post-diff --prompt "<bug 描述>"
```

quick-fix 只写日志，不得直接把 feature 置为 `passes=true`。

## 7. 会话收口与续跑

标准收口：

```bash
python3 .harness/scripts/session_close.py \
  --target-dir . \
  --feature-id "<task-id>" \
  --outcome "pass|fail|blocked|in-progress" \
  --qa-score "<0-100，可选>" \
  --note "<本轮摘要>"
```

继续下个任务：

```bash
python3 .harness/scripts/task_switch.py continue --target-dir .
```

## 8. 老仓库升级

```bash
python3 {{SKILL_PATH}}/scripts/update_runtime.py --target-dir "<项目目录>"
```

支持：备份、版本迁移、远程 manifest 检查与 checksum 校验。

## 9. 前端工程门禁

前端项目默认门禁包括：

- `convention-check`（前端规则）
- lint
- typecheck
- unit test
- build
- e2e（按 contract required/advisory/manual）
- Agent Review Closeout（默认 advisory，可升 required）

Required 门禁失败时禁止 `passes=true`。

## 10. 回报格式

执行完成后简要回报：

- 做了什么
- 改了哪里
- 验证结果
- 下一步建议

## 11. 典型提示词

- `用 frontend-harness 初始化这个仓库，项目名 xxx，目标是 xxx`
- `持续拆任务 主题：结算页重构，拆 4 个`
- `执行 B001-T003，严格按 read task -> plan -> build -> qa -> fix -> mark_pass`
- `quick-fix 修复一个明确小 bug，先分类，修完后 quick close`
- `把当前会话收口，记录 QA 分数和下一步`
- `升级这个项目里的 frontend-harness runtime`
