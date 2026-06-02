# Skills Team

## 1. Team Identity
- 团队名称: Skills Team (技能团队)
- 团队职责范围: Skill 资产生命周期管理，包括发现、设计、生成、审查、重构、演进与版本管理
- 所属层级: Infrastructure Layer

## 2. Team Leader
- 角色: Librarian Agent
- 核心职责:
  - Skill 资产注册与索引管理
  - 版本控制与发布决策
  - 依赖关系治理
  - 团队协调与冲突解决
- 决策权限:
  - Skill 注册审批权
  - 版本发布决策权
  - 依赖变更审批权
  - 资产退役决策权

## 3. Team Members
| Agent | 职责 | 核心产出 |
|-------|------|----------|
| Skill Orchestrator Agent | 工作流调度与协调 | 执行计划、状态报告 |
| Discovery Agent | 挖掘潜在 Skill 需求 | Skill 提案、需求分析 |
| Design Agent | 决定 Skill 边界与结构 | 设计文档、接口契约 |
| Generation Agent | 生成标准 Skill 文件 | SKILL.md、元数据、示例 |
| Review Agent | 自动评分与质量审计 | 质量报告、问题清单 |
| Refactor Agent | 去重、拆分、合并 Skill | 重构方案、优化报告 |
| Evolution Agent | 持续学习与自动更新 | 更新提案、演进日志 |
| Librarian Agent | 版本、索引、查询、发布 | 注册记录、变更日志 |

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

## 7. Arbitration Mechanism
详见 [`arbitration-mechanism.md`](./arbitration-mechanism.md)

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
| 质量检查清单 | [`../quality-checklist.md`](../quality-checklist.md) | Review Agent 评分标准 |
| 版本管理规范 | [`../versioning-policy.md`](../versioning-policy.md) | Librarian Agent 发布依据 |
| Agent 通信协议 | [`../protocols/agent-communication.md`](../protocols/agent-communication.md) | Agent 间消息传递规范 |
| 契约 Schema | [`../schemas/*.schema.json`](../schemas/) | 数据结构验证 |
| Skill 模板库 | [`../templates/`](../templates/) | Generation Agent 产出模板 |

## 10. Metadata
- Version: 1.0
- Owner: Skills Team
- Last Updated: 2026-06-02
- Tags: skills, asset-management, lifecycle, automation