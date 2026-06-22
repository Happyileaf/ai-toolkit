---
step_id: emergency-03
step_name: Quick Fix
responsible_agent: Generation Agent
inputs:
  - emergency_assessment
  - audit_result
outputs:
  - fix_result
next_step: steps/04-quick-review.md
---

# Step 3: Quick Fix - 快速修复

## Purpose

实施最小修复，解决紧急问题。

## Responsible Agent

**Generation Agent**

## Execution Steps

1. **定位问题根因**
   - 基于评估结果快速定位

2. **实施最小修复**

```yaml
quick_fix:
  scope: minimal
  changes:
    - "修复安全漏洞"
    - "补充必要验证"
  skip_steps: [discovery, design]
```

3. **简化测试验证**
   - 仅验证修复直接相关的功能
   - 不做全面回归测试

## Checklist

- [ ] 问题根因已定位
- [ ] 最小修复已实施
- [ ] 修复功能已验证

## Output Contract

```json
{
  "fix_result": {
    "root_cause": "...",
    "fix_scope": "minimal",
    "changes_applied": ["修复安全漏洞", "补充必要验证"],
    "basic_verification_passed": true
  }
}
```

## Duration Estimate

- 正常: 2-4 小时
