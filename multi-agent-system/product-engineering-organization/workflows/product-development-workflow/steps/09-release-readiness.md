---
step_id: pd-09
step_name: Release Readiness
responsible_agent: Release Manager Agent
inputs:
  - qa_verdict
  - qa_report
  - security_report
  - performance_report
  - delivery_plan
  - reviewed_ref
outputs:
  - release_decision
  - release_checklist
  - rollback_plan
  - communication_plan
next_step: steps/10-production-release.md
failure_step: steps/08-system-verification.md
---

# Step 9: Release Readiness - 发布就绪评审

## Purpose

在发布窗口前完成跨团队 Go/No-Go 评审，确保发布可控且可回滚。

## Responsible Agent

**Release Manager Agent**（协作: QA Team Leader Agent, DevOps Agent, Product Manager Agent, Engineering Team Leader Agent）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `qa_verdict` | Step 08 输出 | 质量门禁结论 |
| `qa_report/security_report/performance_report` | Step 08 输出 | 质量证据 |
| `delivery_plan` | Step 05 输出 | 发布窗口 |
| `reviewed_ref` | Step 07 输出 | 待发布引用 |

## Execution Steps

1. **发布前检查**
   - 验证门禁全部通过
   - 确认发布范围、变更清单、值班人员

2. **回滚预案确认**
   - 明确回滚触发条件、回滚步骤、回滚 owner
   - 核查数据回滚与兼容策略

3. **Go/No-Go 会议**
   - 参与方签署发布结论
   - 输出阻塞项与残余风险说明

4. **通知计划确认**
   - 内部通知、外部公告、客服/运营同步计划

## Output Contract

机器可判定 schema：

- `../../../schemas/workflows/product-development/product-development-step-artifact.schema.json`
- `artifact_type`: `pd-09-release-readiness-output`

```json
{
  "release_decision": {
    "status": "go",
    "reviewed_ref": "a1b2c3d4",
    "release_window": "2026-06-30 14:00-16:00",
    "approved_by": [
      "Release Manager Agent",
      "QA Team Leader Agent",
      "Engineering Team Leader Agent",
      "Product Manager Agent"
    ]
  },
  "release_checklist": {
    "gate_passed": true,
    "oncall_ready": true,
    "runbook_ready": true
  },
  "rollback_plan": {
    "trigger": ["5 分钟错误率 > 2%", "核心链路不可用 > 3 分钟"],
    "owner": "DevOps Agent",
    "estimated_recovery_minutes": 15
  },
  "communication_plan": {
    "channels": ["研发群", "客服群", "业务群"],
    "timing": "发布前 30 分钟 / 发布后 10 分钟"
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 门禁状态 | 全部通过 | Checklist |
| 回滚预案完整度 | 100% | Runbook 检查 |
| 责任人就绪度 | 100% | 值班确认 |
| 发布引用一致性 | reviewed_ref 唯一且可追溯 | 引用检查 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 任一门禁未通过 | `release_decision = no-go` |
| 回滚方案不可执行 | 阻断发布并补齐预案 |
| 关键 owner 缺失 | 延后发布窗口 |

## Handoff

- **go**: 转入 `steps/10-production-release.md`
- **no-go**: 返回 `steps/08-system-verification.md`

## Duration Estimate

- 正常: 2-4 小时
