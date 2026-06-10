---
step_id: cr-06
step_name: Report Generation
responsible_agent: Code Review Agent
inputs:
  - scope_manifest
  - project_analysis
  - change_summary
  - logic_issues
  - quality_issues
  - standards_issues
  - performance_issues
  - architecture_issues
  - correctness_verdict
  - quality_verdict
  - architecture_verdict
outputs:
  - per_repo_reports
  - summary_report
  - review_log
next_step: null
failure_step: null
---

# Step 6: Report Generation - 报告生成

## Purpose

汇总所有仓库的评审结果，为每个仓库生成独立的评审报告，并输出总览报告。

## Responsible Agent

**Code Review Agent** - 参考: `../../../agents/engineering-team/code-review-agent.md`

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| 所有前置步骤输出 | Steps 01-05 | 各评审维度的发现与结论 |

## Execution Steps

### 1. 为每个仓库生成独立评审报告

按照 `index.md` 定义的报告格式，为每个仓库生成报告：

```markdown
# Code Review Report

## Repository & Branch

- 仓库名：{repo_name}
- 分支：{branch}
- Git 地址：{git_url}

## Scope

- Daily Review（昨日提交）
- Weekly Review（全量代码）

## Summary

总体评价及主要发现。

## Critical

严重问题列表（来自 logic_issues 中 severity=critical 的条目）。

## Major

重要问题列表（来自各步骤中 severity=major 的条目）。

## Minor

一般问题列表（来自各步骤中 severity=minor 的条目）。

## Positive

优秀实践列表（来自 quality_verdict.positive_practices）。

## Suggestions

优化建议列表。
```

### 2. 生成总览报告

```markdown
# Code Review Summary

## Overview

本次 Review 共涉及 {n} 个仓库+分支。

## Repository Breakdown

| 仓库名 | 分支 | Critical | Major | Minor | Positive |
|--------|------|----------|-------|-------|----------|
| {repo1} | {branch1} | {count} | {count} | {count} | {count} |

## Overall Summary

整体评价及跨仓库发现的共性问题。
```

### 3. 生成 Review Log

记录评审过程的元信息：

```yaml
review_log:
  execution_date: "2026-06-10"
  mode: "daily"
  total_repos: 2
  reviewed_repos: 2
  skipped_repos: 0
  skipped_details: []
  total_issues:
    critical: 1
    major: 3
    minor: 2
    positive: 2
  cross_repo_patterns:
    - description: "两个仓库均存在 useEffect 依赖数组不完整的问题"
      affected_repos: ["bookmark-lite", "ai-toolkit"]
```

### 4. 产物持久化

- 将各仓库报告保存至 `artifacts/code-review/{execution_date}/repos/{repo_name}/review-report.md`
- 将总览报告保存至 `artifacts/code-review/{execution_date}/summary-report.md`
- 将 review_log 保存至 `artifacts/code-review/{execution_date}/review-log.yaml`
- 将结构化数据（JSON）保存至 `artifacts/code-review/{execution_date}/data/`

## Output Contract

```json
{
  "per_repo_reports": [
    {
      "repo_name": "bookmark-lite",
      "file_path": "artifacts/code-review/2026-06-10/repos/bookmark-lite/review-report.md",
      "summary": "代码质量整体良好，存在 1 个 Critical 空值问题和 2 个 Major 优化项"
    }
  ],
  "summary_report": {
    "file_path": "artifacts/code-review/2026-06-10/summary-report.md",
    "total_repos": 2,
    "reviewed_repos": 2,
    "total_critical": 1,
    "total_major": 3,
    "total_minor": 2,
    "total_positive": 2,
    "cross_repo_findings": [
      "两个仓库均存在 useEffect 依赖数组不完整的问题，建议统一审查"
    ]
  },
  "review_log": {
    "execution_date": "2026-06-10",
    "mode": "daily",
    "duration_minutes": 15,
    "total_repos": 2,
    "reviewed_repos": 2,
    "skipped_repos": 0,
    "skipped_details": [],
    "total_issues": {
      "critical": 1,
      "major": 3,
      "minor": 2,
      "positive": 2
    },
    "cross_repo_patterns": [
      {
        "description": "两个仓库均存在 useEffect 依赖数组不完整的问题",
        "affected_repos": ["bookmark-lite", "ai-toolkit"]
      }
    ]
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 报告完整性 | 每个仓库均有报告 | 文件存在性检查 |
| Critical 问题标注 | 正确分级 | 与前置步骤对比 |
| 汇总准确性 | 统计数据与各仓库一致 | 交叉验证 |
| 跨仓库模式识别 | 至少检查共性模式 | 模式匹配 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 某仓库数据不完整 | 标记 `incomplete`，仍输出已有内容 |
| 报告文件写入失败 | 重试 1 次，仍失败则记录错误并继续 |
| 跨仓库模式无发现 | 输出空列表，不做硬性要求 |

## Handoff

- **completed**: 工作流结束，输出所有报告
- 如有 Critical 阻塞问题，升级至 **Engineering Team Leader Agent**