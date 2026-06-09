---
step_id: pd-10
step_name: Production Release
responsible_agent: DevOps Agent
inputs:
  - release_decision
  - reviewed_ref
  - rollback_plan
  - communication_plan
outputs:
  - release_record
  - production_health_report
  - released_ref
  - incident_ticket
next_step: steps/11-post-release-retrospective.md
failure_step: steps/09-release-readiness.md
---

# Step 10: Production Release - 生产发布与守护

## Purpose

执行灰度/全量发布，持续监控关键健康指标，在异常时快速处置或回滚。

## Responsible Agent

**DevOps Agent**（协作: Release Manager Agent, QA Team Leader Agent, Security Agent）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `release_decision` | Step 09 输出 | 必须为 `go` |
| `reviewed_ref` | Step 09 输入 | 待发布引用 |
| `rollback_plan` | Step 09 输出 | 回滚预案 |
| `communication_plan` | Step 09 输出 | 沟通方案 |

## Execution Steps

1. **发布启动**
   - 按计划触发发布流水线
   - 发布开始前发送通知

2. **渐进式发布**
   - 执行 canary（如 5% -> 25% -> 100%）
   - 每个阶段均监控错误率、延迟、业务核心指标

3. **健康检查与判定**
   - 达标则推进下一阶段
   - 触发阈值则暂停并评估回滚

4. **异常处理**
   - 发生严重异常按 `rollback_plan` 执行
   - 必要时创建 `incident_ticket`

5. **发布收口**
   - 发送发布完成通知
   - 固化 `release_record`

## Output Contract

```json
{
  "release_record": {
    "status": "success",
    "released_ref": "a1b2c3d4",
    "release_started_at": "2026-06-30T14:00:00Z",
    "release_completed_at": "2026-06-30T14:42:00Z",
    "strategy": "canary",
    "phases": ["5%", "25%", "100%"]
  },
  "production_health_report": {
    "error_rate": 0.002,
    "latency_p95_ms": 380,
    "availability": "99.95%",
    "business_signal": "activation_rate_realtime +4.1%"
  },
  "released_ref": "a1b2c3d4",
  "incident_ticket": null
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 发布成功状态 | success | 发布记录 |
| 关键指标稳定性 | 无持续恶化 | 监控看板 |
| 回滚可执行性 | 已验证可执行 | Runbook 演练记录 |
| 事件闭环 | 有异常则必须有 ticket | 事件系统 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| canary 指标恶化 | 停止扩量并执行回滚 |
| 大面积错误 | 立即回滚 + 触发 incident-response-workflow |
| 监控不可用 | 暂停发布，恢复监控后继续 |

## Handoff

- **success**: 转入 `steps/11-post-release-retrospective.md`
- **rollback**: 返回 `steps/09-release-readiness.md` 重新评估

## Duration Estimate

- 正常: 1-3 小时（含观察窗口）
