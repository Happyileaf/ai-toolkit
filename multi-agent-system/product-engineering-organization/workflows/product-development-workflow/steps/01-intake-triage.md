---
step_id: pd-01
step_name: Intake & Triage
responsible_agent: Product Team Leader Agent
inputs:
  - initiative_brief
  - business_goals
  - constraints
  - compliance_requirements
  - risk_level
outputs:
  - workflow_id
  - intake_record
  - risk_register
  - metric_baseline
  - integration_branch
  - integration_base_sha
next_step: steps/02-discovery-specification.md
failure_step: null
---

# Step 1: Intake & Triage - 立项与分级

## Purpose

将业务诉求转化为可执行立项，完成优先级分级、风险初筛和执行上下文初始化。

## Responsible Agent

**Product Team Leader Agent**（协作: Project Manager Agent, Data Analyst Agent, Security Agent）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `initiative_brief` | Workflow 输入 | 背景、问题、目标 |
| `business_goals` | Workflow 输入 | KPI 与目标值 |
| `constraints` | Workflow 输入 | 资源/技术/时间限制 |
| `compliance_requirements` | Workflow 输入 | 合规与安全要求 |
| `risk_level` | Workflow 输入 | 风险级别 |

## Execution Steps

1. **立项信息标准化**
   - 生成 `workflow_id`（格式: `WF-PD-YYYY-NNN`）
   - 指定 `business_owner`、`delivery_owner`、`tech_owner`

2. **优先级分级**
   - 按业务影响、时效、可逆性评分
   - 输出优先级: `P0` / `P1` / `P2`

3. **风险初筛**
   - 安全、合规、稳定性、资源四类风险
   - 建立初始 `risk_register`

4. **指标基线建立**
   - 由 Data Analyst Agent 产出当前基线
   - 记录指标口径、数据源、更新时间

5. **执行上下文初始化**
   - 创建 `integration_branch`
   - 记录 `integration_base_sha`
   - 初始化产物目录（建议）: `artifacts/product-development/{workflow_id}/`

## Output Contract

机器可判定 schema：

- `../../../schemas/workflows/product-development/product-development-step-artifact.schema.json`
- `artifact_type`: `pd-01-intake-output`

```json
{
  "workflow_id": "WF-PD-2026-001",
  "intake_record": {
    "title": "提升新用户激活率",
    "priority": "P1",
    "business_owner": "Product Team Leader Agent",
    "delivery_owner": "Project Manager Agent",
    "tech_owner": "Engineering Team Leader Agent",
    "deadline": "2026-06-30",
    "status": "accepted"
  },
  "risk_register": {
    "security": "medium",
    "compliance": "low",
    "stability": "medium",
    "resource": "medium",
    "mitigations": ["发布前执行安全扫描", "灰度发布"]
  },
  "metric_baseline": [
    {
      "metric": "activation_rate_d7",
      "baseline": 0.32,
      "data_source": "growth_dashboard"
    }
  ],
  "integration_branch": "feature/product-WF-PD-2026-001",
  "integration_base_sha": "9f8e7d6c"
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| Owner 完整性 | 100% | 清单检查 |
| KPI 基线完整性 | 每个目标指标均有 baseline | 数据校验 |
| 风险台账完整性 | 4 类风险必须覆盖 | 模板检查 |
| 分支初始化 | 必须成功 | Git 引用检查 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 目标不清晰 | 返回发起方补充立项信息 |
| 基线数据缺失 | Data Team 24h 内补齐 |
| 合规要求不明确 | 升级 Security Agent 澄清 |

## Handoff

- **成功**: 转入 `steps/02-discovery-specification.md`
- **失败**: 保持 `pending_intake`，不进入研发链路

## Duration Estimate

- 正常: 2-4 小时

