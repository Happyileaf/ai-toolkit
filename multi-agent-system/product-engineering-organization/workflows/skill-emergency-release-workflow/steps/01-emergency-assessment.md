---
step_id: emergency-01
step_name: Emergency Assessment
responsible_agent: Evolution Agent
inputs:
  - issue_report
  - severity_data
outputs:
  - emergency_assessment
next_step: steps/02-quick-audit.md
---

# Step 1: Emergency Assessment - 紧急判定

## Purpose

检测并确认安全/重大问题是否属于紧急发布范畴。

## Responsible Agent

**Evolution Agent**（触发），**Librarian Agent**（决策）

## Execution Steps

1. **接收问题报告**
   - 从 Evolution Agent 的检测结果中获取问题信息

2. **评估紧急级别**

   | 类型 | 条件 | 时间要求 |
   |------|------|----------|
   | **安全问题** | 存在安全漏洞或风险 | 24 小时内 |
   | **重大 Bug** | 影响 > 50% 用户 | 48 小时内 |
   | **严重故障** | Skill 完全无法使用 | 48 小时内 |

3. **生成评估结果**

```yaml
emergency_assessment:
  type: security
  severity: critical
  affected_users: "100%"
  time_requirement: "24 hours"
  bypass_normal_process: true
```

4. **提交 Librarian Agent 批准**

## Output Contract

```json
{
  "emergency_assessment": {
    "emergency_type": "security | critical_bug | severe_failure",
    "severity": "critical",
    "affected_users_percentage": "100%",
    "time_requirement": "24 hours",
    "bypass_normal_process": true,
    "approved_by": "Librarian Agent"
  }
}
```

## Duration Estimate

- 正常: 15 分钟
