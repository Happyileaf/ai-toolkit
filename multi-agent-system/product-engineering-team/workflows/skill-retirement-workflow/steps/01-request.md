---
step_id: retirement-01
step_name: Request
responsible_agent: Librarian Agent
inputs:
  - skill_id
  - retirement_reason
outputs:
  - request_validation
  - preliminary_assessment
next_step: steps/02-dependency-check.md
---

# Step 1: Request - 退役请求

## Purpose

验证退役请求的有效性。

## Responsible Agent

**Librarian Agent**

## Execution Steps

1. **Skill 状态检查**
   - 确认 Skill 存在且为 active
   - 检查当前版本

2. **原因验证**
   - 确认退役原因合理
   - 检查是否有替代方案

3. **初步评估**
   - 使用频率查询
   - 最后使用时间

## Output Contract

```json
{
  "request_validation": {
    "skill_id": "SKILL-002",
    "status": "valid",
    "current_version": "1.0.0",
    "retirement_reason": "replaced"
  },
  "preliminary_assessment": {
    "usage_frequency": "low",
    "last_used": "2026-05-15",
    "has_replacement": true,
    "replacement_skill": "SKILL-006"
  }
}
```

## Duration Estimate

- 正常: 30 分钟