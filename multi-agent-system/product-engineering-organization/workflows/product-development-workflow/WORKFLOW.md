---
name: product-development-workflow
description: 面向生产环境的端到端产品研发工作流，覆盖需求治理、设计、开发、测试、发布与复盘。
version: 2.3.0
entry: WORKFLOW.md
status: active
type: workflow
category: product-engineering
tags:
  - product
  - engineering
  - delivery
  - quality-gate
  - release
dependencies:
  - ../../agents/corporate-strategy-office/orchestrator-agent.md
  - ../../agents/platform-team/workflow-orchestrator-agent.md
  - ../../agents/platform-team/memory-manager-agent.md
  - ../../agents/product-team/product-team-leader-agent.md
  - ../../agents/product-team/product-manager-agent.md
  - ../../agents/product-team/requirement-analyst-agent.md
  - ../../agents/product-team/user-research-agent.md
  - ../../agents/design-team/design-team-leader-agent.md
  - ../../agents/design-team/ux-agent.md
  - ../../agents/design-team/ui-design-agent.md
  - ../../agents/engineering-team/engineering-team-leader-agent.md
  - ../../agents/engineering-team/architect-agent.md
  - ../../agents/engineering-team/frontend-engineer-agent.md
  - ../../agents/engineering-team/backend-engineer-agent.md
  - ../../agents/engineering-team/ai-engineer-agent.md
  - ../../agents/engineering-team/code-review-agent.md
  - ../../agents/engineering-team/devops-agent.md
  - ../../agents/quality-assurance-team/quality-assurance-team-leader-agent.md
  - ../../agents/quality-assurance-team/quality-assurance-agent.md
  - ../../agents/quality-assurance-team/security-agent.md
  - ../../agents/quality-assurance-team/performance-agent.md
  - ../../agents/delivery-team/project-manager-agent.md
  - ../../agents/delivery-team/release-manager-agent.md
  - ../../agents/data-team/data-team-leader-agent.md
  - ../../agents/data-team/data-analyst-agent.md
  - ../../agents/data-team/bi-agent.md
steps:
  - steps/01-intake-triage.md
  - steps/02-discovery-specification.md
  - steps/03-ui-ux-design-review.md
  - steps/04-technical-solution-design.md
  - steps/05-planning-kickoff.md
  - steps/06-implementation-self-test.md
  - steps/07-integration-code-review.md
  - steps/08-system-verification.md
  - steps/09-release-readiness.md
  - steps/10-production-release.md
  - steps/11-post-release-retrospective.md
inputs:
  - initiative_brief
  - business_goals
  - target_users
  - constraints
  - compliance_requirements
  - delivery_deadline
  - risk_level
outputs:
  - workflow_id
  - prd_package
  - ui_ux_design_package
  - solution_design_package
  - delivery_plan
  - engineering_delivery
  - qa_verdict
  - release_decision
  - release_record
  - post_release_report
  - retrospective_action_log
requires_agents:
  - Workflow Orchestrator Agent
  - Product Team Leader Agent
  - Product Manager Agent
  - Requirement Analyst Agent
  - Design Team Leader Agent
  - Architect Agent
  - Engineering Team Leader Agent
  - Quality Assurance Team Leader Agent
  - Release Manager Agent
  - DevOps Agent
  - Data Team Leader Agent
---

# Workflow: Product Development

## Purpose

构建一套生产级、完整、可执行的产品研发主流程，确保从需求进入到上线复盘全链路可追踪、可审计、可回滚。

该流程由 **Workflow Orchestrator Agent** 编排执行，默认串行主干 + 有界并行子任务模式。

## Agents Involved

| 步骤 | 负责 Agent | 主要产出 |
|------|-----------|----------|
| Intake & Triage | Product Team Leader Agent | 立项记录、风险台账 |
| Discovery & Specification | Product Manager Agent | PRD 包、验收标准 |
| UI/UX Design & Review | Design Team Leader Agent | 交互方案、视觉规格、设计评审结论 |
| Technical Solution Design | Architect Agent | 技术架构、接口契约、ADR |
| Planning & Kickoff | Engineering Team Leader Agent | 迭代计划、任务分派、里程碑 |
| Implementation & Self-Test | Frontend/Backend/AI Engineer Agents | 代码交付、单测报告 |
| Integration & Code Review | Code Review Agent | 评审结论、集成引用 |
| System Verification | QA Team Leader Agent | 测试报告、安全与性能结论 |
| Release Readiness | Release Manager Agent | Go/No-Go 决策 |
| Production Release | DevOps Agent | 发布记录、健康报告 |
| Post-Release Retrospective | Data Team Leader Agent | 结果复盘、改进动作 |

## Required Inputs

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `initiative_brief` | object | 是 | 立项背景、问题定义、业务价值 |
| `business_goals` | array | 是 | 目标指标与目标值 |
| `target_users` | object | 是 | 目标用户群体与关键场景 |
| `constraints` | array | 否 | 技术、资源、时间等约束 |
| `compliance_requirements` | array | 否 | 合规、安全、审计要求 |
| `delivery_deadline` | string | 否 | 目标交付日期 |
| `risk_level` | string | 否 | `low` / `medium` / `high`，默认 `medium` |

## Branching & Artifact Baseline

- 工作流启动时必须创建唯一 `integration_branch`（示例: `feature/product-WF-2026-001`）。
- 允许各工程 Agent 使用私有开发分支，但提交进入评审前必须回灌到 `integration_branch`。
- 所有质量结论与发布动作必须绑定同一交付引用链路：`integration_base_sha -> reviewed_ref -> released_ref`。
- 建议统一产物目录：`artifacts/product-development/{workflow_id}/`，每步生成结构化文件（JSON/YAML/Markdown）。

## Execution Flow

详细步骤见：

- `./steps/01-intake-triage.md` - 立项与分级
- `./steps/02-discovery-specification.md` - 需求发现与规格冻结
- `./steps/03-ui-ux-design-review.md` - UI&UX 设计与评审
- `./steps/04-technical-solution-design.md` - 技术方案设计与评审
- `./steps/05-planning-kickoff.md` - 研发计划与启动
- `./steps/06-implementation-self-test.md` - 实现与自测
- `./steps/07-integration-code-review.md` - 集成与代码评审
- `./steps/08-system-verification.md` - 系统级验证
- `./steps/09-release-readiness.md` - 发布就绪评审
- `./steps/10-production-release.md` - 生产发布与守护
- `./steps/11-post-release-retrospective.md` - 上线验证与复盘

## Quality Gates

| 门禁 | 条件 | 失败处理 |
|------|------|----------|
| G0 立项准入 | 目标、范围、owner、里程碑完整 | 返回 Step 01 补齐 |
| G1 需求准入 | PRD 冻结 + 可测试验收标准 100% | 返回 Step 02 |
| G2 体验方案准入 | UI/UX 评审通过 + 关键体验风险可控 | 返回 Step 03 |
| G3 技术方案准入 | 架构评审通过 + 关键技术风险可控 | 返回 Step 04 |
| G4 开发准入 | 任务 owner/截止时间完整 + DoD 明确 | 返回 Step 05 |
| G5 质量准入 | P0/P1 缺陷为 0 + 安全高危 0 + 性能达标 | 返回 Step 06-08 修复 |
| G6 发布准入 | Go 决策通过 + 回滚方案演练完成 | 返回 Step 09 |
| G7 稳定性准入 | 发布后关键指标稳定且无阻塞级事故 | 触发 Step 10 回滚/补救 |

## State Model

```text
intake
  -> discovery_spec
  -> ui_ux_design_review
  -> technical_solution_design
  -> planning_kickoff
  -> implementation
  -> integration_review
  -> system_verification
  -> release_readiness
  -> production_release
  -> post_release_retrospective
  -> completed

任何步骤失败 -> 回退到定义的 failure_step（有界重试）-> 重新进入主干。
```

## Retry & Escalation Policy

- 单步骤默认最多重试 2 次，超过阈值自动升级至对应 Team Leader。
- 连续 3 次仍失败，升级至 **Orchestrator Agent** 做范围/排期/资源裁决。
- `high` 风险项目出现安全或生产稳定性阻塞时，直接升级到 Corporate Strategy Office。

## Failure Handling

| 场景 | 处理策略 |
|------|----------|
| 需求证据不足 | 暂停开发，返回 Discovery 补充研究 |
| 架构分歧未收敛 | 输出选项矩阵，升级 Architect + Orchestrator 仲裁 |
| UI/UX 评审未通过 | 返回 UI&UX 设计步骤补齐交互/视觉/无障碍问题 |
| 质量门禁失败 | 强制修复并回归验证，不允许带阻塞缺陷发布 |
| 发布后指标劣化 | 触发灰度停止或回滚，启动 incident-response-workflow |
| 关键结论不可追溯 | 标记审计失败，阻断后续步骤 |

## Copy-Paste Input Template

```text
请按 workflow 入口文件执行：
./workflows/product-development-workflow/WORKFLOW.md

输入参数：
- initiative_brief:
    title: "提升新用户激活率"
    problem_statement: "新用户 7 日激活率低于目标"
    expected_business_impact: "激活率提升 20%"
- business_goals:
    - metric: activation_rate_d7
      current: 0.32
      target: 0.38
- target_users:
    segment: "首次注册用户"
    platforms: ["web", "ios", "android"]
- constraints:
    - "必须兼容现有账号体系"
    - "两周内可发布 MVP"
- compliance_requirements:
    - "日志脱敏"
    - "账号安全策略不降级"
- delivery_deadline: "2026-06-30"
- risk_level: medium
```

## Output Contract

最终输出必须包含：

1. `workflow_id`: 流程唯一标识（示例: `WF-PD-2026-001`）
2. `prd_package`: PRD 与验收标准包
3. `ui_ux_design_package`: UI/UX 设计与评审包
4. `solution_design_package`: 技术架构方案包
5. `delivery_plan`: 任务排期、owner、里程碑
6. `engineering_delivery`: 交付回执（含 `integration_branch` 与 `integrated_head_sha`）
7. `qa_verdict`: 质量门禁结果（含安全/性能）
8. `release_decision`: 发布决策（Go/No-Go）
9. `release_record`: 发布记录与 `released_ref`
10. `post_release_report`: 指标验证与用户反馈总结
11. `retrospective_action_log`: 复盘改进项（owner + due_date）

## Machine-Readable Schema Contract

- 组织级封装标准：`../../schemas/organization/artifact-envelope.schema.json`
- 工作流步骤产物标准：`../../schemas/workflows/product-development/product-development-step-artifact.schema.json`
- 组织级 schema 索引：`../../schemas/schema-registry.json`
- 规范文档：`../../governance/machine-readable-artifact-standard.md`

所有 Step 产物在跨 Agent 交接时，必须使用统一 envelope 结构：

```json
{
  "artifact_type": "pd-01-intake-output",
  "artifact_meta": {
    "schema_id": "workflow.product-development.step-artifact",
    "schema_version": "v1",
    "workflow_id": "WF-PD-2026-001",
    "step_id": "pd-01",
    "generated_at": "2026-06-10T09:00:00Z",
    "generated_by": "Product Team Leader Agent",
    "source_ref": "a1b2c3d4"
  },
  "data": {}
}
```
