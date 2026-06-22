---
step_id: emergency-04
step_name: Quick Review
responsible_agent: Review Agent
inputs:
  - fix_result
outputs:
  - quality_report
next_step: steps/05-immediate-release.md
---

# Step 4: Quick Review - 快速审核

## Purpose

仅检查阻塞项，确保紧急修复有效且无新增阻塞问题。

## Responsible Agent

**Review Agent**

## Execution Steps

1. **仅检查阻塞项**

   | 检查项 | 标准 |
   |------|------|
   | 安全问题已修复 | 必须 |
   | 无新增阻塞问题 | 必须 |
   | 基本功能可用 | 必须 |

2. **评分阈值降低**: >= 70 分（正常为 80）

3. **生成质量报告**

4. **如未通过，返回 Step 3 重新修复**

## Output Contract

```json
{
  "quality_report": {
    "blocking_items_passed": true,
    "security_fixed": true,
    "no_new_blocking_issues": true,
    "basic_functionality_available": true,
    "quality_score": 72,
    "threshold": 70,
    "review_passed": true
  }
}
```

## Duration Estimate

- 正常: 30 分钟
