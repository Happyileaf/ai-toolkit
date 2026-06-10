---
step_id: cr-03
step_name: Logic & Correctness Review
responsible_agent: Code Review Agent
inputs:
  - project_analysis
  - change_summary
outputs:
  - logic_issues
  - correctness_verdict
next_step: steps/04-code-quality-standards-review.md
failure_step: steps/02-code-understanding.md
---

# Step 3: Logic & Correctness Review - 逻辑正确性审查

## Purpose

审查代码的逻辑正确性，识别空值与边界条件处理、异步逻辑、状态管理等方面的潜在缺陷。

## Responsible Agent

**Code Review Agent** - 参考: `../../../agents/engineering-team/code-review-agent.md`

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `project_analysis` | Step 02 输出 | 项目结构与核心模块分析 |
| `change_summary` | Step 02 输出 | 变更摘要与高风险文件 |

## Execution Steps

对每个仓库的代码变更（Daily 模式）或全量代码（Weekly 模式）执行以下检查：

### 1. 空值与边界条件检查

```yaml
checklist:
  - nullable_variables: 变量使用前是否判空
  - array_boundary: 数组索引是否越界
  - optional_chaining: 可选链操作符使用是否一致
  - default_values: 函数参数默认值是否合理
  - edge_cases: 空列表、空字符串、0 值等边界处理
  - type_guards: 类型守卫是否覆盖所有分支
```

### 2. 异步逻辑检查

```yaml
checklist:
  - promise_handling: Promise 是否有 catch / reject 处理
  - async_await: async 函数内 await 是否遗漏
  - race_conditions: 并发操作是否存在竞态条件
  - error_boundaries: 异步错误是否有兜底处理
  - loading_states: 异步操作 loading/error 状态是否完备
  - cleanup: useEffect 清理函数是否取消未完成的异步操作
```

### 3. 状态管理检查

```yaml
checklist:
  - state_initialization: 状态初始值是否合理
  - state_updates: 状态更新逻辑是否可预测
  - derived_state: 派生状态是否使用 useMemo / useCallback
  - stale_closure: 闭包中是否捕获过期状态
  - global_state: 全局状态变更是否可控
```

### 4. React Hook 使用检查（如适用）

```yaml
checklist:
  - hooks_rules: Hook 调用顺序是否违反 Rules of Hooks
  - dependency_array: useEffect / useMemo / useCallback 依赖数组是否完整
  - infinite_loops: 是否存在无限渲染循环风险
  - custom_hooks: 自定义 Hook 逻辑是否自洽
```

### 5. 问题分级

```yaml
severity_levels:
  critical: 可能导致错误结果、数据损坏或运行时崩溃
  major: 可能导致非预期行为，特定条件下触发
  minor: 代码健壮性不足但在当前场景下影响有限
```

## Output Contract

```json
{
  "logic_issues": [
    {
      "id": "CR-001",
      "repo_name": "bookmark-lite",
      "file": "src/hooks/useBookmark.ts",
      "line": 45,
      "severity": "critical",
      "category": "边界条件",
      "description": "bookmarkList 可能为 null 时未做空值检查，直接调用 .map() 会抛 TypeError",
      "suggestion": "添加 bookMarkList?.map() 或前置空值判断"
    },
    {
      "id": "CR-002",
      "repo_name": "bookmark-lite",
      "file": "src/components/BookmarkList.tsx",
      "line": 78,
      "severity": "major",
      "category": "异步逻辑",
      "description": "fetchBookmarks 的 catch 块未处理网络错误，错误信息被静默吞掉",
      "suggestion": "在 catch 中设置 error state 并展示错误提示"
    }
  ],
  "correctness_verdict": {
    "repo_name": "bookmark-lite",
    "critical_count": 1,
    "major_count": 1,
    "minor_count": 0,
    "has_blocking": true,
    "summary": "发现 1 个可能导致崩溃的空值问题和 1 个错误处理缺失问题"
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 空值检查覆盖 | 高风险文件 100% | 逐文件审查 |
| 异步错误处理 | 所有异步操作均处理 | 模式匹配 |
| Hook 依赖完整性 | 无遗漏依赖 | 规则检查 |
| 问题分级准确 | 符合分级标准 | 人工复核 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 代码无法解析 | 标记 `parse_error`，尝试逐块分析 |
| 存在 Critical 问题 | 记录为阻塞项，后续汇总升级 |
| 依赖数组明显缺失 | 标记为 Major 问题 |

## Handoff

- **complete**: 转入 `steps/04-code-quality-standards-review.md`