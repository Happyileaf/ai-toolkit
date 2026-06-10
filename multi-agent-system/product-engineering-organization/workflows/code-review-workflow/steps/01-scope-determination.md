---
step_id: cr-01
step_name: Scope Determination
responsible_agent: Code Review Agent
inputs:
  - repositories
  - execution_date
  - custom_scope
outputs:
  - review_scope
  - scope_manifest
next_step: steps/02-code-understanding.md
failure_step: null
---

# Step 1: Scope Determination - 确定 Review 范围

## Purpose

根据仓库配置和输入参数自动确定每个仓库的评审模式（Daily Review / Weekly Review / Feature Branch Review），输出可执行的评审范围清单。

## Responsible Agent

**Code Review Agent** - 参考: `../../../agents/engineering-team/code-review-agent.md`

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `repositories` | Workflow 输入 | 仓库列表，含 `name`、`git_url`、`branch`；Feature Branch 模式需额外指定 `base_branch` |
| `execution_date` | Workflow 输入 | 执行日期，默认当天 |
| `custom_scope` | Workflow 输入 | 可选，覆盖自动模式判断 |

## Execution Steps

1. **解析执行日期**
   - 未提供 `execution_date` 时使用当天日期
   - 验证日期格式 `YYYY-MM-DD`

2. **确定评审模式与范围**
   ```yaml
   for each repo in repositories:
     if custom_scope.mode == "feature_branch" or repo.base_branch != null:
       # Feature Branch Review 模式
       mode = "feature_branch"
       scope_type = "diff"
       base_branch = custom_scope.base_branch or repo.base_branch
       base_branch = base_branch or "main"  # 默认 main
     else:
       # 根据日期判断 Daily / Weekly
       day_of_week = strftime(execution_date, "%A")
       if day_of_week == "Sunday":
         mode = "weekly"
         scope_type = "full"
       else:
         mode = "daily"
         scope_type = "incremental"
         since = execution_date - 1 day
   ```

3. **应用自定义覆盖**
   - 如果 `custom_scope` 已提供，`mode` 优先使用 `custom_scope.mode`
   - 支持 `commit_range`（指定 commit 区间）、`full`（全量）、`feature_branch`（需求分支 diff）

4. **验证仓库可访问性**
   - 对每个仓库执行 `git ls-remote` 验证可达性
   - 验证分支和 base_branch（Feature Branch 模式）存在性
   - 不可达的仓库标记 `unreachable` 并跳过

5. **生成评审范围清单**
   - 产出 `scope_manifest`，包含每个仓库的模式、范围、base_branch（如适用）、commit 引用

## Output Contract

```json
{
  "review_scope": {
    "execution_date": "2026-06-10",
    "mode": "daily",
    "day_of_week": "Wednesday"
  },
  "scope_manifest": [
    {
      "repo_name": "bookmark-lite",
      "branch": "main",
      "mode": "daily",
      "scope_type": "incremental",
      "since": "2026-06-09T00:00:00Z",
      "status": "accessible",
      "head_sha": "a1b2c3d4e5..."
    },
    {
      "repo_name": "ai-toolkit",
      "branch": "feat/add-bookmark-categories",
      "base_branch": "main",
      "mode": "feature_branch",
      "scope_type": "diff",
      "status": "accessible",
      "head_sha": "f6g7h8i9j0...",
      "base_sha": "a1b2c3d4..."
    }
  ]
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 仓库可访问性 | 所有仓库均验证 | `git ls-remote` |
| 模式判断正确 | 符合日期规则 | 自动化判定 |
| 范围覆盖 | 所有仓库均有评审范围 | manifest 完整性 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 仓库不可访问 | 跳过该仓库，标记 `unreachable` |
| 分支不存在 | 跳过该仓库，标记 `branch_not_found` |
| base_branch 不存在（Feature Branch） | 跳过该仓库，标记 `base_branch_not_found` |
| 日期格式无效 | 使用当天日期并警告 |

## Handoff

- **complete**: 转入 `steps/02-code-understanding.md`
- **部分仓库失败**: 跳过失败仓库，继续处理剩余仓库