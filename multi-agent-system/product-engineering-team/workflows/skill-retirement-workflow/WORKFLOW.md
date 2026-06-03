---
name: skill-retirement-workflow
description: Skill 退役与迁移流程，确保平稳过渡与数据清理。
version: 1.0.0
entry: WORKFLOW.md
status: active
type: workflow
category: skill-management
tags:
  - skill
  - retirement
  - migration
  - cleanup
dependencies:
  - ../../agents/skills-team/skills-librarian-agent.md
  - ../../agents/skills-team/skills-refactor-agent.md
  - ../../agents/skills-team/skills-team-orchestrator-agent.md
steps:
  - steps/01-request.md
  - steps/02-dependency-check.md
  - steps/03-announcement.md
  - steps/04-execution.md
  - steps/05-cleanup.md
inputs:
  - skill_id
  - retirement_reason
  - migration_plan
outputs:
  - retirement_record
  - migration_guide
  - cleanup_report
requires_agents:
  - Librarian Agent
  - Refactor Agent
  - Skill Orchestrator Agent
---

# Workflow: Skill Retirement

## Purpose

Skill 退役与迁移流程，确保平稳过渡与数据清理。

## Agents Involved

| 步骤 | 负责 Agent | 主要产出 |
|------|-----------|----------|
| Request | Librarian Agent | 退役请求验证 |
| Dependency Check | Refactor Agent | 依赖影响分析 |
| Announcement | Librarian Agent | 公告发布 |
| Execution | Librarian Agent | 退役执行 |
| Cleanup | Librarian Agent | 数据清理 |

## Required Inputs

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `skill_id` | string | 是 | 待退役 Skill ID |
| `retirement_reason` | string | 是 | 退役原因: `deprecated` / `replaced` / `unused` / `security` |
| `migration_plan` | object | 否 | 迁移方案（如有替代 Skill） |

## Execution Flow

详细步骤见：

- `./steps/01-request.md` - 退役请求
- `./steps/02-dependency-check.md` - 依赖检查
- `./steps/03-announcement.md` - 公告发布
- `./steps/04-execution.md` - 退役执行
- `./steps/05-cleanup.md` - 数据清理

## Retirement Reasons

| 原因 | 说明 | 公告周期 |
|------|------|----------|
| `deprecated` | 功能过时，有更好替代 | 2 周 |
| `replaced` | 被新 Skill 替代 | 2 周 |
| `unused` | 使用率极低 | 1 周 |
| `security` | 安全风险无法修复 | 立即 |

## Migration Plan Template

```yaml
migration_plan:
  replacement_skill: SKILL-XXX
  migration_steps:
    - step: "替换依赖引用"
      description: "将 SKILL-OLD 替换为 SKILL-XXX"
    - step: "更新输入参数"
      description: "参数映射说明"
  compatibility_notes: "主要差异说明"
```

## State Model

```
request → dependency_check → announcement → execution → cleanup
              │
              └─ 有依赖 → 等待依赖解除
```

## Copy-Paste Input Template

```text
请按 workflow 入口文件执行：
./workflows/skill-retirement-workflow/WORKFLOW.md

输入参数：
- skill_id: SKILL-002
- retirement_reason: replaced
- migration_plan:
    replacement_skill: SKILL-006
    migration_steps:
      - step: "替换依赖引用"
        description: "将 ui-audit 替换为 ui-gap-audit"
    compatibility_notes: "新 Skill 输出格式更结构化"
```

## Output Contract

最终输出必须包含：

1. `retirement_record`: 退役记录
2. `migration_guide`: 迁移指南（如有）
3. `cleanup_report`: 清理报告