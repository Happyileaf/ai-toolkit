---
step_id: retirement-05
step_name: Cleanup
responsible_agent: Librarian Agent
inputs:
  - retirement_execution
outputs:
  - cleanup_report
  - final_record
next_step: null
---

# Step 5: Cleanup - 数据清理

## Purpose

清理退役 Skill 相关数据。

## Responsible Agent

**Librarian Agent**

## Execution Steps

1. **依赖图清理**
   - 移除节点
   - 断开连接边

2. **文档清理**
   - 移动到 archived 目录
   - 更新 CHANGELOG

3. **变更日志**
   ```markdown
   ## 2026-06-16
   
   ### Retired
   - SKILL-002 (ui-audit): 功能被 SKILL-006 (ui-gap-audit) 替代
   ```

4. **迁移指南归档**
   - 保留迁移指南供参考

## Output Contract

```json
{
  "cleanup_report": {
    "skill_id": "SKILL-002",
    "cleanup_actions": [
      "依赖图节点移除",
      "文档归档",
      "变更日志更新"
    ],
    "archive_path": "skills/retired/ui-audit/"
  },
  "final_record": {
    "retirement_complete": true,
    "workflow_result": {
      "status": "completed",
      "skill_id": "SKILL-002",
      "retired_at": "2026-06-16T00:00:00Z"
    }
  }
}
```

## Duration Estimate

- 正常: 30 分钟