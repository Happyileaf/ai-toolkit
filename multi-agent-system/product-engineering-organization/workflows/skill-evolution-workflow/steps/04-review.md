---
step_id: evolution-04
step_name: Review
responsible_agent: Review Agent
inputs:
  - update_proposal
outputs:
  - quality_report
  - decision
next_step: steps/05-release.md
failure_step: steps/03-proposal.md
---

# Step 4: Review - 质量审计

## Purpose

审计更新提案，确保质量达标。

## Responsible Agent

**Review Agent**

## Execution Steps

1. **变更验证**
   - 向后兼容性检查
   - 接口一致性检查
   - 文档完整性检查

2. **回归测试**
   - 原有功能不受影响
   - 新增功能正常工作

3. **评分计算**
   - 同 creation workflow 标准

4. **决策**
   - pass: 转入 Release
   - fail: 返回 Proposal 修改

## Output Contract

```json
{
  "quality_report": {
    "skill_id": "SKILL-003",
    "score": 90,
    "backward_compatibility": "passed",
    "regression_test": "passed",
    "issues": []
  },
  "decision": {
    "status": "pass",
    "next_action": "release"
  }
}
```

## Duration Estimate

- 正常: 1-2 小时