---
step_id: cr-04
step_name: Code Quality & Engineering Standards Review
responsible_agent: Code Review Agent
inputs:
  - project_analysis
  - change_summary
  - logic_issues
  - engineering_standards
outputs:
  - quality_issues
  - standards_issues
  - quality_verdict
next_step: steps/05-performance-architecture-review.md
failure_step: steps/03-logic-correctness-review.md
---

# Step 4: Code Quality & Engineering Standards Review - 代码质量与工程规范审查

## Purpose

审查代码质量（命名、重复、复杂度、可维护性）和工程规范（TypeScript 类型、测试覆盖、ESLint 及项目规范）两个维度。

## Responsible Agent

**Code Review Agent** - 参考: `../../../agents/engineering-team/code-review-agent.md`

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `project_analysis` | Step 02 输出 | 项目结构与核心模块分析 |
| `change_summary` | Step 02 输出 | 变更摘要 |
| `logic_issues` | Step 03 输出 | 已发现的逻辑问题（避免重复） |
| `engineering_standards` | Workflow 输入 | 工程规范引用，默认 `../../../rules/coding/` |

## Execution Steps

对每个仓库依次执行以下检查：

### 1. 代码质量检查

#### 1.1 命名清晰度
```yaml
checklist:
  - variable_naming: 变量名是否表意清晰，避免单字母/缩写
  - function_naming: 函数名是否体现行为，动词开头
  - component_naming: 组件名是否 PascalCase
  - file_naming: 文件名是否符合项目规范（kebab-case / camelCase）
  - consistency: 同一概念是否使用统一命名
```

#### 1.2 重复代码
```yaml
checklist:
  - duplicate_logic: 是否存在多处相似的业务逻辑
  - copy_paste: 是否存在明显的复制粘贴代码块
  - magic_numbers: 是否存在未命名的魔术数字/字符串
  - utility_extraction: 重复逻辑是否可提取为工具函数
```

#### 1.3 函数复杂度
```yaml
checklist:
  - function_length: 单个函数是否过长（建议 <= 50 行）
  - nested_depth: 嵌套层级是否过深（建议 <= 3 层）
  - parameter_count: 参数数量是否合理（建议 <= 3 个）
  - single_responsibility: 函数是否违反单一职责原则
```

#### 1.4 可维护性
```yaml
checklist:
  - comments_needed: 复杂逻辑是否缺少必要注释
  - dead_code: 是否存在注释掉的代码或未使用的导入/变量
  - todo_fixme: 是否存在遗留的 TODO / FIXME
  - error_messages: 错误信息是否可理解、可追踪
```

### 2. 工程规范检查

引用 `../../../rules/coding/` 目录中的项目规范：

#### 2.1 TypeScript 类型完整性
```yaml
checklist:
  - explicit_types: 函数参数和返回值是否有显式类型
  - any_usage: 是否存在不必要的 `any` 类型
  - interface_vs_type: 是否遵循项目类型定义规范
  - generic_proper: 泛型使用是否合理
  - null_undefined: null/undefined 类型是否明确标注
```

#### 2.2 测试覆盖
```yaml
checklist:
  - test_existence: 新增功能是否有对应的测试文件
  - test_quality: 测试是否覆盖关键路径与边界条件
  - test_naming: 测试用例命名是否表意清晰
  - coverage_gaps: 核心逻辑是否有明显的测试缺口
```

#### 2.3 ESLint 及项目规范
```yaml
checklist:
  - lint_errors: 是否存在 ESLint 错误
  - lint_warnings: 是否存在 ESLint 警告（需确认）
  - project_convention: 是否遵循项目特定的代码约定
```

### 3. 问题分级与输出

```yaml
severity_levels:
  major: 明显违反质量或规范标准，需整改
  minor: 建议优化项，不影响功能
  positive: 值得肯定的优秀实践
```

## Output Contract

```json
{
  "quality_issues": [
    {
      "id": "CQ-001",
      "repo_name": "bookmark-lite",
      "file": "src/utils/format.ts",
      "line": 23,
      "severity": "minor",
      "category": "命名",
      "description": "变量名 `arr` 语义不清晰，应体现其存储的数据含义",
      "suggestion": "重命名为 `bookmarkList` 或 `items`"
    },
    {
      "id": "CQ-002",
      "repo_name": "bookmark-lite",
      "file": "src/components/BookmarkCard.tsx",
      "line": 56,
      "severity": "major",
      "category": "重复代码",
      "description": "格式化逻辑在 BookmarkCard 和 BookmarkList 中各出现一次，逻辑相同",
      "suggestion": "提取为 `src/utils/format.ts` 中的共享函数"
    }
  ],
  "standards_issues": [
    {
      "id": "STD-001",
      "repo_name": "bookmark-lite",
      "file": "src/hooks/useBookmark.ts",
      "line": 12,
      "severity": "major",
      "category": "TypeScript 类型",
      "description": "函数返回值类型标注为 `any`，失去了类型检查保障",
      "suggestion": "定义明确的返回类型接口替代 any"
    }
  ],
  "quality_verdict": {
    "repo_name": "bookmark-lite",
    "major_count": 2,
    "minor_count": 1,
    "positive_practices": [
      "组件拆分粒度合理，BookmarkCard 职责单一",
      "自定义 Hook 封装了远程数据获取逻辑，可复用性良好"
    ],
    "summary": "代码整体质量良好，存在少量命名和重复代码问题"
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 规范引用完整性 | 引用所有活跃规范 | 对比规范索引 |
| TypeScript `any` 检查 | 高风险变更中 `any` 为 0 | 模式匹配 |
| 测试覆盖检查 | 新增功能有测试 | 文件匹配 |
| 问题非重复 | 不与 Step 03 重复 | ID 去重 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 规范文件不可读 | 使用默认规范基线 |
| 测试文件不存在 | 标记 `test_missing`，不阻塞评审 |
| ESLint 配置缺失 | 使用通用 ESLint 规则检查 |

## Handoff

- **complete**: 转入 `steps/05-performance-architecture-review.md`