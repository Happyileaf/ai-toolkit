---
step_id: retirement-03
step_name: Announcement
responsible_agent: Librarian Agent
inputs:
  - dependency_impact
  - retirement_reason
outputs:
  - announcement_record
  - announcement_date
next_step: steps/04-execution.md
---

# Step 3: Announcement - 公告发布

## Purpose

发布退役公告，通知相关方。

## Responsible Agent

**Librarian Agent**

## Execution Steps

1. **公告周期计算**
   ```
   if reason == "security": period = 0 (立即)
   elif reason == "unused": period = 7 days
   else: period = 14 days
   ```

2. **公告内容生成**
   ```markdown
   # Skill 退役公告
   
   ## 退役信息
   - Skill ID: SKILL-002
   - Skill 名称: ui-audit
   - 退役原因: 功能被 ui-gap-audit 替代
   - 生效日期: 2026-06-16
   
   ## 替代方案
   - 替代 Skill: SKILL-006 (ui-gap-audit)
   - 迁移指南: [链接]
   
   ## 注意事项
   - 请在生效日期前完成迁移
   - 退役后 Skill 将不可用
   ```

3. **发布渠道**
   - 团队公告
   - 文档更新
   - 索引标记

## Output Contract

```json
{
  "announcement_record": {
    "skill_id": "SKILL-002",
    "announcement_date": "2026-06-02",
    "effective_date": "2026-06-16",
    "period_days": 14,
    "channels": ["团队公告", "文档更新"]
  },
  "announcement_date": "2026-06-02"
}
```

## Duration Estimate

- 正常: 30 分钟