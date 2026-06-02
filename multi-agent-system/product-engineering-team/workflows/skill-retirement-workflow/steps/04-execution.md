---
step_id: retirement-04
step_name: Execution
responsible_agent: Librarian Agent
inputs:
  - announcement_record
outputs:
  - retirement_execution
  - status_update
next_step: steps/05-cleanup.md
---

# Step 4: Execution - 退役执行

## Purpose

执行 Skill 退役，更新状态。

## Responsible Agent

**Librarian Agent**

## Execution Steps

1. **生效日期检查**
   - 确认已过公告周期
   - 确认无阻塞

2. **状态更新**
   - SKILL.md status: `retired`
   - _meta.json status: `retired`

3. **索引更新**
   - index.md status: `retired`
   - 移动到退役区域

4. **版本归档**
   - 保留最后版本记录
   - 标记退役时间

## Output Contract

```json
{
  "retirement_execution": {
    "skill_id": "SKILL-002",
    "retired_at": "2026-06-16T00:00:00Z",
    "last_version": "1.0.0",
    "status": "retired"
  },
  "status_update": {
    "files_updated": ["SKILL.md", "_meta.json", "index.md"],
    "archive_location": "skills/retired/ui-audit/"
  }
}
```

## Duration Estimate

- 正常: 30 分钟