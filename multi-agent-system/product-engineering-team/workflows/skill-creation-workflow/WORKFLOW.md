---
name: skill-creation-workflow
description: 从需求发现到 Skill 发布的完整创建流程，确保 Skill 质量达标并符合规范。
version: 1.0.0
entry: WORKFLOW.md
status: active
type: workflow
category: skill-management
tags:
  - skill
  - creation
  - lifecycle
  - quality-gate
dependencies:
  - ../../agents/skills-team/discovery-agent.md
  - ../../agents/skills-team/design-agent.md
  - ../../agents/skills-team/generation-agent.md
  - ../../agents/skills-team/review-agent.md
  - ../../agents/skills-team/librarian-agent.md
  - ../../agents/skills-team/skill-orchestrator-agent.md
steps:
  - steps/01-discovery.md
  - steps/02-design.md
  - steps/03-generation.md
  - steps/04-review.md
  - steps/05-registration.md
  - steps/06-release.md
inputs:
  - source_type
  - source_data
  - priority
  - constraints
outputs:
  - skill_id
  - skill_files
  - quality_score
  - release_record
requires_agents:
  - Discovery Agent
  - Design Agent
  - Generation Agent
  - Review Agent
  - Librarian Agent
  - Skill Orchestrator Agent
---

# Workflow: Skill Creation

## Purpose

从需求发现到 Skill 发布的完整创建流程，确保 Skill 质量达标并符合规范。

该工作流由 **Skill Orchestrator Agent** 调度，依次执行各步骤。

## Agents Involved

| 步骤 | 负责 Agent | 主要产出 |
|------|-----------|----------|
| Discovery | Discovery Agent | Skill 提案 |
| Design | Design Agent | 设计文档、接口契约 |
| Generation | Generation Agent | SKILL.md、元数据、示例 |
| Review | Review Agent | 质量报告、评分 |
| Registration | Librarian Agent | 注册记录、索引更新 |
| Release | Librarian Agent | 发布公告、变更日志 |

## Required Inputs

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `source_type` | string | 是 | 来源类型: `user_request` / `pattern_discovery` / `product_input` |
| `source_data` | object | 是 | 来源数据（日志、代码、需求文档等） |
| `priority` | string | 否 | 优先级: `P0` / `P1` / `P2`，默认 `P1` |
| `constraints` | array | 否 | 约束条件 |

## Execution Flow

详细步骤见：

- `./steps/01-discovery.md` - 需求发现与提案
- `./steps/02-design.md` - 架构设计与契约定义
- `./steps/03-generation.md` - 文件生成与自检
- `./steps/04-review.md` - 质量审计与评分
- `./steps/05-registration.md` - 注册与索引更新
- `./steps/06-release.md` - 发布与公告

严格按上述顺序执行。

## Quality Gates

| 门禁 | 条件 | 失败处理 |
|------|------|----------|
| 设计评审 | Review Agent 签署通过 | 返回 Design Agent 修改 |
| 生成验证 | 质量评分 >= 80 分 | 返回 Generation Agent 修复 |
| 发布审批 | 无阻塞问题 + Librarian 签署 | 拒绝发布 |

## State Model

```
discovery → design → generation → review → registration → release
    │          │          │           │
    └──────────┴──────────┴───────────┘
              (可回退重试)
```

## Failure Handling

| 场景 | 处理策略 |
|------|----------|
| Discovery 数据不足 | 标记"观察期"，设置复查时间 |
| Design 边界模糊 | 返回 Discovery 补充，最多 2 次重试 |
| Generation 规范冲突 | 标记问题，请求规则更新 |
| Review 评分 < 80 | 返回 Generation 修复，最多 3 次重试 |
| Review 连续 3 次失败 | 升级至 Librarian Agent 仲裁 |
| Registration 依赖冲突 | 召集 Design Agent 协调 |
| Release 发布失败 | 执行回滚并记录故障 |

## Copy-Paste Input Template

```text
请按 workflow 入口文件执行：
./workflows/skill-creation-workflow/WORKFLOW.md

输入参数：
- source_type: user_request
- source_data:
    user_logs: [最近 30 天用户请求日志]
    frequency: 5次/周
    scenario: "用户频繁请求 UI 原型对比功能"
- priority: P1
- constraints:
  - 不依赖外部付费服务
  - 支持离线执行
```

## Output Contract

最终输出必须包含：

1. `skill_id`: Skill 唯一标识（格式: `SKILL-XXX`）
2. `skill_files`: 文件清单（SKILL.md、_meta.json、examples/）
3. `quality_score`: 质量评分（0-100）
4. `release_record`: 发布记录（版本、时间、变更日志）