# Quality Assurance Team

## 1. Team Identity
- 团队名称: Quality Assurance Team (质量保障团队)
- 团队职责范围: 测试策略、质量门禁、缺陷管理、发布风险评估
- 所属层级: Execution Layer

## 2. Team Leader
- 角色: Quality Assurance Team Leader Agent
- 核心职责:
  - 定义测试策略与发布质量门禁
  - 协调缺陷分诊与严重级别管理
  - 输出发布就绪度与残余风险报告
  - 质量体系建设与持续改进
- 决策权限:
  - 发布 go/no-go 决策权
  - 测试策略定义权
  - 缺陷优先级判定权
  - 质量门禁设置权

## 3. Team Members
| Agent | 职责 | 核心产出 |
|-------|------|----------|
| Quality Assurance Team Leader Agent | 测试策略与发布信心管理 | 测试计划、质量门禁决策、缺陷分诊结论 |
| Quality Assurance Agent | 质量策略与测试执行 | 测试报告、缺陷清单、门禁结论 |
| Performance Agent | 性能基线与容量优化 | 压测报告、瓶颈分析、容量评估 |
| Security Agent | 应用与平台安全治理 | 风险评估报告、加固建议、门禁意见 |

## 4. Core Workflows
- `product-development-workflow`: 参与系统验证与发布就绪节点，提供质量门禁与发布风险评估
- `code-review-workflow`: 协作代码审查中的质量检查

## 5. Collaboration
- 内部协作: Quality Assurance Team Leader Agent 统一治理测试策略与质量门禁，分派 Quality Assurance Agent 执行功能测试、Performance Agent 执行性能测试、Security Agent 执行安全评审
- 外部协作:
  - 与 Product Team 协作验收标准与边界场景细化
  - 与 Engineering Team 协作修复验证与代码审查
  - 与 Delivery Team 协作发布 go/no-go 决策
  - 与 Platform Team 协作平台级质量与合规门禁
  - 与 Corporate Strategy Office 协作重大质量风险升级

## 6. Quality Gates
- 缺陷门禁: 存在未解决 P0/P1 缺陷时阻止发布
- 安全门禁: 高危漏洞未修复不得放行
- 性能门禁: 关键链路 P95/P99 不达标则阻断发布
- 覆盖率要求: 关键路径自动化回归覆盖率 >= 80%

## 7. Arbitration Mechanism

### 仲裁层级
```
Level 1: Quality Assurance Team Leader Agent (Team Leader)
    - 处理缺陷优先级争议、测试范围分歧、门禁标准争议

Level 2: Delivery Team Leader Agent
    - 处理质量与交付节奏冲突

Level 3: CEO Agent (Corporate Strategy Office)
    - 处理重大质量风险与安全决策分歧
```

### 仲裁触发场景
| 场景 | 升级路径 |
|------|----------|
| 缺陷优先级争议 | Quality Assurance Team Leader Agent 仲裁 |
| 测试范围分歧 | Quality Assurance Team Leader Agent 仲裁 |
| 质量与交付节奏冲突 | Delivery Team Leader Agent 仲裁 |
| 重大质量与安全决策 | CEO Agent 仲裁 |

## 8. Emergency Response

### 紧急响应条件
| 类型 | 时间要求 |
|------|----------|
| P0/P1 线上逃逸缺陷 | 立即响应并组织修复验证 |
| 高危安全漏洞 | 立即阻断发布并跟踪修复 |
| 关键性能指标恶化 | 立即阻断发布建议并定位瓶颈 |

### 紧急流程
- Quality Assurance Team Leader Agent 立即组织缺陷分诊与修复验证
- 安全问题阻断发布并启动安全事件响应
- 性能问题阻断发布并组织专项优化
- 重大质量风险升级至 Delivery Team 与 Corporate Strategy Office

## 9. Supporting Documents
| 文档 | 路径 | 用途 |
|------|------|------|
| 组织架构 | [`organization/organization-structure.md`](../../organization/organization-structure.md) | 组织层级与团队关系参考 |
| 安全策略 | [`governance/security-policy.md`](../../governance/security-policy.md) | 安全评审与合规门禁依据 |
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
- Owner: Quality Assurance Team
- Last Updated: 2026-06-10
- Tags: qa, testing, quality-gate, security, performance
