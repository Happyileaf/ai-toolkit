---
step_id: pd-03
step_name: UI/UX Design & Review
responsible_agent: Design Team Leader Agent
inputs:
  - workflow_id
  - prd_package
  - requirement_traceability_matrix
  - acceptance_criteria
  - constraints
  - risk_register
outputs:
  - ui_ux_design_package
  - ux_review_report
  - ui_review_report
  - ux_ui_gate_decision
next_step: steps/04-technical-solution-design.md
failure_step: steps/02-discovery-specification.md
---

# Step 3: UI/UX Design & Review - UI&UX 设计与评审

## Purpose

独立完成 UI/UX 设计、可用性与一致性评审，形成可开发、可验收的体验规格。

## Responsible Agent

**Design Team Leader Agent**（执行: UX Agent, UI Design Agent；协作: Product Manager Agent, Frontend Engineer Agent, QA Team Leader Agent）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `workflow_id` | Step 01 输出 | 流程标识 |
| `prd_package` | Step 02 输出 | 产品需求包 |
| `requirement_traceability_matrix` | Step 02 输出 | 追踪矩阵 |
| `acceptance_criteria` | Step 02 输出 | 验收标准 |
| `constraints` | Workflow 输入 | 资源与实现约束 |
| `risk_register` | Step 01 输出 | 风险台账 |

## Execution Steps

1. **UX 方案设计**
   - 梳理主流程、异常流程、边界流程
   - 输出信息架构、任务流与交互状态机

2. **UI 方案设计**
   - 定义视觉规范、组件清单、交互细节
   - 明确空态、错误态、加载态、禁用态

3. **可用性与无障碍检查**
   - 核查关键信息层级、可读性、可达性
   - 评估跨端一致性与可操作性

4. **设计评审**
   - Design Team Leader 组织 UI/UX 联合评审
   - Product + Engineering + QA 联合确认可实现与可测试性

5. **门禁决策**
   - 输出 `ux_ui_gate_decision`：`pass` / `changes_requested`

## Output Contract

机器可判定 schema：

- `../../../schemas/workflows/product-development/product-development-step-artifact.schema.json`
- `artifact_type`: `pd-03-ui-ux-output`

```json
{
  "ui_ux_design_package": {
    "flow_spec": ["onboarding_main_flow_v2", "onboarding_exception_flow_v2"],
    "ui_spec": {
      "components": ["onboarding-stepper", "guidance-modal", "progress-card"],
      "states": ["default", "loading", "empty", "error", "success"]
    },
    "cross_platform_notes": ["web/ios/android 交互一致，文案长度按移动端收敛"]
  },
  "ux_review_report": {
    "status": "pass",
    "usability_risks": [],
    "open_questions": []
  },
  "ui_review_report": {
    "status": "pass",
    "consistency_issues": [],
    "accessibility_issues": []
  },
  "ux_ui_gate_decision": {
    "status": "pass",
    "review_ref": "DESIGN-UXUI-001",
    "blocking_issues": []
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 主/异常流程覆盖 | 100% | UX 评审 |
| 组件状态完整性 | 必须覆盖 5 类状态 | UI 评审 |
| 可用性风险 | 阻塞项为 0 | 设计评审清单 |
| 可测试性 | 验收标准可映射到界面行为 | QA 联合评审 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 交互方案不可收敛 | 回退 Step 02 重新澄清需求边界 |
| UI 一致性不达标 | UI Design Agent 修订后重审 |
| 可用性阻塞问题 | UX Agent 修订后重审 |

## Handoff

- **pass**: 转入 `steps/04-technical-solution-design.md`
- **changes_requested**: 本步骤内修订重试（最多 2 次）

## Duration Estimate

- 正常: 1-2 个工作日
