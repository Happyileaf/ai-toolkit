---
step_id: pd-05
step_name: Planning & Kickoff
responsible_agent: Engineering Team Leader Agent
inputs:
  - workflow_id
  - solution_design_package
  - ui_ux_design_package
  - interface_contracts
  - technical_design_gate_decision
  - ux_ui_gate_decision
  - delivery_deadline
outputs:
  - delivery_plan
  - sprint_backlog
  - dependency_map
  - kickoff_record
next_step: steps/06-implementation-self-test.md
failure_step: steps/04-technical-solution-design.md
---

# Step 5: Planning & Kickoff - 研发计划与启动

## Purpose

将方案转化为可执行迭代计划，明确任务 owner、里程碑、依赖与质量门禁，完成开发启动。

## Responsible Agent

**Engineering Team Leader Agent**（协作: Project Manager Agent, QA Team Leader Agent, DevOps Agent）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `workflow_id` | Step 01 输出 | 流程标识 |
| `solution_design_package` | Step 04 输出 | 技术方案包 |
| `ui_ux_design_package` | Step 03 输出 | 设计规格包 |
| `interface_contracts` | Step 04 输出 | 接口契约 |
| `technical_design_gate_decision` | Step 04 输出 | 技术评审门禁结论 |
| `ux_ui_gate_decision` | Step 03 输出 | UI/UX 评审门禁结论 |
| `delivery_deadline` | Workflow 输入 | 发布目标时间 |

## Execution Steps

1. **任务拆解**
   - 按模块拆分到 Frontend/Backend/AI/DevOps/QA 子任务
   - 每个任务必须有 owner、估时、截止时间

2. **依赖与关键路径识别**
   - Project Manager Agent 维护 `dependency_map`
   - 标记关键路径与缓冲区

3. **迭代排期与里程碑冻结**
   - 明确 Sprint 目标、发布窗口、冻结时间
   - 记录范围变更策略

4. **质量与发布前置对齐**
   - QA Team Leader 固化测试准入条件
   - DevOps 固化环境与流水线要求

5. **启动会纪要**
   - 输出 `kickoff_record`，包含行动清单与升级路径

## Output Contract

机器可判定 schema：

- `../../../schemas/workflows/product-development/product-development-step-artifact.schema.json`
- `artifact_type`: `pd-05-planning-output`

```json
{
  "delivery_plan": {
    "workflow_id": "WF-PD-2026-001",
    "milestones": [
      { "name": "M1-开发完成", "date": "2026-06-20" },
      { "name": "M2-测试完成", "date": "2026-06-25" },
      { "name": "M3-发布", "date": "2026-06-30" }
    ],
    "release_window": "2026-06-30 14:00-16:00"
  },
  "sprint_backlog": [
    {
      "task_id": "TASK-001",
      "title": "前端引导流程重构",
      "owner": "Frontend Engineer Agent",
      "eta_days": 4,
      "due_date": "2026-06-18"
    }
  ],
  "dependency_map": {
    "critical_path": ["TASK-002", "TASK-005", "TASK-009"],
    "blocked_by": []
  },
  "kickoff_record": {
    "status": "started",
    "risks": ["接口联调窗口紧张"],
    "escalation_path": "Engineering TL -> Orchestrator"
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 任务 owner 完整性 | 100% | Backlog 校验 |
| 截止时间完整性 | 100% | 排期校验 |
| 关键路径识别 | 必须 | 项目评审 |
| DoD 与门禁定义 | 必须 | 启动会检查 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 产能不足 | 缩减范围或调整里程碑 |
| 依赖冲突 | Project Manager 重新排期 |
| 技术或 UI/UX 设计未冻结 | 回退 Step 03/04 |

## Handoff

- **成功**: 转入 `steps/06-implementation-self-test.md`
- **失败**: 返回 `steps/04-technical-solution-design.md`

## Duration Estimate

- 正常: 0.5-1 个工作日
