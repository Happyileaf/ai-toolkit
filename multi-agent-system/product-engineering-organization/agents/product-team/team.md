# Product Team

## 1. Team Identity
- 团队名称: Product Team (产品团队)
- 团队职责范围: 需求发现、产品规划、PRD编写、验收标准定义
- 所属层级: Functional Layer

## 2. Team Leader
- 角色: Product Team Leader Agent
- 核心职责:
  - 需求优先级治理与范围控制
  - Product 团队任务分派与排期协调
  - 验收口径一致性管理
  - 跨团队需求对齐与冲突处理
- 决策权限:
  - 需求优先级决策权
  - 任务分派与排期决策权
  - 发布范围决策权
  - 需求变更审批权

## 3. Team Members
| Agent | 职责 | 核心产出 |
|-------|------|----------|
| Product Team Leader Agent | 需求治理、范围控制与跨团队对齐 | 需求队列、分派计划、范围变更决策 |
| Product Manager Agent | 功能定义与交付规划 | PRD、用户故事、验收标准、优先级 Backlog |
| Requirement Analyst Agent | 需求澄清与规格化分析 | 需求规格说明书、追踪矩阵、变更影响报告 |
| User Research Agent | 用户洞察与行为研究 | 研究计划、洞察报告、机会清单、验证结论 |

## 4. Core Workflows
- `product-development-workflow`: 参与 intake triage、discovery specification、UI/UX 设计评审等核心节点

## 5. Collaboration
- 内部协作: Product Team Leader Agent 统一治理需求优先级并分派任务，Product Manager Agent 负责 PRD 与验收标准，Requirement Analyst Agent 负责需求拆解，User Research Agent 负责用户证据
- 外部协作:
  - 与 Corporate Strategy Office 协作战略对齐与业务优先级
  - 与 Engineering Team 协作需求可行性与技术约束
  - 与 Design Team 协作体验目标与交互定义
  - 与 QA Team 协作验收标准与质量门禁
  - 与 Delivery Team 协作排期与发布范围

## 6. Quality Gates
- 需求准入: 不满足可测试验收标准的需求不得进入开发排期
- 范围控制: Sprint 期间需求范围波动率 <= 10%
- 变更审批: 未完成影响评估的范围变更不得生效
- 需求追踪: 所有需求决策必须可追溯至目标与证据

## 7. Arbitration Mechanism

### 仲裁层级
```
Level 1: Product Team Leader Agent (Team Leader)
    - 处理需求优先级争议、范围冲突、验收标准分歧

Level 2: CEO Agent (Corporate Strategy Office)
    - 处理跨团队优先级冲突、战略级需求分歧
```

### 仲裁触发场景
| 场景 | 升级路径 |
|------|----------|
| 需求优先级争议 | Product Team Leader Agent 仲裁 |
| 范围冲突 | Product Team Leader Agent 仲裁 |
| 验收标准分歧 | Product Team Leader Agent 仲裁 |
| 跨团队优先级冲突 | CEO Agent 仲裁 |

## 8. Emergency Response

### 紧急响应条件
| 类型 | 时间要求 |
|------|----------|
| P1 范围冲突 | 24 小时内升级到 Corporate Strategy Office |
| 需求证据不足 | 要求补充研究后再排期 |
| 范围持续膨胀 | 立即收缩到可发布最小范围并重排 |

### 紧急流程
- Product Team Leader Agent 立即收缩范围到可发布最小集
- 按目标对齐结果触发升级裁决
- 跨团队优先级冲突升级至 Corporate Strategy Office

## 9. Supporting Documents
| 文档 | 路径 | 用途 |
|------|------|------|
| 组织架构 | [`organization/organization-structure.md`](../../organization/organization-structure.md) | 组织层级与团队关系参考 |
| PRD 模板 | [`templates/prd-template.md`](../../templates/prd-template.md) | Product Manager Agent 产出模板 |
| 人工介入策略 | [`governance/human-in-the-loop.md`](../../governance/human-in-the-loop.md) | 合规与风险升级规则 |
| 契约 Schema | [`schemas/schema-registry.json`](../../schemas/schema-registry.json) | 组织级 schema 索引与数据结构验证 |

## 10. Execution Context
- 组织运作知识库: 由 Orchestrator Agent 维护，本地路径参见 `prompts/organization-knowledge-base.md`
- 团队工作根目录: `multi-agent-system/product-engineering-organization/`
- 开工前置:
  - 直接读取 Orchestrator Agent 维护在本地的组织运作知识库，无需自行 clone/pull 仓库。
  - 若本地知识库路径不存在或内容缺失，向 Orchestrator Agent 反馈并等待同步完成。
- 分支与发布治理: 统一遵循 Gitflow（feature/release/hotfix），禁止直接在主干分支开发。
- 集成分支治理:
  - 一个工作（workflow）必须且仅有一个集成分支（`integration_branch`）。
  - Agent 可使用私有工作分支（如 `agent/{agent-name}/{workflow-id}`），但必须将交付提交回灌到 `integration_branch`。
  - 审查、注册、发布均以 `integration_branch` 的 HEAD commit 为唯一依据。
  - 不允许以多个 agent 分支并列作为最终交付物。
- 工作过程中如果某些路径找不到的文件都可以在仓库中进行查找作为兜底。

## 11. Metadata
- Version: 1.0
- Owner: Product Team
- Last Updated: 2026-06-10
- Tags: product, requirements, prioritization, scope-control
