```markdown
# code-review

## 目标

对指定仓库的指定分支进行代码评审，识别潜在问题并提供可执行的改进建议。

重点关注：

- 逻辑正确性
- 代码质量
- 可维护性
- 性能风险
- 工程规范

---

## 上下文

### 仓库列表

| 仓库名 | Git 地址 | 分支 |
|--------|----------|------|
| bookmark-lite | git@github.com:Happyileaf/bookmark-lite.git | main |
| ai-toolkit | git@github.com:Happyileaf/ai-toolkit.git | main |


Agent 应拉取仓库并切换至指定分支进行分析。

---

## Review 范围

根据执行日期自动确定 Review 范围：

### 周一至周六

仅 Review 前一天产生的提交和代码变更。

目标：

- 快速发现新增问题
- 控制 Review 成本
- 提供持续质量反馈

### 周日

Review 当前分支全部代码。

目标：

- 全量质量巡检
- 发现历史遗留问题
- 识别架构与规范问题
- 输出长期改进建议

---

## 执行步骤

对每个仓库+分支分别执行以下步骤：

### 1. 确定 Review 范围

根据当前日期自动判断：

- 周一至周六：Review 前一天提交
- 周日：Review 当前分支全量代码

### 2. 理解代码

分析：

- 项目结构
- 核心模块
- 本次变更内容

### 3. 检查逻辑问题

关注：

- 空值与边界条件
- 异步逻辑
- 状态管理
- React Hook 使用

### 4. 检查代码质量

关注：

- 命名是否清晰
- 是否存在重复代码
- 函数是否过长
- 是否易于理解和维护

### 5. 检查性能与架构

关注：

- 不必要的渲染
- 重复计算
- 模块职责是否清晰
- 是否存在明显设计问题

### 6. 检查工程规范

关注：

- TypeScript 类型完整性
- 测试覆盖情况
- ESLint 及项目规范

### 7. 输出 Review 报告

为每个仓库+分支分别输出独立的报告，格式如下：

```markdown
# Code Review Report

## Repository & Branch

- 仓库名：{repository_name}
- 分支：{branch_name}
- Git 地址：{git_url}

## Scope

- Daily Review（昨日提交）
- Weekly Review（全量代码）

## Summary

总体评价及主要发现。

## Critical

严重问题。

## Major

重要问题。

## Minor

一般问题。

## Positive

优秀实践。

## Suggestions

优化建议。
```

所有仓库+分支的报告输出完成后，输出一个总览报告：

```markdown
# Code Review Summary

## Overview

本次 Review 共涉及 {n} 个仓库+分支。

## Repository Breakdown

| 仓库名 | 分支 | Critical | Major | Minor | Positive |
|--------|------|----------|-------|-------|----------|
| {repo1} | {branch1} | {count} | {count} | {count} | {count} |
| {repo2} | {branch2} | {count} | {count} | {count} | {count} |
| ... | ... | ... | ... | ... | ... |

## Overall Summary

整体评价及跨仓库发现的共性问题。
```

---

## 评审原则

- 优先发现真实问题
- 避免过度设计
- 尊重现有架构
- 建议必须可落地
- 保持简洁、专业、客观

```

```