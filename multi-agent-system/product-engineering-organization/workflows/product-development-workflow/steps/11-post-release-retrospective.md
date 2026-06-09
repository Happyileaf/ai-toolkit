---
step_id: pd-11
step_name: Post-Release Validation & Retrospective
responsible_agent: Data Team Leader Agent
inputs:
  - workflow_id
  - release_record
  - production_health_report
  - metric_baseline
  - business_goals
outputs:
  - post_release_report
  - retrospective_action_log
  - memory_update_record
  - workflow_result
next_step: null
failure_step: steps/10-production-release.md
---

# Step 11: Post-Release Validation & Retrospective - 上线验证与复盘

## Purpose

验证发布效果与业务目标达成情况，沉淀经验并形成可执行改进动作，关闭工作流。

## Responsible Agent

**Data Team Leader Agent**（协作: Product Team Leader Agent, Project Manager Agent, Memory Manager Agent）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `workflow_id` | Step 01 输出 | 流程标识 |
| `release_record` | Step 10 输出 | 发布结果 |
| `production_health_report` | Step 10 输出 | 运行状态 |
| `metric_baseline` | Step 01 输出 | 上线前基线 |
| `business_goals` | Workflow 输入 | 目标指标 |

## Execution Steps

1. **效果评估**
   - 在 T+1 / T+7 / T+14 评估核心指标变化
   - 对比基线、目标值、波动范围

2. **用户反馈与问题收集**
   - 汇总客服工单、用户反馈、行为异常
   - 标注是否触发后续迭代需求

3. **复盘会议**
   - 复盘做得好/不好的项
   - 明确改进动作（owner + due_date + 验收标准）

4. **组织记忆更新**
   - Memory Manager Agent 写入经验与风险模式
   - 更新模板、检查清单、运行手册（如需要）

5. **流程关闭**
   - 输出 `workflow_result = completed`

## Output Contract

```json
{
  "post_release_report": {
    "workflow_id": "WF-PD-2026-001",
    "kpi_validation": [
      {
        "metric": "activation_rate_d7",
        "baseline": 0.32,
        "current": 0.375,
        "target": 0.38,
        "status": "near_target"
      }
    ],
    "user_feedback_summary": "新手引导理解成本下降，但移动端加载仍有优化空间",
    "residual_risks": ["高峰时段首屏加载波动"]
  },
  "retrospective_action_log": [
    {
      "action_id": "RA-001",
      "action": "优化移动端首屏资源加载",
      "owner": "Frontend Engineer Agent",
      "due_date": "2026-07-05",
      "success_criteria": "P95 首屏耗时下降 20%"
    }
  ],
  "memory_update_record": {
    "status": "updated",
    "knowledge_items": 6
  },
  "workflow_result": {
    "status": "completed",
    "workflow_id": "WF-PD-2026-001",
    "released_ref": "a1b2c3d4"
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| KPI 验证完整性 | 每个目标指标均有评估 | 报告校验 |
| 复盘动作可执行性 | 每项都有 owner 与截止时间 | Action Log |
| 经验沉淀完整性 | 关键经验写入记忆系统 | Memory 记录 |
| 关闭标准 | `workflow_result.status=completed` | 流程状态检查 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| KPI 严重不达标 | 触发新一轮需求迭代并回到 Step 02 |
| 发布后稳定性恶化 | 回到 Step 10 执行补救/回滚 |
| 复盘动作长期未执行 | 升级 Project Manager 跟踪 |

## Workflow Completion

本步骤完成后，产品研发工作流闭环结束。

## Duration Estimate

- 正常: 3-10 天（含指标观察窗口）
