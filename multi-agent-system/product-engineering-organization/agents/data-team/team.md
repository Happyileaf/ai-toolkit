# Data Team

## 1. Team Identity
- 团队名称: Data Team (数据团队)
- 团队职责范围: 数据分析、商业智能、数据治理、数据产品支撑
- 所属层级: Functional Layer

## 2. Team Leader
- 角色: Data Team Leader Agent
- 核心职责:
  - 数据需求优先级治理与任务分派
  - 指标口径一致性与数据质量治理
  - BI/分析交付节奏管理
  - 跨团队数据协同与升级处理
- 决策权限:
  - 数据优先级决策权
  - 数据源优先级决策权
  - 数据治理标准制定权
  - 分析报告发布审批权

## 3. Team Members
| Agent | 职责 | 核心产出 |
|-------|------|----------|
| Data Team Leader Agent | 数据需求治理、口径一致性与分析交付管理 | 需求优先级清单、口径决策记录、交付验收结论 |
| BI Agent | 数据看板与经营指标可视化 | BI 看板、指标字典、异常解读 |
| Data Analyst Agent | 数据分析与业务问题拆解 | 分析报告、指标解释、决策建议 |

## 4. Core Workflows
- `product-development-workflow`: 参与需求分析与效果验证节点，提供数据支撑
- 数据需求响应流程: 从业务问题到分析交付的闭环

## 5. Collaboration
- 内部协作: Data Team Leader Agent 统一接收需求并分派给 BI Agent 与 Data Analyst Agent，审核交付物口径一致性
- 外部协作:
  - 与 Product Team 协作业务问题定义与指标映射
  - 与 Engineering/Platform Team 协作数据链路稳定性治理
  - 与 Design Team 协作数据可视化体验
  - 与 Corporate Strategy Office 协作经营指标与决策数据支撑

## 6. Quality Gates
- 口径一致性: 核心指标口径冲突事件 = 0
- 交付验收: 分析报告必须可追溯到数据来源与计算逻辑
- 发布阻断: 口径未统一或来源不可追溯的分析结论默认阻断发布

## 7. Arbitration Mechanism

### 仲裁层级
```
Level 1: Data Team Leader Agent (Team Leader)
    - 处理口径争议、数据源优先级冲突、分析结论分歧

Level 2: CEO Agent (Corporate Strategy Office)
    - 处理跨团队数据优先级冲突、重大口径治理分歧
```

### 仲裁触发场景
| 场景 | 升级路径 |
|------|----------|
| 指标口径争议 | Data Team Leader Agent 仲裁 |
| 数据源优先级冲突 | Data Team Leader Agent 协调 |
| 分析结论分歧 | Data Team Leader Agent 仲裁 |
| 跨团队数据优先级冲突 | CEO Agent 仲裁 |

## 8. Emergency Response

### 紧急响应条件
| 类型 | 时间要求 |
|------|----------|
| 核心指标异常 | 4 小时内响应 |
| 关键数据源故障 | 4 小时内启动应急降级 |
| 经营复盘数据缺失 | 1 个工作日内补齐 |

### 紧急流程
- Data Team Leader Agent 优先插队处理关键数据异常
- 触发应急降级并同步风险给相关团队
- 口径争议无法收敛时升级至 Corporate Strategy Office 裁决

## 9. Supporting Documents
| 文档 | 路径 | 用途 |
|------|------|------|
| 组织架构 | [`organization/organization-structure.md`](../../organization/organization-structure.md) | 组织层级与团队关系参考 |
| 人工介入策略 | [`governance/human-in-the-loop.md`](../../governance/human-in-the-loop.md) | 合规与风险升级规则 |
| 契约 Schema | [`schemas/schema-registry.json`](../../schemas/schema-registry.json) | 组织级 schema 索引与数据结构验证 |

## 10. Execution Context
- 组织运行知识库: 由 Knowledge Team 提供服务，Knowledge Sync Agent 负责克隆同步与路径管理。
  - 目录: `org_knowledge_base/ai-toolkit/multi-agent-system/product-engineering-organization/`
  - 工作过程中如果某些路径找不到的文件都可以在知识库中进行查找作为兜底。
- 开工前置:
  - 通过 Knowledge Sync Agent 获取知识库真实本地路径与同步状态。
  - 若本地知识库路径不存在或内容缺失，向 Knowledge Team 反馈并等待同步完成或内容补充。
- 分支与发布治理: 统一遵循 GitHub Flow（feature/bugfix/hotfix 直接合入 main），禁止直接在主干分支开发。
- 集成分支治理:
  - 一个工作（workflow）必须且仅有一个集成分支（`integration_branch`）。
  - Agent 可使用私有工作分支（如 `feat/{workflow-id}/{agent-name}`），但必须将交付提交回灌到 `integration_branch`。
  - 审查、注册、发布均以 `integration_branch` 的 HEAD commit 为唯一依据。
  - 不允许以多个 agent 分支并列作为最终交付物。

## 11. Metadata
- Version: 1.0
- Owner: Data Team
- Last Updated: 2026-06-10
- Tags: data, analytics, bi, governance
