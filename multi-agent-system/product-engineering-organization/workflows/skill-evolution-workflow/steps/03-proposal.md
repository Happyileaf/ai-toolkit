---
step_id: evolution-03
step_name: Proposal
responsible_agent: Evolution Agent / Refactor Agent
inputs:
  - improvement_points
  - update_type
outputs:
  - update_proposal
  - affected_files_list
next_step: steps/04-review.md
---

# Step 3: Proposal - 更新提案

## Purpose

生成具体更新提案，包括代码修改与文档变更。

## Responsible Agent

- **Evolution Agent**: 单 Skill 内改进
- **Refactor Agent**: 多 Skill 间结构调整

## Decision Rule

```
if improvement_points 单 Skill:
  agent = Evolution Agent
else:
  agent = Refactor Agent
```

## Execution Steps

1. **修改方案设计**
   - 具体代码/文档修改
   - 保持向后兼容（patch/minor）
   - 迁移方案（major）

2. **提案生成**
   ```yaml
   update_proposal:
     skill_id: SKILL-003
     version_change: 1.0.0 → 1.0.1
     changes:
       - file: SKILL.md
         type: modify
         description: "增加 fallback 选择器逻辑"
         lines: 50-60
       - file: examples/example-01.md
         type: modify
         description: "补充错误处理示例"
     rollback_plan: "恢复原选择器逻辑"
   ```

3. **风险评估**
   - 破坏性影响
   - 依赖影响
   - 回滚复杂度

## Output Contract

```json
{
  "update_proposal": {
    "skill_id": "SKILL-003",
    "current_version": "1.0.0",
    "new_version": "1.0.1",
    "update_type": "patch",
    "changes": [
      {
        "file": "SKILL.md",
        "type": "modify",
        "description": "增加 fallback 选择器逻辑",
        "diff": "+5 lines"
      }
    ],
    "rollback_plan": "恢复原选择器逻辑",
    "risk_level": "low"
  },
  "affected_files_list": ["SKILL.md", "examples/example-01.md"]
}
```

## Duration Estimate

- 正常: 2-4 小时
- 复杂更新: +2 小时