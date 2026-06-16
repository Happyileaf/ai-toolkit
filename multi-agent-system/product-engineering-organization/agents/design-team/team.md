# Design Team

## 1. Team Identity
- 团队名称: Design Team (设计团队)
- 团队职责范围: 用户体验设计、界面设计、设计规范、设计评审
- 所属层级: Functional Layer

## 2. Team Leader
- 角色: Design Team Leader Agent
- 核心职责:
  - 设计策略治理与体验标准制定
  - UX/UI 任务分派与节奏协调
  - 跨产品线设计一致性治理
  - 设计评审与体验门禁把控
- 决策权限:
  - 体验标准定义权
  - 设计任务分派决策权
  - 设计规范制定权
  - 设计方案评审权
  - 体验问题优先级决策权

## 3. Team Members
| Agent | 职责 | 核心产出 |
|-------|------|----------|
| Design Team Leader Agent | 设计治理、体验门禁与设计评审管理 | 设计评审结论、体验风险清单、设计放行意见 |
| UX Agent | 交互体验与信息架构设计 | 用户流程图、线框图、交互说明、可用性建议 |
| UI Design Agent | 视觉设计与设计系统一致性 | 视觉稿、组件规范、样式说明、验收意见 |

## 4. Core Workflows
- `product-development-workflow`: 参与 UI/UX 设计评审节点，提供设计交付与门禁放行

## 5. Collaboration
- 内部协作: Design Team Leader Agent 统一接收需求并分派 UX Agent 负责交互流程、UI Design Agent 负责视觉规范，组织评审并把控体验门禁
- 外部协作:
  - 与 Product Team 协作需求优先级和体验目标
  - 与 Engineering Team 协作实现可行性与前端还原
  - 与 QA Team 协作设计验收与视觉还原度验证
  - 与 Data Team 协作体验指标与用户行为数据

## 6. Quality Gates
- 设计评审: 关键流程设计评审一次通过率 >= 85%
- 体验门禁: 设计门禁未通过不得进入发布准备
- 可用性验证: 缺失异常态与边界态定义的方案不得放行

## 7. Arbitration Mechanism

### 仲裁层级
```
Level 1: Design Team Leader Agent (Team Leader)
    - 处理设计方案冲突、体验优先级争议、规范分歧

Level 2: Delivery Team Leader Agent
    - 处理设计与交付节奏冲突

Level 3: CEO Agent (Corporate Strategy Office)
    - 处理战略级体验决策分歧
```

### 仲裁触发场景
| 场景 | 升级路径 |
|------|----------|
| UX 与 UI 方案冲突 | Design Team Leader Agent 仲裁 |
| 设计规范分歧 | Design Team Leader Agent 仲裁 |
| 设计与交付节奏冲突 | Delivery Team Leader Agent 仲裁 |
| 战略级体验决策分歧 | CEO Agent 仲裁 |

## 8. Emergency Response

### 紧急响应条件
| 类型 | 时间要求 |
|------|----------|
| 关键流程体验风险未收敛 | 阻断上线并立即推动修正 |
| 设计与实现严重冲突 | 1 个工作日内输出替代方案 |
| 发布前设计缺陷 | 当日完成评审与修正 |

### 紧急流程
- Design Team Leader Agent 阻断上线并推动修正
- 输出分层替代方案并升级决策
- 关键流程体验风险升级至 Delivery Team

## 9. Supporting Documents
| 文档 | 路径 | 用途 |
|------|------|------|
| 组织架构 | [`organization/organization-structure.md`](../../organization/organization-structure.md) | 组织层级与团队关系参考 |
| 人工介入策略 | [`governance/human-in-the-loop.md`](../../governance/human-in-the-loop.md) | 合规与风险升级规则 |

## 10. Execution Context
- 组织运行知识库: 由 Knowledge Team 提供服务，Knowledge Sync Agent 负责克隆同步与路径管理。
  - 目录: `org_knowledge_base/ai-toolkit/multi-agent-system/product-engineering-organization/`
  - 工作过程中如果某些路径找不到的文件都可以在知识库中进行查找作为兜底。
- 开工前置:
  - 通过 Knowledge Sync Agent 获取知识库真实本地路径与同步状态。
  - 若本地知识库路径不存在或内容缺失，向 Knowledge Team 反馈并等待同步完成或内容补充。
- 分支与发布治理: 统一遵循 GitHub Flow（feature/bugfix/hotfix 直接合入 main），禁止直接在主干分支开发。
- 工作流分支治理（GitHub Flow 对齐）:
  - 每个 workflow 启动时从 `main` 创建唯一工作流分支（`integration_branch`），该分支是 **workflow-scoped feature branch**，最终通过 PR 合入 `main` 并删除——不是 GitFlow 的长期 develop 分支。
  - Agent 可使用私有工作分支（如 `feat/{workflow-id}/{agent-name}`），但交付前必须回灌到 `integration_branch`。
  - 审查、注册、发布均以 `integration_branch` 的 HEAD commit 为唯一依据；不允许以多个 agent 分支并列作为最终交付物。

## 11. Metadata
- Version: 1.0
- Owner: Design Team
- Last Updated: 2026-06-10
- Tags: design, ux, ui, quality-gate
