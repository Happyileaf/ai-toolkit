---
step_id: cr-02
step_name: Code Understanding
responsible_agent: Code Review Agent
inputs:
  - scope_manifest
  - engineering_standards
outputs:
  - project_analysis
  - change_summary
next_step: steps/03-logic-correctness-review.md
failure_step: steps/01-scope-determination.md
---

# Step 2: Code Understanding - 理解代码

## Purpose

对每个仓库执行代码获取与项目结构分析，理解核心模块与本次变更内容，为后续评审提供上下文。

## Responsible Agent

**Code Review Agent** - 参考: `../../../agents/engineering-team/code-review-agent.md`

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `scope_manifest` | Step 01 输出 | 评审范围清单 |
| `engineering_standards` | Workflow 输入 | 工程规范引用列表 |

## Execution Steps

对 `scope_manifest` 中状态为 `accessible` 的每个仓库依次执行：

1. **克隆 / 拉取仓库**
   - 克隆仓库至本地工作目录
   - 切换至指定分支
   - 拉取最新代码

2. **确定 Review 引用与变更范围**
   - Daily 模式: 获取 `since` 之后的提交列表，计算 `reviewed_ref`（HEAD SHA）
   - Weekly 模式: 获取当前分支 HEAD 作为 `reviewed_ref`
   - Feature Branch 模式:
     - 获取 `base_branch` 的最新 SHA 作为 `base_sha`
     - 获取当前分支 HEAD 作为 `head_sha`
     - `reviewed_ref` = `head_sha`
     - 变更范围 = `base_sha...head_sha` 的 diff

3. **分析项目结构**
   ```yaml
   project_analysis:
     - language: TypeScript / Python / Go 等
     - framework: React / Next.js / FastAPI 等
     - package_manager: npm / yarn / pnpm / poetry 等
     - directory_structure: 核心目录与模块划分
     - config_files: tsconfig, eslint, prettier 等
   ```

4. **识别核心模块**
   - 通过目录结构分析识别核心业务模块
   - 标注模块间的依赖关系

5. **提取变更摘要**
   - Daily 模式：基于 `git log --since` 获取变更；
   - Feature Branch 模式：基于 `git diff base_sha...head_sha` 获取变更；
   - 所有模式都产出统一的 change_summary 结构：
     - 获取所有变更文件的列表
     - 统计文件变更类型（新增/修改/删除）
     - 提取 commit message 作为变更背景
     - 标注高风险文件（核心模块、公共工具类等）

6. **输出分析结果**
   - 产出 `project_analysis` 与 `change_summary`

## Output Contract

### Daily / Weekly 模式

```json
{
  "project_analysis": {
    "repo_name": "bookmark-lite",
    "branch": "main",
    "reviewed_ref": "a1b2c3d4",
    "language": "TypeScript",
    "framework": "React + Next.js",
    "core_modules": [
      { "name": "components", "path": "src/components", "description": "UI 组件" },
      { "name": "hooks", "path": "src/hooks", "description": "自定义 Hook" },
      { "name": "utils", "path": "src/utils", "description": "工具函数" }
    ]
  },
  "change_summary": {
    "mode": "daily",
    "since": "2026-06-09T00:00:00Z",
    "commit_count": 3,
    "files_changed": 5,
    "file_breakdown": {
      "added": 2,
      "modified": 3,
      "deleted": 0
    },
    "high_risk_files": ["src/hooks/useBookmark.ts"],
    "commit_messages": ["feat: add bookmark sorting", "fix: handle empty state"]
  }
}
```

### Feature Branch 模式

```json
{
  "project_analysis": {
    "repo_name": "bookmark-lite",
    "branch": "feat/add-bookmark-categories",
    "base_branch": "main",
    "reviewed_ref": "f6g7h8i9",
    "base_sha": "a1b2c3d4",
    "head_sha": "f6g7h8i9",
    "language": "TypeScript",
    "framework": "React + Next.js",
    "core_modules": [
      { "name": "components", "path": "src/components", "description": "UI 组件" },
      { "name": "hooks", "path": "src/hooks", "description": "自定义 Hook" },
      { "name": "utils", "path": "src/utils", "description": "工具函数" }
    ]
  },
  "change_summary": {
    "mode": "feature_branch",
    "base_branch": "main",
    "base_sha": "a1b2c3d4",
    "head_sha": "f6g7h8i9",
    "commit_count": 3,
    "files_changed": 5,
    "file_breakdown": {
      "added": 2,
      "modified": 3,
      "deleted": 0
    },
    "high_risk_files": ["src/hooks/useCategories.ts", "src/api/categoryService.ts"],
    "commit_messages": ["feat: add bookmark category CRUD", "fix: category sort order", "refactor: extract category hooks"]
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 仓库克隆成功 | 100% | git clone 结果 |
| 分支切换正确 | 匹配 scope_manifest | git branch 确认 |
| 变更提取完整（Daily） | commit 列表完整 | git log 对比 |
| 变更提取完整（Feature Branch） | diff 覆盖所有变更 | git diff base...head 对比 |
| 核心模块识别 | 至少覆盖主要目录 | 结构分析 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 克隆失败 | 重试 1 次，仍失败则跳过该仓库 |
| 分支切换失败 | 标记 `branch_switch_failed`，跳过该仓库 |
| base_branch 拉取失败（Feature Branch） | 标记 `base_branch_fetch_failed`，跳过该仓库 |
| Feature Branch 与 base_branch 无 diff | 标记 `no_diff`，跳过评审 |
| 项目结构无法解析 | 标记 `structure_unresolved`，继续执行基础分析 |

## Handoff

- **complete**: 转入 `steps/03-logic-correctness-review.md`
- **仓库跳过**: 在报告中标记跳过的仓库及原因