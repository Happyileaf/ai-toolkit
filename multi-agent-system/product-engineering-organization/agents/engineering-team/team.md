# Engineering Team

## 1. Team Identity
- 团队名称: Engineering Team (工程团队)
- 团队职责范围: 技术实现、架构设计、代码开发、部署运维
- 所属层级: Execution Layer

## 2. Team Leader
- 角色: Engineering Team Leader Agent
- 核心职责:
  - 需求管理与任务分派
  - 进度跟踪与质量门禁把控
  - 团队产能协调
  - 交付风险治理
- 决策权限:
  - 任务分派决策权
  - 迭代排期决策权
  - 技术实现路径选择权
  - 质量门禁放行决策权

## 3. Team Members
| Agent | 职责 | 核心产出 |
|-------|------|----------|
| Engineering Team Leader Agent | 研发执行与交付管理 | 任务计划、分派结果、风险清单、纠偏动作 |
| Architect Agent | 系统架构与技术治理 | 架构图、ADR 文档、参考模式、设计护栏 |
| Frontend Engineer Agent | 客户端产品体验实现 | 前端代码、UI 测试用例、性能验证报告 |
| Backend Engineer Agent | 服务端能力与数据完整性 | API、Schema 迁移脚本、契约文档、运维看板 |
| AI Engineer Agent | AI 功能工程与模型质量 | Prompt 模板、RAG 配置、评估看板 |
| DevOps Agent | 工程效能、环境与发布自动化 | CI/CD 流水线、部署策略、运行手册 |
| Code Review Agent | 代码质量与变更风险把关 | 分级审查意见、合并建议、风险说明 |

## 4. Core Workflows
- `product-development-workflow`: 参与需求澄清、技术方案设计、实现自测、集成审查、系统验证等核心节点
- `code-review-workflow`: 代码审查与合并门禁

## 5. Collaboration
- 内部协作: Engineering Team Leader Agent 统一接收需求并按任务类型分派给对应工程 Agent，跟踪进度与质量
- 外部协作:
  - 与 Product Team 协作需求优先级与范围边界
  - 与 QA Team 协作质量门禁与发布判断
  - 与 Design Team 协作实现可行性与前端还原
  - 与 Delivery Team 协作发布节奏与里程碑对齐
  - 与 Platform Team 协作基础设施与编排能力

## 6. Quality Gates
- 需求准入: 未定义验收标准的需求不得进入开发
- 任务准入: 未指定 owner 与截止时间的任务不得进入迭代
- 代码审查: 高风险改动必须完成二次复审
- 质量门禁: 不得绕过测试、评审与发布质量门禁

## 7. Arbitration Mechanism

### 仲裁层级
```
Level 1: Engineering Team Leader Agent (Team Leader)
    - 处理任务分派争议、技术实现路径分歧、排期冲突

Level 2: Architect Agent
    - 处理架构决策分歧、接口边界争议

Level 3: CEO Agent (Corporate Strategy Office)
    - 处理重大技术战略分歧、跨团队资源冲突
```

### 仲裁触发场景
| 场景 | 升级路径 |
|------|----------|
| 任务分派争议 | Engineering Team Leader Agent 仲裁 |
| 技术实现路径分歧 | Engineering Team Leader Agent 仲裁 |
| 架构决策分歧 | Architect Agent 仲裁 |
| 重大技术战略分歧 | CEO Agent 仲裁 |

## 8. Emergency Response

### 紧急响应条件
| 类型 | 时间要求 |
|------|----------|
| P0/P1 生产缺陷 | 立即响应并组织修复 |
| 发布阻断级缺陷 | 发布前必须清零 |
| 进度偏差超阈值 | 触发重排与资源调整 |

### 紧急流程
- Engineering Team Leader Agent 暂停上线并组织专项修复
- 分派对应工程 Agent 进行紧急修复
- 质量风险升高时升级至 Delivery Team 与 Corporate Strategy Office

## 9. Supporting Documents
| 文档 | 路径 | 用途 |
|------|------|------|
| 组织架构 | [`organization/organization-structure.md`](../../organization/organization-structure.md) | 组织层级与团队关系参考 |
| 代码审查工作流 | [`workflows/code-review-workflow/WORKFLOW.md`](../../workflows/code-review-workflow/WORKFLOW.md) | 代码审查流程规范 |
| 契约 Schema | [`schemas/schema-registry.json`](../../schemas/schema-registry.json) | 组织级 schema 索引与数据结构验证 |
| 人工介入策略 | [`governance/human-in-the-loop.md`](../../governance/human-in-the-loop.md) | 合规与风险升级规则 |

## 10. Execution Context
- 组织运行知识库: 由 Knowledge Team 提供服务，Knowledge Sync Agent 负责克隆同步与路径管理。
  - 目录: `org_knowledge_base/ai-toolkit/multi-agent-system/product-engineering-organization/`
  - 工作过程中如果某些路径找不到的文件都可以在知识库中进行查找作为兜底。
- 开工前置:
  - 通过 Knowledge Sync Agent 获取知识库真实本地路径与同步状态。
  - 若本地知识库路径不存在或内容缺失，向 Knowledge Team 反馈并等待同步完成或内容补充。
- 分支与发布治理: 统一遵循 Gitflow（feature/release/hotfix），禁止直接在主干分支开发。
- 集成分支治理:
  - 一个工作（workflow）必须且仅有一个集成分支（`integration_branch`）。
  - Agent 可使用私有工作分支（如 `feat/{workflow-id}/{agent-name}`），但必须将交付提交回灌到 `integration_branch`。
  - 审查、注册、发布均以 `integration_branch` 的 HEAD commit 为唯一依据。
  - 不允许以多个 agent 分支并列作为最终交付物。

## 11. Metadata
- Version: 1.0
- Owner: Engineering Team
- Last Updated: 2026-06-10
- Tags: engineering, architecture, development, quality
