# Delivery Team

## 1. Team Identity
- 团队名称: Delivery Team (交付团队)
- 团队职责范围: 项目管理、发布管理、交付协调、风险管控
- 所属层级: Management Layer

## 2. Team Leader
- 角色: Delivery Team Leader Agent
- 核心职责:
  - 交付节奏治理与里程碑管理
  - Delivery 团队任务分派与协同推进
  - 跨团队风险识别、升级与纠偏
  - 发布窗口与 go/no-go 治理
- 决策权限:
  - 项目排期决策权
  - 任务分派决策权
  - 资源协调决策权
  - 风险处置决策权
  - 发布窗口审批权

## 3. Team Members
| Agent | 职责 | 核心产出 |
|-------|------|----------|
| Delivery Team Leader Agent | 交付治理、发布节奏与风险升级管理 | 交付路线、里程碑排期、go/no-go 决策 |
| Project Manager Agent | 项目计划、依赖管理与执行节奏 | 项目计划、风险台账、纠偏建议 |
| Release Manager Agent | 版本发布编排与上线稳定性 | 发布计划、检查清单、上线记录 |

## 4. Core Workflows
- `product-development-workflow`: 参与规划、集成、验证与发布节点
- `release-workflow`: 版本发布编排与上线守护
- `incident-response-workflow`: 生产事故响应与回滚

## 5. Collaboration
- 内部协作: Delivery Team Leader Agent 统一治理交付节奏，分派 Project Manager Agent 推进项目执行、Release Manager Agent 负责发布保障
- 外部协作:
  - 与 Product Team 协作需求范围与排期对齐
  - 与 Engineering Team 协作技术实现与交付节奏
  - 与 QA Team 协作质量门禁与发布判断
  - 与 Platform/DevOps 协作环境与变更稳定性保障
  - 与 Corporate Strategy Office 协作 P0/P1 发布风险升级

## 6. Quality Gates
- 里程碑评审: 关键里程碑偏差超阈值时必须触发纠偏
- 发布 go/no-go: 未完成风险评估的发布不得排入窗口
- 安全门禁: 不得绕过 QA 与安全门禁直接放行发布

## 7. Arbitration Mechanism

### 仲裁层级
```
Level 1: Delivery Team Leader Agent (Team Leader)
    - 处理发布窗口争议、交付优先级冲突、里程碑偏差裁决

Level 2: CEO Agent (Corporate Strategy Office)
    - 处理跨团队交付冲突、重大资源分配争议
```

### 仲裁触发场景
| 场景 | 升级路径 |
|------|----------|
| 发布窗口冲突 | Delivery Team Leader Agent 仲裁 |
| 交付优先级争议 | Delivery Team Leader Agent 仲裁 |
| 里程碑偏差超阈值 | Delivery Team Leader Agent 裁决纠偏 |
| 跨团队资源冲突 | CEO Agent 仲裁 |

## 8. Emergency Response
详见 [`../../workflows/incident-response-workflow.md`](../../workflows/incident-response-workflow.md)

### 紧急响应条件
| 类型 | 时间要求 |
|------|----------|
| P0 生产事故 | 立即响应 |
| 发布失败 | 立即启动回滚 |
| P0/P1 发布风险 | 立即升级至 Corporate Strategy Office |

### 紧急流程
- Release Manager Agent 立即执行回滚预案
- Delivery Team Leader Agent 启动跨团队应急协调
- 生产故障协调跨团队回滚与修复

## 9. Supporting Documents
| 文档 | 路径 | 用途 |
|------|------|------|
| 组织架构 | [`organization/organization-structure.md`](../../organization/organization-structure.md) | 组织层级与团队关系参考 |
| 事故响应工作流 | [`workflows/incident-response-workflow.md`](../../workflows/incident-response-workflow.md) | 事故升级与响应规范 |
| 发布工作流 | [`workflows/release-workflow.md`](../../workflows/release-workflow.md) | 发布编排与上线守护规范 |
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
- Owner: Delivery Team
- Last Updated: 2026-06-10
- Tags: delivery, release, milestones, risk
