---
step_id: creation-01
step_name: Discovery
responsible_agent: Discovery Agent
inputs:
  - source_type
  - source_data
  - existing_skills
outputs:
  - skill_proposal
  - priority_queue
next_step: steps/02-design.md
failure_step: null
---

# Step 1: Discovery - 需求发现与提案

## Purpose

分析输入数据，识别值得 Skill 化的模式，产出结构化提案。

## Responsible Agent

**Discovery Agent** - 参考: `../../../agents/skills-team/skills-discovery-agent.md`

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `source_type` | Workflow 输入 | 来源类型 |
| `source_data` | Workflow 输入 | 原始数据（日志、代码、反馈） |
| `existing_skills` | Librarian Agent 查询 | 现有 Skill 索引 |

## Execution Steps

1. **数据收集**
   - 从 `source_data` 提取关键信息
   - 查询现有 Skill 索引避免重复

2. **模式识别**
   - 应用频率阈值: > 3 次/周
   - 应用复杂度阈值: > 中等
   - 识别重复请求模式

3. **价值评估**
   ```yaml
   value_assessment:
     frequency: high | medium | low
     complexity: high | medium | low
     reuse_potential: cross-team | single-team | personal
     estimated_value: 高 | 中 | 低
   ```

4. **提案生成**
   - 产出 Skill 提案文档
   - Schema: `../../../schemas/skill-proposal.schema.json`

5. **优先级排序**
   - 加入候选队列
   - 标记优先级: P0 / P1 / P2

## Output Contract

```json
{
  "skill_proposal": {
    "id": "PROP-0001",
    "title": "Skill 名称",
    "scenario": "使用场景描述",
    "value_assessment": {
      "frequency": "high",
      "complexity": "medium",
      "reuse_potential": "cross-team"
    },
    "priority": "P1",
    "data_sources": ["用户请求日志", "代码变更历史"],
    "success_metrics": ["每周使用 >= 10 次", "用户满意度 >= 80%"],
    "status": "submitted"
  },
  "priority_queue": {
    "position": 3,
    "queue_status": "pending_design"
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 数据来源标注 | 必须 | 人工检查 |
| 现有 Skill 检查 | 必须 | 自动匹配 |
| 成功指标定义 | >= 2 个 | Schema 验证 |
| 优先级合理性 | 符合阈值 | 规则检查 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 数据不足 | 标记"需更多信息"，请求补充 |
| 与现有 Skill 重复 | 标记"已覆盖"，终止流程 |
| 价值不明确 | 标记"观察期"，设置 7 天后复查 |

## Handoff

- **成功**: 转入 `steps/02-design.md`
- **观察期**: 暂停，等待复查
- **已覆盖**: 终止，记录日志

## Duration Estimate

- 正常: 1-2 小时
- 数据不足需补充: +1 天
