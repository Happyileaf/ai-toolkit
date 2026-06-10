---
step_id: creation-04
step_name: Review
responsible_agent: Review Agent
inputs:
  - skill_files
  - delivery_receipt
  - quality_standards
  - checklist
outputs:
  - quality_report
  - decision
  - reviewed_ref
  - integration_branch
next_step: steps/05-registration.md
failure_step: steps/03-generation.md
---

# Step 4: Review - 质量审计与评分

## Purpose

执行全面质量检查，产出评分报告与发布决策。

## Responsible Agent

**Review Agent** - 参考: `../../../agents/skills-team/skills-review-agent.md`

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `skill_files` | Step 03 输出 | Skill 文件包 |
| `delivery_receipt` | Step 03 输出 | 集成交付回执（含分支与 commit 引用） |
| `quality_standards` | `../../../skill-quality-checklist.md` | 质量标准 |
| `checklist` | `../../../skill-quality-checklist.md` | 检查清单 |

## Execution Steps

1. **文件解析**
   - 解析 SKILL.md
   - 解析 _meta.json
   - 解析示例文件

2. **集成交付检查（前置门禁）**
   ```yaml
   integration_gate:
     - integration_branch: unique_and_present
     - integrated_head_sha: matches_branch_head
     - private_branch_direct_review: forbidden
   ```

3. **规范合规检查 (30%)**
   ```yaml
   compliance_check:
     - naming_convention: NAMING-001
     - structure: REACT-001 (如适用)
     - comments: COMMENT-001
     - enum_definition: ENUM-001 (如适用)
   ```

4. **文档完整性检查 (25%)**
   ```yaml
   documentation_check:
     - required_fields: [name, description, version, inputs, outputs]
     - trigger_conditions: 明确
     - workflow_steps: 完整
     - examples: >= 2
   ```

5. **示例可执行性检查 (25%)**
   ```yaml
   example_check:
     - example_01: runnable
     - example_02: runnable
     - coverage: main_scenarios
   ```

6. **依赖正确性检查 (20%)**
   ```yaml
   dependency_check:
     - declared: complete
     - circular: none
     - version: explicit
     - depth: <= 3
   ```

7. **阻塞项检查**
   ```yaml
   blocking_check:
     - security_issues: none
     - circular_dependency: none
     - core_documentation_missing: none
   ```

8. **评分计算**
   ```
   score = compliance(30%) + documentation(25%) + examples(25%) + dependencies(20%)
   ```

9. **机器可判定产物 Schema 校验**
   - Schema: `../../../schemas/workflows/skill-creation/skill-quality-report.schema.json`

## Output Contract

```json
{
  "quality_report": {
    "skill_id": "SKILL-XXX",
    "score": 85,
    "score_breakdown": {
      "compliance": 28,
      "documentation": 24,
      "examples": 23,
      "dependencies": 20
    },
    "issues": [
      {
        "id": "ISSUE-001",
        "category": "文档",
        "severity": "suggestion",
        "description": "示例 02 缺少预期输出说明",
        "fix_suggestion": "添加 output_contract 部分"
      }
    ],
    "blocking_issues": [],
    "passed_checks": ["compliance", "dependencies"],
    "warning_checks": ["documentation"],
    "check_time": "2026-06-02T10:00:00Z"
  },
  "decision": {
    "status": "pass",
    "reason": "评分 >= 80 且无阻塞问题",
    "retry_count": 0,
    "next_action": "registration",
    "reviewed_ref": "a1b2c3d4",
    "integration_branch": "feature/skill-WF-001"
  }
}
```

## Decision Rules

| 条件 | 决策 | 后续动作 |
|------|------|----------|
| 未通过集成交付门禁 | fail | 返回 Generation 完成回灌 |
| score >= 80 且无阻塞 | pass | 转入 Registration |
| score < 80 或有阻塞 | fail | 返回 Generation 修复 |
| 连续 3 次 fail | escalate | 升级 Librarian 仲裁 |

## Quality Checklist Reference

详细检查项见: `../../../skill-quality-checklist.md`

## Failure Handling

| 场景 | 处理 |
|------|------|
| 检查工具故障 | 标记"人工审核"，升级 |
| 标准 模糊 | 标记"需澄清"，暂停 |
| 连续 3 次失败 | 升级 Librarian Agent 仲裁 |

## Handoff

- **pass**: 转入 `steps/05-registration.md`
- **fail**: 返回 `steps/03-generation.md`，最多 3 次
- **escalate**: 升级 Librarian Agent

## Duration Estimate

- 正常: 1-2 小时
- 人工审核: +4 小时
