---
step_id: pd-07
step_name: Integration & Code Review
responsible_agent: Code Review Agent
inputs:
  - engineering_delivery
  - delivery_receipt
  - integration_branch
  - integrated_head_sha
outputs:
  - review_report
  - review_decision
  - reviewed_ref
next_step: steps/08-system-verification.md
failure_step: steps/06-implementation-self-test.md
---

# Step 7: Integration & Code Review - 集成与代码评审

## Purpose

对集成交付执行代码质量、架构一致性和工程规范评审，确保进入系统测试前代码质量达标。

## Responsible Agent

**Code Review Agent**（协作: Architect Agent, Engineering Team Leader Agent）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `engineering_delivery` | Step 06 输出 | 变更摘要 |
| `delivery_receipt` | Step 06 输出 | 集成回执 |
| `integration_branch` | Step 06 输出 | 目标分支 |
| `integrated_head_sha` | Step 06 输出 | 集成引用 |

## Execution Steps

1. **前置校验**
   - 确认 `integrated_head_sha` 与 `integration_branch` HEAD 一致
   - 禁止直接评审私有开发分支

2. **代码评审**
   - 审查可读性、复杂度、异常处理、可维护性
   - 检查需求实现与设计契约一致性

3. **架构一致性检查**
   - 高影响模块需 Architect Agent 补充签署
   - 检查跨模块边界是否破坏

4. **评审决策**
   - `pass` / `changes_requested`
   - 产出阻塞项与建议项列表

## Output Contract

```json
{
  "review_report": {
    "reviewed_ref": "a1b2c3d4",
    "summary": "代码结构清晰，新增事件处理符合设计",
    "blocking_issues": [],
    "suggestions": [
      {
        "id": "RV-001",
        "description": "提取重复校验逻辑",
        "severity": "suggestion"
      }
    ]
  },
  "review_decision": {
    "status": "pass",
    "required_approvals": 1,
    "actual_approvals": 1
  },
  "reviewed_ref": "a1b2c3d4"
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 阻塞问题 | 0 | 评审记录 |
| 评审通过数 | >= 1 | 审批记录 |
| 架构一致性 | 高影响改动必须签署 | Architect 签署 |
| 交付引用一致性 | 必须一致 | 分支引用校验 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 存在阻塞问题 | 返回 Step 06 修复 |
| 架构偏离严重 | 升级 Architect 仲裁 |
| 引用不一致 | 退回重新集成 |

## Handoff

- **pass**: 转入 `steps/08-system-verification.md`
- **changes_requested**: 返回 `steps/06-implementation-self-test.md`

## Duration Estimate

- 正常: 0.5-1 个工作日
