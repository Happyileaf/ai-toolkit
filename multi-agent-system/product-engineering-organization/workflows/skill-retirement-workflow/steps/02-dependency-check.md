---
step_id: retirement-02
step_name: Dependency Check
responsible_agent: Refactor Agent
inputs:
  - request_validation
outputs:
  - dependency_impact
  - blocking_dependencies
next_step: steps/03-announcement.md
---

# Step 2: Dependency Check - 依赖检查

## Purpose

分析退役对依赖方的影响。

## Responsible Agent

**Refactor Agent**

## Execution Steps

1. **下游依赖查询**
   - 查询哪些 Skill 依赖本 Skill
   - 统计影响范围

2. **阻塞检查**
   ```yaml
   blocking_rules:
     - if active_downstream_dependencies > 0: blocked
     - if downstream_in_production: blocked
   ```

3. **解除方案**
   - 如有阻塞，提供迁移路径
   - 通知依赖方

## Output Contract

```json
{
  "dependency_impact": {
    "downstream_skills": [],
    "affected_workflows": [],
    "impact_level": "none"
  },
  "blocking_dependencies": {
    "has_blocking": false,
    "blocking_list": [],
    "resolution_plan": null
  }
}
```

## Decision Rules

| 条件 | 后续动作 |
|------|----------|
| 无下游依赖 | 转入 Announcement |
| 有下游依赖 | 等待依赖解除或提供迁移 |

## Duration Estimate

- 正常: 1 小时
- 有依赖需协调: +2 天