---
step_id: pd-08
step_name: System Verification
responsible_agent: Quality Assurance Team Leader Agent
inputs:
  - reviewed_ref
  - prd_package
  - acceptance_criteria
  - solution_design_package
  - ui_ux_design_package
  - risk_register
outputs:
  - qa_report
  - security_report
  - performance_report
  - defect_summary
  - qa_verdict
next_step: steps/09-release-readiness.md
failure_step: steps/06-implementation-self-test.md
---

# Step 8: System Verification - 系统级验证

## Purpose

执行功能、回归、安全、性能全量验证，产出发布前质量门禁结论。

## Responsible Agent

**Quality Assurance Team Leader Agent**（执行: Quality Assurance Agent, Security Agent, Performance Agent）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `reviewed_ref` | Step 07 输出 | 评审通过引用 |
| `prd_package` | Step 02 输出 | 需求与范围 |
| `acceptance_criteria` | Step 02 输出 | 验收标准 |
| `solution_design_package` | Step 04 输出 | 技术 NFR 与架构约束 |
| `ui_ux_design_package` | Step 03 输出 | UI/UX 规格约束 |
| `risk_register` | Step 01 输出 | 风险台账 |

## Execution Steps

1. **测试计划落地**
   - 按风险分层定义测试优先级
   - 明确冒烟、回归、端到端覆盖清单

2. **功能与回归验证**
   - 执行功能、集成、端到端测试
   - 验证关键路径自动化覆盖

3. **安全验证**
   - 执行依赖扫描、配置基线检查、关键路径安全验证
   - 输出漏洞分级与修复建议

4. **性能验证**
   - 执行压测与容量评估
   - 对比 NFR 目标，输出瓶颈与优化建议

5. **缺陷分诊与回归**
   - 按严重级别分诊（P0/P1/P2）
   - 对修复项执行回归验证

6. **门禁决策**
   - 输出 `qa_verdict`：`pass` / `fail`

## Output Contract

```json
{
  "qa_report": {
    "functional_cases": 186,
    "passed": 186,
    "failed": 0,
    "automation_coverage_key_paths": 0.84
  },
  "security_report": {
    "critical": 0,
    "high": 0,
    "medium": 2,
    "status": "pass_with_mitigations"
  },
  "performance_report": {
    "latency_p95_ms": 360,
    "error_rate": 0.003,
    "throughput_rps": 480,
    "status": "pass"
  },
  "defect_summary": {
    "P0": 0,
    "P1": 0,
    "P2": 3,
    "open_defects": ["BUG-121", "BUG-135", "BUG-148"]
  },
  "qa_verdict": {
    "status": "pass",
    "quality_gate": "G5",
    "residual_risks": ["低频边界场景存在 P2 待观察问题"]
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| P0/P1 缺陷 | 必须为 0 | 缺陷系统 |
| 关键路径自动化覆盖 | >= 80% | 覆盖率报告 |
| 安全高危漏洞 | 必须为 0 | 扫描报告 |
| 性能 NFR 达标 | 必须达标 | 压测报告 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| QA 失败 | 返回 Step 06 修复后重测 |
| 安全高危未修复 | 直接阻断发布 |
| 性能不达标 | 触发专项优化并回归 |

## Handoff

- **pass**: 转入 `steps/09-release-readiness.md`
- **fail**: 返回 `steps/06-implementation-self-test.md`

## Duration Estimate

- 正常: 1-3 个工作日
