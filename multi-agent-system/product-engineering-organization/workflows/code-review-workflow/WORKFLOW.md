---
name: code-review-workflow
description: 独立代码评审工作流，支持多仓库、多分支的 Daily/Weekly/Feature Branch 代码审查，识别潜在问题并提供可执行改进建议。
version: 1.1.0
entry: WORKFLOW.md
status: active
type: workflow
category: quality-assurance
tags:
  - code-review
  - quality
  - inspection
  - daily-review
  - weekly-review
  - feature-branch-review
dependencies:
  - ../../agents/engineering-team/code-review-agent.md
  - ../../agents/engineering-team/architect-agent.md
  - ../../agents/engineering-team/engineering-team-leader-agent.md
steps:
  - steps/01-scope-determination.md
  - steps/02-code-understanding.md
  - steps/03-logic-correctness-review.md
  - steps/04-code-quality-standards-review.md
  - steps/05-performance-architecture-review.md
  - steps/06-report-generation.md
inputs:
  - repositories
  - execution_date
  - custom_scope
  - engineering_standards
outputs:
  - per_repo_reports
  - summary_report
  - review_log
  - reviewed_refs
requires_agents:
  - Code Review Agent
  - Architect Agent
  - Engineering Team Leader Agent
---

# Workflow: Code Review

## Purpose

对指定仓库的指定分支执行结构化代码评审，识别逻辑正确性、代码质量、性能风险、架构一致性和工程规范方面的潜在问题，并提供可执行的改进建议。

该流程由 **Code Review Agent** 编排执行，支持三种模式：

- **Daily Review**（增量）— 周一至六，Review 前一天提交
- **Weekly Review**（全量）— 周日，Review 当前分支全部代码
- **Feature Branch Review**（Diff）— 任何时候，Review 需求分支相对于主分支的变更

## Agents Involved

| 步骤 | 负责 Agent | 主要产出 |
|------|-----------|----------|
| Scope Determination | Code Review Agent | 评审范围清单（仓库+分支+模式） |
| Code Understanding | Code Review Agent | 项目结构分析、变更摘要 |
| Logic & Correctness Review | Code Review Agent | 逻辑问题清单（Critical/Major） |
| Code Quality & Standards Review | Code Review Agent | 质量问题清单 + 工程规范检查结果 |
| Performance & Architecture Review | Code Review Agent, Architect Agent | 性能风险 + 架构一致性问题 |
| Report Generation | Code Review Agent | 各仓库评审报告 + 总览报告 |

## Required Inputs

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `repositories` | array | 是 | 仓库列表，每项包含 `name`、`git_url`、`branch`；Feature Branch 模式需额外指定 `base_branch` |
| `execution_date` | string | 否 | 执行日期，默认当天；格式 `YYYY-MM-DD` |
| `custom_scope` | object | 否 | 自定义范围覆盖，可指定 `commit_range` / `full` / `feature_branch` |
| `engineering_standards` | array | 否 | 工程规范引用列表，默认引用 `../../../rules/coding/` |

## Branching & Artifact Baseline

- 工作流启动时根据 `repositories` 列表克隆各仓库并切换至指定分支。
- Daily Review 模式：基于 `git log --since` 获取前一天提交，不创建分支。
- Weekly Review 模式：拉取当前分支 HEAD 全量分析。
- Feature Branch Review 模式：基于 `git diff base_branch...branch` 获取需求分支相对于主分支的变更，仅评审这些变更。
- 所有审查结论必须绑定 `repo_name` + `branch` + `reviewed_ref`（commit SHA）。
- 建议统一产物目录：`artifacts/code-review/{execution_date}/`，每步生成结构化文件。

## Execution Flow

详细步骤见：

- `./steps/01-scope-determination.md` - 确定 Review 范围
- `./steps/02-code-understanding.md` - 理解代码结构与变更
- `./steps/03-logic-correctness-review.md` - 检查逻辑正确性
- `./steps/04-code-quality-standards-review.md` - 检查代码质量与工程规范
- `./steps/05-performance-architecture-review.md` - 检查性能与架构
- `./steps/06-report-generation.md` - 输出 Review 报告

严格按上述顺序执行，每个仓库处理完一个完整循环后再处理下一个。

## Scope Determination Rules

根据仓库配置和输入参数自动判断评审模式：

| 条件 | 模式 | 范围 | 目标 |
|------|------|------|------|
| `custom_scope.mode` 指定为 `feature_branch` | Feature Branch Review | 需求分支相对主分支的 diff | 审查需求变更，确保质量达标后合并 |
| 仓库指定了 `base_branch` 且不等于 `branch` | Feature Branch Review | 需求分支相对 `base_branch` 的 diff | 审查需求变更，确保质量达标后合并 |
| 周一至周六（无 feature branch 配置） | Daily Review | 前一天提交的代码变更 | 快速发现新增问题，控制 Review 成本 |
| 周日（无 feature branch 配置） | Weekly Review | 当前分支全量代码 | 全量质量巡检，发现历史遗留问题 |

优先级：`custom_scope` > 仓库 `base_branch` 配置 > 日期自动判断。

## Review Dimensions

每次评审覆盖以下五个维度：

| 维度 | 权重 | 关注点 |
|------|------|--------|
| 逻辑正确性 | High | 空值与边界条件、异步逻辑、状态管理、React Hook 使用 |
| 代码质量 | High | 命名清晰度、重复代码、函数长度、可维护性 |
| 性能风险 | Medium | 不必要的渲染、重复计算、资源泄漏 |
| 架构一致性 | Medium | 模块职责清晰度、跨模块边界、设计合理性 |
| 工程规范 | Medium | TypeScript 类型完整性、测试覆盖、ESLint 及项目规范 |

## Quality Gates

| 门禁 | 条件 | 失败处理 |
|------|------|----------|
| G0 范围准入 | 仓库可访问、分支存在、commit 可追溯 | 跳过该仓库，标记原因 |
| G1 代码可读性 | 代码变更可解析、项目结构清晰 | 标记需人工介入 |
| G2 阻塞问题门禁 | Critical 问题为 0 | 生成阻塞报告，升级 Engineering Team Leader |
| G3 报告完整性 | 每个仓库均产出结构化报告 | 补充缺失报告 |

## State Model

```text
scope_determination
  -> code_understanding
  -> logic_correctness_review
  -> code_quality_standards_review
  -> performance_architecture_review
  -> report_generation
  -> completed

每个仓库独立循环：
  for each repo in repositories:
    run steps 02-05 for this repo
  -> step 06: generate combined report

任何步骤失败 -> 跳过当前仓库，标记异常原因 -> 继续处理下一个仓库。
```

## Retry & Escalation Policy

- 单仓库单步骤最多重试 1 次（如 clone 失败可重试）。
- 连续 2 次失败 -> 跳过该仓库，标记为 `skipped`。
- 发现安全高危问题 -> 立即升级至 **Engineering Team Leader Agent**。
- 架构问题仲裁 -> 引入 **Architect Agent** 参与。

## Failure Handling

| 场景 | 处理策略 |
|------|----------|
| 仓库不可访问 | 跳过该仓库，在报告中标记 `unreachable` |
| 分支不存在 | 跳过该仓库，在报告中标记 `branch_not_found` |
| 无昨日提交（Daily） | 跳过评审，标记 `no_new_commits` |
| Feature Branch 的 base_branch 不存在 | 跳过该仓库，标记 `base_branch_not_found` |
| Feature Branch 与 base_branch 无差异 | 跳过评审，标记 `no_diff_found` |
| 发现安全高危问题 | 立即生成阻塞报告，升级 Engineering Team Leader |
| 架构偏离严重 | 引入 Architect Agent 仲裁，记录架构偏差 |
| 评审结论不可追溯 | 标记审计失败，要求重新执行 |

## Output Contract

工作流最终输出包含：

1. `per_repo_reports`: 每个仓库的独立评审报告，格式见 Step 06
2. `summary_report`: 总览报告，包含所有仓库的问题统计
3. `review_log`: 评审过程日志（含跳过的仓库及原因）
4. `reviewed_refs`: 各仓库审查的 commit SHA 引用列表

## Copy-Paste Input Template

### Daily/Weekly Review

```text
请按 workflow 入口文件执行：
./workflows/code-review-workflow/WORKFLOW.md

输入参数：
- repositories:
    - name: bookmark-lite
      git_url: git@github.com:Happyileaf/bookmark-lite.git
      branch: main
    - name: ai-toolkit
      git_url: git@github.com:Happyileaf/ai-toolkit.git
      branch: main
- execution_date: 2026-06-10
- engineering_standards:
  - ../../../rules/coding/naming-convention.md
  - ../../../rules/coding/react-component.md
  - ../../../rules/coding/enum-definition.md
  - ../../../rules/coding/comment-convention.md
```

### Feature Branch Review

```text
请按 workflow 入口文件执行：
./workflows/code-review-workflow/WORKFLOW.md

输入参数：
- repositories:
    - name: bookmark-lite
      git_url: git@github.com:Happyileaf/bookmark-lite.git
      branch: feat/add-bookmark-categories
      base_branch: main
    - name: ai-toolkit
      git_url: git@github.com:Happyileaf/ai-toolkit.git
      branch: fix/memory-leak
      base_branch: main
- execution_date: 2026-06-10
- engineering_standards:
  - ../../../rules/coding/naming-convention.md
  - ../../../rules/coding/react-component.md
  - ../../../rules/coding/enum-definition.md
  - ../../../rules/coding/comment-convention.md
```