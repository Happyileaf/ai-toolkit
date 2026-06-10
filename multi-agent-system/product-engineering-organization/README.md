# Multi-Agent System Blueprint

企业级 Multi-Agent 产研组织。覆盖从需求、设计、研发、测试、发布到复盘的完整链路。  
组织由多个职能团队组成（Product、Design、Engineering、QA、Delivery、Data、Platform、Skills 等），通过 Workflow 编排协同执行，目标是让复杂任务在多角色协作下仍然保持可追踪、可审计、可演进。

## 核心目标

- 模拟真实互联网公司的产研流程
- 支持产品、研发、测试、运营全链路
- 支持长期记忆与协作
- 支持 Workflow Orchestration
- 支持 Human-in-the-loop

## 系统整体介绍

## 系统模块

- `workflows/`：工作流入口与步骤说明（任务执行主入口）
- `agents/`：各团队 Agent 角色定义与 team 视图
- `schemas/`：组织级与 workflow 级 schema、registry、通用 envelope
- `protocols/`：跨 Agent 通信协议
- `governance/`：安全、人工介入、机器可判定标准等治理规则
- `organization/`：组织结构、Agent 索引、总协调角色
- `platform/`：评估体系与工具能力说明
- `infra/`：基础设施与可观测性说明
- `memory/`：记忆架构
- `templates/`：模板资产
- `examples/`：参考案例
- `prompts/`：系统提示词等配置

在这个组织中：

- `workflows/` 定义“做事流程”
- `agents/` 定义“谁来做、怎么做”
- `schemas/` 定义“交接产物如何机器可判定”
- `governance/` 定义“必须遵守的组织约束”

## Level 0: 先判定任务类型

- 做产品需求到上线交付：读 `workflows/product-development-workflow/WORKFLOW.md`
- 新建 Skill：读 `workflows/skill-creation-workflow/WORKFLOW.md`
- 演进已有 Skill：读 `workflows/skill-evolution-workflow/WORKFLOW.md`
- 退役 Skill：读 `workflows/skill-retirement-workflow/WORKFLOW.md`
- 紧急发布 Skill：读 `workflows/skill-emergency-release.md`
- 处理线上事故：读 `workflows/incident-response-workflow.md`
- 只看发布阶段动作：读 `workflows/release-workflow.md`
- 不确定走哪条流程：读 `agents/platform-team/workflow-orchestrator-agent.md`

## Level 1: 需要角色/团队边界时

- 看组织分层：读 `organization/organization-structure.md`
- 看全量 Agent 索引：读 `organization/agents-index.md`
- 看特定团队职责：读 `agents/<team>/team.md`

## Level 2: 需要机器可判定产物时

- 看标准说明：读 `governance/machine-readable-artifact-standard.md`
- 查 schema 索引：读 `schemas/schema-registry.json`
- 看 schema 目录说明：读 `schemas/README.md`
- 看通用封装：读 `schemas/organization/artifact-envelope.schema.json`

## Level 3: 需要协作与约束时

- 看 Agent 通信：读 `protocols/skill-agent-communication.md`
- 看安全约束：读 `governance/security-policy.md`
- 看人工介入边界：读 `governance/human-in-the-loop.md`

## Level 4: 需要实现支撑信息时

- 看平台能力：读 `platform/tooling.md`
- 看评估体系：读 `platform/evaluation-system.md`
- 看观测与基础设施：读 `infra/observability.md`、`infra/infra-stack.md`
- 看记忆架构：读 `memory/memory-architecture.md`

## Level 5: 需要模板或示例时

- 需要产物模板：读 `templates/`
- 需要参考案例：读 `examples/ai-ppt-generator-case.md`

## 使用方式（渐进式披露）

1. 从 Level 0 只选一个入口文件。  
2. 仅在当前问题缺信息时，再进入下一层。  
3. 每次只打开最少文件，避免全量扫描。  
4. 如遇冲突，以被路由到的源文件为准。
