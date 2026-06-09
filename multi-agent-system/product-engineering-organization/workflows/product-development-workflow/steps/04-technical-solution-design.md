---
step_id: pd-04
step_name: Technical Solution Design
responsible_agent: Architect Agent
inputs:
  - prd_package
  - ui_ux_design_package
  - requirement_traceability_matrix
  - acceptance_criteria
  - constraints
  - risk_register
outputs:
  - solution_design_package
  - architecture_decision_record
  - interface_contracts
  - technical_design_gate_decision
next_step: steps/05-planning-kickoff.md
failure_step: steps/03-ui-ux-design-review.md
---

# Step 4: Technical Solution Design - 技术方案设计与评审

## Purpose

将需求转化为可实现的技术方案，完成架构权衡、接口契约、数据模型与非功能目标定义。

## Responsible Agent

**Architect Agent**（协作: Engineering Team Leader Agent, Security Agent, QA Team Leader Agent）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `prd_package` | Step 02 输出 | 产品需求包 |
| `ui_ux_design_package` | Step 03 输出 | UI/UX 设计规格与约束 |
| `requirement_traceability_matrix` | Step 02 输出 | 追踪矩阵 |
| `acceptance_criteria` | Step 02 输出 | 验收标准 |
| `constraints` | Workflow 输入 | 技术与资源约束 |
| `risk_register` | Step 01 输出 | 风险台账 |

## Execution Steps

1. **架构选型与 ADR**
   - 至少给出 2 个备选方案与权衡
   - 输出最终 ADR（性能、成本、复杂度、风险）

2. **接口与数据契约设计**
   - 定义 API/事件契约、错误码、幂等策略
   - 明确向后兼容与迁移策略

3. **测试与安全设计前置**
   - QA Team Leader 对齐测试策略框架
   - Security Agent 对齐关键攻击面及加固要求

4. **技术评审门禁**
   - Architect + Engineering Team Leader + QA Team Leader 联合评审
   - 通过后产出 `technical_design_gate_decision = pass`

## Output Contract

```json
{
  "solution_design_package": {
    "adr_id": "ADR-WF-PD-2026-001",
    "selected_option": "Option-B",
    "architecture_summary": "引导流程服务化 + 前端状态机",
    "data_model_changes": ["user_onboarding_state"],
    "nfr_targets": {
      "latency_p95_ms": 400,
      "error_rate": 0.005,
      "availability": "99.9%"
    }
  },
  "architecture_decision_record": {
    "alternatives": ["Option-A", "Option-B"],
    "tradeoffs": ["复杂度上升", "扩展性更好"],
    "approved_by": "Architect Agent"
  },
  "interface_contracts": {
    "apis": ["POST /onboarding/start", "POST /onboarding/complete"],
    "events": ["onboarding_completed_v1"],
    "backward_compatibility": "guaranteed"
  },
  "technical_design_gate_decision": {
    "status": "pass",
    "open_risks": [],
    "review_ref": "TECH-DESIGN-REVIEW-001"
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 架构权衡充分性 | >= 2 备选方案 | ADR 评审 |
| 契约完整性 | 输入/输出/错误码完整 | 契约检查 |
| NFR 明确性 | 性能/可用性目标显式 | NFR 检查 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 方案不可落地 | 返回 Step 02 缩减范围 |
| 接口冲突 | 召集 Architect/Backend 重新建模 |
| 技术风险未闭合 | 保留阻塞，禁止进入研发计划阶段 |

## Handoff

- **成功**: 转入 `steps/05-planning-kickoff.md`
- **失败**: 返回 `steps/03-ui-ux-design-review.md`

## Duration Estimate

- 正常: 1-3 个工作日
