# Knowledge Team

## 1. Team Identity
- 团队名称: Knowledge Team (知识管理团队)
- 团队职责范围: 组织运行知识库的维护、同步、内容质量审核与服务提供
- 所属层级: Infrastructure Layer

## 2. Team Leader
- 角色: Knowledge Team Leader Agent
- 核心职责:
  - 知识库治理决策与内容质量标准制定
  - 团队任务分派与节奏协调
  - 跨团队知识库服务对接与升级处理
  - 知识库版本演进与淘汰策略治理
- 决策权限:
  - 知识库内容准入/淘汰决策权
  - 知识库服务质量标准制定权
  - 知识库同步优先级决策权
  - 团队任务分派决策权

## 3. Team Members
| Agent | 职责 | 核心产出 |
|-------|------|----------|
| Knowledge Team Leader Agent | 知识库治理决策与跨团队服务对接 | 治理决策记录、内容质量标准、服务协议 |
| Knowledge Curator Agent | 内容整理、质量审核与文档规范治理 | 内容审核结论、文档规范检查结果、缺失文档清单 |
| Knowledge Sync Agent | 知识库克隆、同步与路径管理 | 同步状态报告、本地真实路径、同步异常告警 |

## 4. Core Workflows
- `product-development-workflow`: 提供知识库服务支撑，确保各团队可获取权威组织文档
- 知识库维护流程: 初始化、定时同步、内容审核、缺失补充、过期淘汰

## 5. Collaboration
- 内部协作: Knowledge Team Leader Agent 统一治理知识库标准与准入决策，分派 Knowledge Curator Agent 负责内容整理与质量审核、Knowledge Sync Agent 负责技术层面的克隆同步与路径管理
- 外部协作:
  - 与所有团队协作知识库服务提供——各团队通过 Knowledge Sync Agent 获取路径与同步状态，通过 Knowledge Curator Agent 反馈内容缺失或质量问题
  - 与 Platform Team 协作基础设施（Git 仓库）与同步稳定性
  - 与 Corporate Strategy Office 协作战略级文档准入与治理升级

## 6. Quality Gates
- 内容准入: 文档必须符合组织文档规范方可纳入知识库
- 同步时效: 知识库本地副本与远程仓库偏差不超过 1 小时
- 路径可用性: 所有 Agent 请求知识库路径时必须在 5 分钟内响应
- 内容完整性: 缺失文档必须在 2 个工作日内补充或标记为已知缺失

## 7. Arbitration Mechanism

### 仲裁层级
```
Level 1: Knowledge Team Leader Agent (Team Leader)
    - 处理内容准入争议、同步优先级冲突、服务质量分歧

Level 2: CEO Agent (Corporate Strategy Office)
    - 处理战略级文档治理分歧、跨团队知识库服务冲突
```

### 仲裁触发场景
| 场景 | 升级路径 |
|------|----------|
| 内容准入争议 | Knowledge Team Leader Agent 仲裁 |
| 同步优先级冲突 | Knowledge Team Leader Agent 协调 |
| 服务质量分歧 | Knowledge Team Leader Agent 仲裁 |
| 战略级文档治理分歧 | CEO Agent 仲裁 |

## 8. Emergency Response

### 紧急响应条件
| 类型 | 时间要求 |
|------|----------|
| 知识库同步完全失败 | 1 小时内启动应急恢复 |
| 多团队反馈路径不可用 | 30 分钟内响应并排查 |
| 关键组织文档缺失 | 4 小时内补充或提供替代方案 |

### 紧急流程
- Knowledge Sync Agent 立即排查同步故障并尝试恢复
- Knowledge Team Leader Agent 评估影响范围并升级通知
- 路径不可用时提供应急访问方案（直接引用远程仓库）

## 9. Supporting Documents
| 文档 | 路径 | 用途 |
|------|------|----------|
| 组织架构 | [`organization/organization-structure.md`](../../organization/organization-structure.md) | 组织层级与团队关系参考 |
| 知识库管理服务协议 | [`docs/organization-knowledge-base-management.md`](../../docs/organization-knowledge-base-management.md) | Knowledge Team 知识库服务协议 |
| 人工介入策略 | [`governance/human-in-the-loop.md`](../../governance/human-in-the-loop.md) | 合规与风险升级规则 |

## 10. Execution Context
- 组织运行知识库: 由 Knowledge Team 提供服务，Knowledge Sync Agent 负责克隆同步与路径管理。
  - 仓库: `git@github.com:Happyileaf/ai-toolkit.git`
  - 目录: `org_knowledge_base/ai-toolkit/multi-agent-system/product-engineering-organization/`
  - 所有团队可通过 Knowledge Sync Agent 获取知识库本地真实路径与同步状态。
  - 工作过程中如果某些路径找不到的文件都可以在知识库中进行查找作为兜底。
- 开工前置:
  - Knowledge Sync Agent 初始化并同步组织运行知识库。
  - 若本地知识库路径不存在或内容缺失，Knowledge Curator Agent 负责追踪并补充缺失内容。
- 分支与发布治理: 统一遵循 GitHub Flow（feature/bugfix/hotfix 直接合入 main），禁止直接在主干分支开发。
- 工作流分支治理（GitHub Flow 对齐）:
  - 每个 workflow 启动时从 `main` 创建唯一工作流分支（`integration_branch`），该分支是 **workflow-scoped feature branch**，最终通过 PR 合入 `main` 并删除——不是 GitFlow 的长期 develop 分支。
  - Agent 可使用私有工作分支（如 `feat/{workflow-id}/{agent-name}`），但交付前必须回灌到 `integration_branch`。
  - 审查、注册、发布均以 `integration_branch` 的 HEAD commit 为唯一依据；不允许以多个 agent 分支并列作为最终交付物。

## 11. Metadata
- Version: 1.0
- Owner: Knowledge Team
- Last Updated: 2026-06-15
- Tags: knowledge, documentation, governance, service
