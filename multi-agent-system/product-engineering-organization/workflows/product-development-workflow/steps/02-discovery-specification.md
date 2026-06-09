---
step_id: pd-02
step_name: Discovery & Specification
responsible_agent: Product Manager Agent
inputs:
  - workflow_id
  - intake_record
  - metric_baseline
  - risk_register
outputs:
  - prd_package
  - requirement_traceability_matrix
  - acceptance_criteria
  - scope_freeze_record
next_step: steps/03-ui-ux-design-review.md
failure_step: steps/01-intake-triage.md
---

# Step 2: Discovery & Specification - 需求发现与规格冻结

## Purpose

完成用户证据收集、需求规格化与验收标准定义，形成可开发、可测试、可追踪的 PRD 包。

## Responsible Agent

**Product Manager Agent**（协作: Requirement Analyst Agent, User Research Agent, Data Analyst Agent）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `workflow_id` | Step 01 输出 | 流程标识 |
| `intake_record` | Step 01 输出 | 立项上下文 |
| `metric_baseline` | Step 01 输出 | 指标基线 |
| `risk_register` | Step 01 输出 | 风险台账 |

## Execution Steps

1. **用户与场景证据补齐**
   - User Research Agent 提供访谈/行为证据
   - 区分事实、推断、假设

2. **需求规格化**
   - Requirement Analyst Agent 拆解主流程与异常流程
   - 明确范围内/范围外（In-Scope / Out-of-Scope）

3. **验收标准定义**
   - 每个 Story 采用 Given/When/Then 或等价结构
   - 覆盖功能、异常、权限、幂等等关键场景

4. **数据与埋点策略**
   - 定义指标事件、口径与验收阈值
   - 明确上线后观测项

5. **需求冻结评审**
   - Product Team Leader Agent 签署需求冻结
   - 输出 `scope_freeze_record`

## Output Contract

```json
{
  "prd_package": {
    "prd_id": "PRD-WF-PD-2026-001",
    "problem_statement": "新用户激活率偏低",
    "goals": [
      { "metric": "activation_rate_d7", "target": 0.38 }
    ],
    "in_scope": ["新手引导重构", "关键节点提示优化"],
    "out_of_scope": ["账号体系重构"],
    "user_stories": [
      {
        "id": "US-001",
        "story": "作为新用户，我希望在首次使用时快速理解核心功能",
        "priority": "P1"
      }
    ]
  },
  "requirement_traceability_matrix": [
    {
      "goal": "activation_rate_d7",
      "story_id": "US-001",
      "acceptance_id": "AC-001"
    }
  ],
  "acceptance_criteria": [
    {
      "id": "AC-001",
      "given": "新注册用户首次登录",
      "when": "完成引导流程",
      "then": "可在 2 分钟内完成关键操作"
    }
  ],
  "scope_freeze_record": {
    "status": "frozen",
    "approved_by": "Product Team Leader Agent",
    "approved_at": "2026-06-09T10:00:00Z"
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 需求可测试性 | 100% Story 有验收标准 | 评审检查 |
| 追踪完整性 | Goal -> Story -> AC 全链路可追踪 | RTM 校验 |
| 范围边界清晰度 | In/Out Scope 均明确 | 人工评审 |
| 数据可观测性 | 每个业务目标有对应埋点/指标 | 数据评审 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 用户证据不足 | 返回补充研究 |
| 验收标准不可测试 | Requirement Analyst 重写 |
| 范围争议无法收敛 | 升级 Product Team Leader 仲裁 |

## Handoff

- **成功**: 转入 `steps/03-ui-ux-design-review.md`
- **失败**: 返回 `steps/01-intake-triage.md` 或本步骤重做

## Duration Estimate

- 正常: 1-2 个工作日
