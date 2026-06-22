---
name: skill-evolution-workflow
description: 从反馈收集到 Skill 更新的持续演进流程，确保 Skill 持续优化。
version: 1.0.0
entry: WORKFLOW.md
status: active
type: workflow
category: skill-management
tags:
  - skill
  - evolution
  - improvement
  - feedback-loop
dependencies:
  - ../../agents/skills-team/skills-evolution-agent.md
  - ../../agents/skills-team/skills-refactor-agent.md
  - ../../agents/skills-team/skills-review-agent.md
  - ../../agents/skills-team/skills-librarian-agent.md
  - ../../agents/skills-team/skills-team-orchestrator-agent.md
steps:
  - steps/01-feedback-collection.md
  - steps/02-analysis.md
  - steps/03-proposal.md
  - steps/04-review.md
  - steps/05-release.md
inputs:
  - feedback_sources
  - skill_id
  - update_type
outputs:
  - update_proposal
  - updated_skill_files
  - evolution_log
requires_agents:
  - Evolution Agent
  - Refactor Agent
  - Review Agent
  - Librarian Agent
  - Skill Orchestrator Agent
---

# Workflow: Skill Evolution

## Purpose

从反馈收集到 Skill 更新的持续演进流程，确保 Skill 持续优化。

## Agents Involved

| 步骤 | 负责 Agent | 主要产出 |
|------|-----------|----------|
| Feedback Collection | Evolution Agent | 反馈数据聚合 |
| Analysis | Evolution Agent | 根因分析、改进点 |
| Proposal | Evolution Agent / Refactor Agent | 更新提案 |
| Review | Review Agent | 质量审计 |
| Release | Librarian Agent | 版本发布 |

## Required Inputs

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `feedback_sources` | array | 是 | 反馈来源: `pr` / `bug` / `incident` / `user_feedback` |
| `skill_id` | string | 是 | 目标 Skill ID |
| `update_type` | string | 否 | 更新类型: `patch` / `minor` / `major` |

## Execution Flow

详细步骤见：

- `./steps/01-feedback-collection.md` - 反馈收集
- `./steps/02-analysis.md` - 根因分析
- `./steps/03-proposal.md` - 更新提案
- `./steps/04-review.md` - 质量审计
- `./steps/05-release.md` - 版本发布

## Update Type Rules

| 类型 | 条件 | 版本变更 |
|------|------|----------|
| `patch` | Bug 修复、文档补充、小优化 | x.x.+1 |
| `minor` | 新功能、向后兼容的增强 | x.+1.0 |
| `major` | 破坏性变更、接口重构 | +1.0.0 |

## Emergency Mode

安全问题触发紧急发布流程，跳过正常排期，24 小时内完成。

详见: `./skill-emergency-release-workflow/WORKFLOW.md`

## State Model

```
feedback_collection → analysis → proposal → review → release
                          │          │
                          └──────────┘
                    (可触发 Refactor)
```

## Copy-Paste Input Template

```text
请按 workflow 入口文件执行：
./workflows/skill-evolution-workflow/WORKFLOW.md

输入参数：
- feedback_sources: [bug, user_feedback]
- skill_id: SKILL-003
- update_type: patch
- feedback_data:
    bug_reports:
      - id: BUG-001
        description: "选择器不稳定导致偶发失败"
        frequency: 3次/周
    user_feedback:
      - "示例不够清晰"
      - "缺少错误处理说明"
```

## Output Contract

最终输出必须包含：

1. `update_proposal`: 更新提案
2. `updated_skill_files`: 更新后的文件清单
3. `evolution_log`: 演进日志