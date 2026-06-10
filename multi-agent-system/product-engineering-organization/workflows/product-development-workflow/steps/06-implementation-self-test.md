---
step_id: pd-06
step_name: Implementation & Self-Test
responsible_agent: Engineering Team Leader Agent
inputs:
  - sprint_backlog
  - solution_design_package
  - ui_ux_design_package
  - interface_contracts
  - integration_branch
  - integration_base_sha
outputs:
  - engineering_delivery
  - unit_test_report
  - self_test_report
  - delivery_receipt
  - integrated_head_sha
next_step: steps/07-integration-code-review.md
failure_step: steps/05-planning-kickoff.md
---

# Step 6: Implementation & Self-Test - 实现与自测

## Purpose

在冻结范围内完成代码实现与自测，形成可评审、可集成、可追溯的工程交付。

## Responsible Agent

**Engineering Team Leader Agent**（执行: Frontend/Backend/AI Engineer Agents）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `sprint_backlog` | Step 05 输出 | 任务清单 |
| `solution_design_package` | Step 04 输出 | 设计方案 |
| `ui_ux_design_package` | Step 03 输出 | UI/UX 设计方案 |
| `interface_contracts` | Step 04 输出 | 接口契约 |
| `integration_branch` | Step 01 输出 | 主集成分支 |
| `integration_base_sha` | Step 01 输出 | 集成基线 |

## Execution Steps

1. **开发执行**
   - 各工程 Agent 在私有分支实现任务
   - 变更不得超出 `sprint_backlog` 范围

2. **单元测试与静态检查**
   - 补齐新增/变更逻辑的单元测试
   - 执行 lint、类型检查、基础静态扫描

3. **自测与联调**
   - 按验收标准执行自测
   - 核对接口契约一致性

4. **集成交付**
   - 将各私有分支提交回灌到 `integration_branch`
   - 产出 `delivery_receipt`（记录所有 commit 引用）

## Output Contract

机器可判定 schema：

- `../../../schemas/workflows/product-development/product-development-step-artifact.schema.json`
- `artifact_type`: `pd-06-implementation-output`

```json
{
  "engineering_delivery": {
    "changed_modules": ["web/onboarding", "service/onboarding-api"],
    "change_summary": "引导流程重构并新增完成事件上报",
    "linked_tasks": ["TASK-001", "TASK-002"]
  },
  "unit_test_report": {
    "total": 128,
    "passed": 128,
    "failed": 0,
    "coverage_line": 0.82
  },
  "self_test_report": {
    "acceptance_cases": 24,
    "passed": 24,
    "open_issues": []
  },
  "delivery_receipt": {
    "integration_branch": "feature/product-WF-PD-2026-001",
    "integration_base_sha": "9f8e7d6c",
    "integrated_head_sha": "a1b2c3d4",
    "agent_commit_shas": ["bb11cc22", "dd33ee44"],
    "status": "integrated"
  },
  "integrated_head_sha": "a1b2c3d4"
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 任务完成率 | 计划范围内 100% | Backlog 对账 |
| 单测通过率 | 100% | CI 报告 |
| 覆盖率 | 关键模块 >= 80% | 覆盖率报告 |
| 集成引用完整性 | 必须有 `integrated_head_sha` | 交付回执检查 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 进度滑坡 | Engineering TL 触发重排 |
| 契约不一致 | 立即修复或回退 |
| 自测失败 | 修复后重测，最多 2 次 |

## Handoff

- **成功**: 转入 `steps/07-integration-code-review.md`
- **失败**: 返回 `steps/05-planning-kickoff.md` 调整计划

## Duration Estimate

- 正常: 2-7 个工作日（按范围）
