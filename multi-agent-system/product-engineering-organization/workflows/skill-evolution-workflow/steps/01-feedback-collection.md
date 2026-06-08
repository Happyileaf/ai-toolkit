---
step_id: evolution-01
step_name: Feedback Collection
responsible_agent: Evolution Agent
inputs:
  - feedback_sources
  - skill_id
outputs:
  - feedback_aggregation
  - priority_queue
next_step: steps/02-analysis.md
---

# Step 1: Feedback Collection - 反馈收集

## Purpose

从多源收集反馈数据并聚合分析。

## Responsible Agent

**Evolution Agent**

## Execution Steps

1. **数据收集**
   - PR 记录: 代码变更、合并历史
   - Bug 报告: 问题描述、频率、影响
   - 事故复盘: 根因、教训、改进措施
   - 用户反馈: 使用体验、建议

2. **数据清洗**
   - 去除无关反馈
   - 统计反馈频率
   - 评估影响范围

3. **优先级排序**
   ```yaml
   priority_rules:
     security: immediate
     stability: high
     performance: medium
     experience: low
   ```

4. **聚合输出**
   - 按类型分组
   - 标记优先级

## Output Contract

```json
{
  "feedback_aggregation": {
    "skill_id": "SKILL-003",
    "total_feedbacks": 5,
    "by_type": {
      "bug": 3,
      "user_feedback": 2
    },
    "priority_distribution": {
      "high": 1,
      "medium": 3,
      "low": 1
    },
    "top_issues": [
      {
        "id": "BUG-001",
        "type": "bug",
        "priority": "high",
        "description": "选择器不稳定",
        "frequency": "3次/周",
        "impact": "10%用户"
      }
    ]
  },
  "priority_queue": ["BUG-001", "FEED-002", "FEED-003"]
}
```

## Duration Estimate

- 正常: 1-2 小时