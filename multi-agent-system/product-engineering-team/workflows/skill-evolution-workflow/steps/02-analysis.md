---
step_id: evolution-02
step_name: Analysis
responsible_agent: Evolution Agent
inputs:
  - feedback_aggregation
outputs:
  - root_cause_analysis
  - improvement_points
  - update_type
next_step: steps/03-proposal.md
---

# Step 2: Analysis - 根因分析

## Purpose

分析反馈数据，识别根因与改进点。

## Responsible Agent

**Evolution Agent**

## Execution Steps

1. **根因分析**
   - 识别共同模式
   - 定位问题根源
   - 评估修复难度

2. **改进点提取**
   ```yaml
   improvement_points:
     - id: IMP-001
       type: stability
       description: "增加选择器容错机制"
       affected_files: ["SKILL.md"]
       estimated_effort: low
     - id: IMP-002
       type: documentation
       description: "补充错误处理示例"
       affected_files: ["examples/example-01.md"]
       estimated_effort: low
   ```

3. **更新类型判定**
   ```
   if security_issue: update_type = "patch" (紧急)
   elif interface_change: update_type = "major"
   elif new_feature: update_type = "minor"
   else: update_type = "patch"
   ```

4. **影响范围评估**
   - 受影响用户比例
   - 依赖 Skill 影响

## Output Contract

```json
{
  "root_cause_analysis": {
    "common_patterns": ["选择器匹配不稳定"],
    "root_cause": "缺少 fallback 选择器策略",
    "fix_difficulty": "low"
  },
  "improvement_points": [
    {
      "id": "IMP-001",
      "type": "stability",
      "description": "增加选择器容错机制",
      "affected_files": ["SKILL.md"],
      "estimated_effort": "low"
    }
  ],
  "update_type": "patch",
  "impact_assessment": {
    "affected_users": "10%",
    "dependency_impact": "none"
  }
}
```

## Duration Estimate

- 正常: 2-4 小时