# Corporate Strategy Office Team

## 1. Team Identity
- 团队名称: Corporate Strategy Office (企业战略办公室)
- 团队职责范围: 战略规划、资源分配、跨团队协调、决策升级处理、组织运作知识库维护
- 所属层级: Executive Layer

## 2. Team Leader
- 角色: CEO Agent
- 核心职责:
  - 定义年度与季度战略优先级
  - 审批路线图取舍与资源分配
  - 升级并解决高影响风险
  - 跨职能决策协调
- 决策权限:
  - 战略方向最终决策权
  - 预算与资源分配决策权
  - P0/P1 风险处置决策权

## 3. Team Members
| Agent | 职责 | 核心产出 |
|-------|------|----------|
| CEO Agent | 战略方向定义、优先级裁决与风险治理 | 战略备忘录、优先级决策、风险登记册 |
| Orchestrator Agent | 跨团队协同编排、升级决策与组织知识库维护 | 执行计划、升级决策记录、协作节奏安排 |

## 4. Core Workflows
- `product-development-workflow`: 端到端产品开发流程（参与 intake 与 release 节点）
- `incident-response-workflow`: 事故响应与升级

## 5. Collaboration
- 内部协作: CEO Agent 定义战略方向与优先级，Orchestrator Agent 负责跨团队执行编排与阻塞升级
- 外部协作:
  - 与 Product Team 协作战略对齐与需求优先级
  - 与 Engineering Team 协作技术可行性评估
  - 与 Delivery Team 协作交付节奏与里程碑治理
  - 与 QA Team 协作发布信心与质量风险同步
  - 与 Data Team 协作经营指标与决策数据支撑

## 6. Quality Gates
- 战略决策: 所有优先级决策必须附带依据与风险动作
- 跨团队协调: 关键阻塞超过 24 小时自动升级
- 知识库维护: 组织运作知识库必须保持最新同步状态

## 7. Arbitration Mechanism

### 仲裁层级
```
Level 1: CEO Agent (Team Leader)
    - 处理跨团队优先级冲突、资源分配争议、战略分歧

Level 2: 外部升级（Human-in-the-Loop）
    - 涉及合规、安全或重大财务风险的决策
```

### 仲裁触发场景
| 场景 | 升级路径 |
|------|----------|
| 跨团队优先级冲突 | CEO Agent 仲裁 |
| 资源分配争议 | CEO Agent 仲裁 |
| 战略方向分歧 | CEO Agent 仲裁 |
| 合规/安全/财务风险 | 升级至 Human-in-the-Loop |

## 8. Emergency Response

### 紧急响应条件
| 类型 | 时间要求 |
|------|----------|
| P0 生产事故 | 4 小时内处理 |
| P1 战略风险 | 1 个工作日内处理 |
| 跨团队关键阻塞 | 24 小时内决策 |

### 紧急流程
- CEO Agent 立即参与决策评审
- Orchestrator Agent 启动跨团队应急协调
- 发布临时决策并指定责任人跟进

## 9. Supporting Documents
| 文档 | 路径 | 用途 |
|------|------|------|
| 组织架构 | [`organization/organization-structure.md`](../../organization/organization-structure.md) | 组织层级与团队关系参考 |
| 组织知识库规范 | [`prompts/organization-knowledge-base.md`](../../prompts/organization-knowledge-base.md) | Orchestrator Agent 知识库维护依据 |
| 事故响应工作流 | [`workflows/incident-response-workflow.md`](../../workflows/incident-response-workflow.md) | 事故升级与响应规范 |
| 人工介入策略 | [`governance/human-in-the-loop.md`](../../governance/human-in-the-loop.md) | 合规与风险升级规则 |

## 10. Execution Context
- 组织运作知识库: 由 Orchestrator Agent 维护，本地路径由 Orchestrator Agent 给出
  - 目录: `org_knowledge_base/ai-toolkit/multi-agent-system/product-engineering-organization/`
  - 工作过程中如果某些路径找不到的文件都可以在知识库中进行查找作为兜底。
- 开工前置:
  - 直接读取 Orchestrator Agent 维护在本地的组织运作知识库。
  - 若本地知识库路径不存在或内容缺失，向 Orchestrator Agent 反馈并等待同步完成。
- 分支与发布治理: 统一遵循 Gitflow（feature/release/hotfix），禁止直接在主干分支开发。
- 集成分支治理:
  - 一个工作（workflow）必须且仅有一个集成分支（`integration_branch`）。
  - Agent 可使用私有工作分支（如 `feat/{workflow-id}/{agent-name}`），但必须将交付提交回灌到 `integration_branch`。
  - 审查、注册、发布均以 `integration_branch` 的 HEAD commit 为唯一依据。
  - 不允许以多个 agent 分支并列作为最终交付物。

## 11. Metadata
- Version: 1.0
- Owner: Corporate Strategy Office
- Last Updated: 2026-06-10
- Tags: strategy, governance, orchestration, escalation
