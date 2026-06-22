---
step_id: emergency-02
step_name: Quick Audit
responsible_agent: Review Agent
inputs:
  - emergency_assessment
outputs:
  - audit_result
next_step: steps/03-quick-fix.md
---

# Step 2: Quick Audit - 快速审计

## Purpose

跳过正常排期，简化审核流程，仅检查关键阻塞项。

## Responsible Agent

**Review Agent**

## Execution Steps

1. **确认跳过正常流程**

   | 正常流程 | 紧急流程 | 变化 |
   |----------|----------|------|
   | Discovery → Design → Generation | 直接 Generation | 跳过前两步 |
   | Review 完整审计 | Review 快速审计 | 仅检查阻塞项 |
   | 发布窗口（周二/四） | 立即发布 | 跳过窗口限制 |
   | 公告周期（2 周） | 同步公告 | 立即公告 |

2. **执行快速审计，仅检查阻塞项**

   | 检查项 | 标准 |
   |------|------|
   | 安全问题已识别 | 必须 |
   | 影响范围已确认 | 必须 |
   | 修复方向可行 | 必须 |

3. **生成审计结果**

## Output Contract

```json
{
  "audit_result": {
    "skip_discovery": true,
    "skip_design": true,
    "skip_release_window": true,
    "blocking_items_checked": ["security_identified", "impact_confirmed", "fix_feasible"],
    "audit_approved": true
  }
}
```

## Duration Estimate

- 正常: 20 分钟
