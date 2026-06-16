# Skills Team

## 1. Team Identity
- 团队名称: Skills Team (技能团队)
- 团队职责范围: Skill 资产生命周期管理，包括发现、设计、生成、审查、重构、演进与版本管理
- 所属层级: Infrastructure Layer

## 2. Team Leader
- 角色: Skills Team Leader Agent
- 核心职责:
  - 工作流调度与协调
  - 任务路由与状态迁移
  - 重试、降级与超时升级
  - 团队协调与进度可视性
- 决策权限:
  - 工作流调度决策权
  - 任务路由决策权
  - 重试与升级决策权
  - 资源分配决策权

## 3. Team Members
| Agent | 职责 | 核心产出 |
|-------|------|----------|
| Skills Team Leader Agent | 工作流调度与协调 | 执行计划、状态报告 |
| Skills Librarian Agent | 版本、索引、查询、发布 | 注册记录、变更日志 |
| Skills Discovery Agent | 挖掘潜在 Skill 需求 | Skill 提案、需求分析 |
| Skills Design Agent | 决定 Skill 边界与结构 | 设计文档、接口契约 |
| Skills Generation Agent | 生成标准 Skill 文件 | SKILL.md、元数据、示例 |
| Skills Review Agent | 自动评分与质量审计 | 质量报告、问题清单 |
| Skills Refactor Agent | 去重、拆分、合并 Skill | 重构方案、优化报告 |
| Skills Evolution Agent | 持续学习与自动更新 | 更新提案、演进日志 |

## 4. Core Workflows
- `skill-creation-workflow`: 新 Skill 从发现到发布
- `skill-evolution-workflow`: 已有 Skill 的持续改进
- `skill-retirement-workflow`: Skill 退役与迁移

## 5. Collaboration
- 内部协作: 通过 Skill Orchestrator 协调各 Agent 执行顺序
- 外部协作:
  - 与 Product Team 协作 Skill 需求对齐
  - 与 Engineering Team 协作技术实现
  - 与 QA Team 协作质量标准
  - 与 Platform Team 协作工作流集成

## 6. Quality Gates
- 设计评审: Design Agent 产出需 Review Agent 签署
- 生成验证: Generation Agent 产出需通过自动化测试
- 发布审批: Librarian Agent 确认所有检查通过后发布
- 集成交付门禁: 所有步骤产出必须先集成到同一 `integration_branch`（workflow-scoped feature branch），审查仅基于该分支 HEAD

## 7. Arbitration Mechanism
详见 [`skills-arbitration-mechanism.md`](./skills-arbitration-mechanism.md)

### 仲裁层级
```
Level 1: Librarian Agent (Team Leader)
    - 处理审核争议、依赖冲突、发布争议
    
Level 2: CEO Agent (Executive)
    - 处理战略分歧、重大架构决策
```

### 仲裁触发场景
| 场景 | 升级路径 |
|------|----------|
| Design vs Review 冲突 | Librarian Agent 仲裁 |
| 连续审核失败 (3 次) | Librarian Agent 仲裁 |
| 依赖冲突 | Librarian Agent 协调 |
| 战略分歧 | CEO Agent 仲裁 |

## 8. Emergency Release
详见 [`../workflows/skill-emergency-release.md`](../workflows/skill-emergency-release.md)

### 紧急发布条件
| 类型 | 时间要求 |
|------|----------|
| 安全问题 | 24 小时内 |
| 重大 Bug (>50% 用户) | 48 小时内 |

### 紧急流程
- 跳过 Discovery/Design 步骤
- Review 仅检查阻塞项
- 立即发布，无窗口限制

## 9. Supporting Documents
| 文档 | 路径 | 用途 |
|------|------|------|
| 质量检查清单 | [`skill-quality-checklist.md`](../../skill-quality-checklist.md) | Review Agent 评分标准 |
| 版本管理规范 | [`skill-versioning-policy.md`](../../skill-versioning-policy.md) | Librarian Agent 发布依据 |
| Agent 通信协议 | [`protocols/skill-agent-communication.md`](../../protocols/skill-agent-communication.md) | Agent 间消息传递规范 |
| 契约 Schema | [`schemas/schema-registry.json`](../../schemas/schema-registry.json) | 组织级 schema 索引与数据结构验证 |
| Skill 模板库 | [`templates/skill-template.*`](../../templates/) | Generation Agent 产出模板 |

## 10. Execution Context
- 组织运行知识库: 由 Knowledge Team 提供服务，Knowledge Sync Agent 负责克隆同步与路径管理。
- 团队工作根目录: `multi-agent-system/product-engineering-organization/`
- Skills 资产目录: `skills/` 与 `workflows/`
- 开工前置:
  - 直接读取 Knowledge Team 提供的组织运行知识库，无需自行 clone/pull 仓库。
  - 若本地知识库路径不存在或内容缺失，向 Knowledge Team 反馈并等待同步完成或内容补充。
- 分支与发布治理: 统一遵循 GitHub Flow（feature/bugfix/hotfix 直接合入 main），禁止直接在主干分支开发。
- 工作流分支治理（GitHub Flow 对齐）:
  - 每个 workflow 启动时从 `main` 创建唯一工作流分支（`integration_branch`），该分支是 **workflow-scoped feature branch**，最终通过 PR 合入 `main` 并删除——不是 GitFlow 的长期 develop 分支。
  - Agent 可使用私有工作分支（如 `agent/{agent-name}/{workflow-id}`），但交付前必须回灌到 `integration_branch`。
  - 审查、注册、发布均以 `integration_branch` 的 HEAD commit 为唯一依据；不允许以多个 agent 分支并列作为最终交付物。
- 工作过程中如果某些路径找不到的文件都可以在仓库中进行查找作为兜底。

## 11. Metadata
- Version: 1.0
- Owner: Skills Team
- Last Updated: 2026-06-03
- Tags: skills, asset-management, lifecycle, automation
