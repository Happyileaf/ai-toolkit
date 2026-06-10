# Platform Team

## 1. Team Identity
- 团队名称: Platform Team (平台团队)
- 团队职责范围: 基础设施、记忆管理、工作流编排、平台稳定性
- 所属层级: Infrastructure Layer

## 2. Team Leader
- 角色: Platform Team Leader Agent
- 核心职责:
  - 平台优先级治理与任务分派
  - 编排与记忆能力协同治理
  - 平台稳定性、容量与SLO管理
  - 平台架构演进与风险控制
- 决策权限:
  - 平台优先级决策权
  - 资源分配决策权
  - 工作流调度策略决策权
  - 平台架构变更审批权
  - 故障处理优先级决策权

## 3. Team Members
| Agent | 职责 | 核心产出 |
|-------|------|----------|
| Platform Team Leader Agent | 平台能力治理与稳定性管理 | 平台路线图、分派结果、风险评估、放行结论 |
| Workflow Orchestrator Agent | 多 Agent 工作流执行协调 | 路由计划、状态日志、完成摘要 |
| Memory Manager Agent | 多 Agent 上下文质量的记忆生命周期管理 | 检索上下文包、记忆健康报告、保留与裁剪动作 |

## 4. Core Workflows
- `product-development-workflow`: 提供工作流编排与记忆上下文支撑
- `skill-creation-workflow`: 提供 Skill 注册与工作流编排基础设施
- `skill-evolution-workflow`: 提供 Skill 演进的工作流编排支撑
- `skill-retirement-workflow`: 提供 Skill 退役的工作流编排支撑

## 5. Collaboration
- 内部协作: Platform Team Leader Agent 统一治理平台优先级，分派 Workflow Orchestrator Agent 负责工作流编排、Memory Manager Agent 负责上下文管理
- 外部协作:
  - 与 Engineering/Delivery 团队协作平台变更窗口与风险同步
  - 与 QA Team 协作平台级质量门禁
  - 与 Skills Team 协作工作流集成与 Skill 编排
  - 与 Corporate Strategy Office 协作 P0/P1 平台事件升级

## 6. Quality Gates
- SLO 巡检: 平台可用性 >= 99.9%
- 变更评审: 未通过风险评估与回滚校验的变更不得上线
- 容量评估: 不得绕过容量评估直接提升负载
- 事件审计: 平台事件处理必须保留审计轨迹与复盘记录

## 7. Arbitration Mechanism

### 仲裁层级
```
Level 1: Platform Team Leader Agent (Team Leader)
    - 处理编排优先级冲突、记忆资源分配争议、平台变更分歧

Level 2: CEO Agent (Corporate Strategy Office)
    - 处理重大平台架构决策分歧、跨团队基础设施冲突
```

### 仲裁触发场景
| 场景 | 升级路径 |
|------|----------|
| 编排优先级冲突 | Platform Team Leader Agent 仲裁 |
| 记忆资源分配争议 | Platform Team Leader Agent 协调 |
| 平台变更分歧 | Platform Team Leader Agent 仲裁 |
| 重大平台架构决策 | CEO Agent 仲裁 |

## 8. Emergency Response

### 紧急响应条件
| 类型 | 时间要求 |
|------|----------|
| P0 平台故障 | 立即进入应急流程并冻结非关键发布 |
| 容量风险持续上升 | 触发降级策略并升级管理层 |
| 变更失败 | 立即执行回滚并输出复盘整改计划 |

### 紧急流程
- Platform Team Leader Agent 立即进入应急流程
- 冻结非关键发布并优先处置风险
- P0/P1 平台事件立即升级至 Corporate Strategy Office
- 变更失败执行回滚并组织复盘

## 9. Supporting Documents
| 文档 | 路径 | 用途 |
|------|------|------|
| 组织架构 | [`organization/organization-structure.md`](../../organization/organization-structure.md) | 组织层级与团队关系参考 |
| 记忆架构 | [`memory/memory-architecture.md`](../../memory/memory-architecture.md) | 记忆系统设计参考 |
| 可观测性 | [`infra/observability.md`](../../infra/observability.md) | 平台监控与可观测性规范 |
| 人工介入策略 | [`governance/human-in-the-loop.md`](../../governance/human-in-the-loop.md) | 合规与风险升级规则 |

## 10. Execution Context
- 权威仓库: `git@github.com:Happyileaf/ai-toolkit.git`
- 团队工作根目录: `multi-agent-system/product-engineering-organization/`
- 开工前置:
  - 若本地不存在仓库，先 clone 到工作目录。
  - 若本地已存在仓库，先 pull 最新默认分支。
  - 后续任务仅在该仓库内执行。
- 分支与发布治理: 统一遵循 Gitflow（feature/release/hotfix），禁止直接在主干分支开发。
- 集成分支治理:
  - 一个工作（workflow）必须且仅有一个集成分支（`integration_branch`）。
  - Agent 可使用私有工作分支（如 `agent/{agent-name}/{workflow-id}`），但必须将交付提交回灌到 `integration_branch`。
  - 审查、注册、发布均以 `integration_branch` 的 HEAD commit 为唯一依据。
  - 不允许以多个 agent 分支并列作为最终交付物。
- 工作过程中如果某些路径找不到的文件都可以在仓库中进行查找作为兜底。

## 11. Metadata
- Version: 1.0
- Owner: Platform Team
- Last Updated: 2026-06-10
- Tags: platform, orchestration, memory, reliability
