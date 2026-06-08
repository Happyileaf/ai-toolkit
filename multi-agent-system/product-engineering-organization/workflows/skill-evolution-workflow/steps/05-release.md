---
step_id: evolution-05
step_name: Release
responsible_agent: Librarian Agent
inputs:
  - update_proposal
  - quality_report
outputs:
  - release_record
  - evolution_log
next_step: null
---

# Step 5: Release - 版本发布

## Purpose

发布 Skill 更新版本，更新变更日志。

## Responsible Agent

**Librarian Agent**

## Execution Steps

1. **版本更新**
   - 更新 SKILL.md version 字段
   - 更新 _meta.json

2. **变更日志**
   ```markdown
   ## v1.0.1 - 2026-06-02
   
   ### Fixed
   - 选择器不稳定问题 (BUG-001)
   
   ### Improved
   - 补充错误处理示例
   ```

3. **索引更新**
   - 更新 index.md 版本号

4. **演进日志**
   - 记录改进来源
   - 记录效果追踪计划

## Output Contract

```json
{
  "release_record": {
    "skill_id": "SKILL-003",
    "version": "1.0.1",
    "released_at": "2026-06-02T12:00:00Z",
    "update_type": "patch",
    "changes": [...]
  },
  "evolution_log": {
    "feedback_sources": ["BUG-001", "FEED-002"],
    "improvements_applied": ["IMP-001", "IMP-002"],
    "effect_tracking": "30天后复查"
  }
}
```

## Duration Estimate

- 正常: 30 分钟