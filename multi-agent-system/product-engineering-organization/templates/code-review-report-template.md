# 代码评审报告

> 本报告由代码评审工作流（Code Review Workflow）自动生成，用于记录对目标代码仓库的结构化评审结果。报告覆盖评审基本信息、问题统计与总体评价、按严重等级分组的问题汇总及详情，以及优秀实践和改进建议，旨在帮助团队快速识别代码质量风险、推动持续改进。

---

## 一、评审基本信息

| 字段 | 值 |
|------|-----|
| 仓库 | {{repository_url}} |
| 仓库名称 | {{repository_name}} |
| 分支 | {{branch_name}} |
| 对比基线分支 | {{base_branch}} |
| 评审模式 | {{review_mode}} |
| 评审范围 | {{review_scope_description}} |
| 评审 commit (HEAD) | {{reviewed_head_sha}} |
| 基线 commit | {{base_commit_sha}} |
| 最新提交信息 | {{latest_commit_message}} |
| 最新提交作者 | {{latest_commit_author}} |
| 评审时间 | {{review_timestamp}} |
| 评审耗时 | {{review_duration}} |
| 主语言 | {{primary_language}} |
| 主框架 | {{primary_framework}} |
| 报告生成时间 | {{report_generation_timestamp}} |
| 报告编号 | {{report_id}} |

> 评审模式取值：`daily`（增量）/ `weekly`（全量）/ `feature_branch`（需求分支 Diff）。

---

## 二、评审统计概览

### 总体评价

{{overall_assessment}}

| 统计项 | 数量 |
|------|------|
| 提交数 | {{commit_count}} |
| 变更文件数 | {{files_changed}} |
| 高风险文件数 | {{high_risk_files_count}} |
| 发现问题总数 | {{total_issues_found}} |
| Critical 级别 | {{critical_count}} |
| Major 级别 | {{major_count}} |
| Minor 级别 | {{minor_count}} |
| 优秀实践数 | {{positive_count}} |
| 是否存在阻塞问题 | {{has_blocking}} |
| 是否建议引入 Architect 复审 | {{architect_review_required}} |

### 各维度问题分布

| 维度 | Critical | Major | Minor | 备注 |
|------|----------|-------|-------|------|
| 逻辑正确性 | {{logic_critical}} | {{logic_major}} | {{logic_minor}} | {{logic_note}} |
| 代码质量 | — | {{quality_major}} | {{quality_minor}} | {{quality_note}} |
| 工程规范 | — | {{standards_major}} | {{standards_minor}} | {{standards_note}} |
| 性能风险 | — | {{performance_major}} | {{performance_minor}} | {{performance_note}} |
| 架构一致性 | — | {{architecture_major}} | {{architecture_minor}} | {{architecture_note}} |

### 严重等级分布

```
Critical ████████████████ {{critical_count}}  {{critical_percent}}%
Major    ██████████████   {{major_count}}     {{major_percent}}%
Minor    ████████          {{minor_count}}     {{minor_percent}}%
```

---

## 三、问题汇总表（按严重等级分组）

### Critical

| # | 问题编号 | 维度 | 类别 | 影响文件 | 影响行 | 摘要 |
|---|---------|------|------|---------|-------|------|
| {{critical_row_number}} | {{issue_id}} | {{dimension}} | {{category}} | {{affected_file}} | {{affected_line}} | {{issue_summary}} |

### Major

| # | 问题编号 | 维度 | 类别 | 影响文件 | 影响行 | 摘要 |
|---|---------|------|------|---------|-------|------|
| {{major_row_number}} | {{issue_id}} | {{dimension}} | {{category}} | {{affected_file}} | {{affected_line}} | {{issue_summary}} |

### Minor

| # | 问题编号 | 维度 | 类别 | 影响文件 | 影响行 | 摘要 |
|---|---------|------|------|---------|-------|------|
| {{minor_row_number}} | {{issue_id}} | {{dimension}} | {{category}} | {{affected_file}} | {{affected_line}} | {{issue_summary}} |

---

## 四、问题详情

---

### ISSUE-{{issue_id}}：{{issue_title}}

#### 基本信息

| 字段 | 值 |
|------|-----|
| 问题编号 | ISSUE-{{issue_id}} |
| 严重等级 | {{severity_level}} |
| 评审维度 | {{dimension}} |
| 类别 | {{category}} |
| 关联规范 | {{related_standard}} |

#### 影响范围

| 字段 | 值 |
|------|-----|
| 影响文件 | {{affected_file_path}} |
| 影响行号 | {{affected_line_range}} |
| 涉及模块 | {{affected_module}} |
| 涉及函数 / 组件 | {{affected_function_or_component}} |

#### 问题代码

```{{language}}
// {{affected_file_path}}:{{affected_line_range}}
{{code_snippet}}
```

#### 问题描述

{{issue_description}}

#### 影响分析

{{impact_analysis}}

#### 修改建议

{{suggestion_description}}

##### 建议代码示例

```{{language}}
// 建议修改后的代码
{{suggested_code_snippet}}
```

#### 参考链接

- {{reference_link_1}}
- {{reference_link_2}}

---

<!-- 以上 ISSUE 块按实际发现数量重复 -->

---

## 五、优秀实践

| # | 实践描述 | 涉及文件 / 模块 |
|---|---------|----------------|
| {{positive_number}} | {{positive_practice_description}} | {{positive_affected_scope}} |

---

## 六、工程规范符合度

| 规范 | 状态 | 不符合项数 | 备注 |
|------|------|-----------|------|
| {{standard_name}} | {{compliance_status}} | {{nonconformance_count}} | {{standard_note}} |

> 工程规范参考目录：`rules/coding/`，包含命名规范、React 组件规范、枚举定义规范、注释规范等。

---

## 七、改进建议

### 短期改进（本次评审周期内）

{{short_term_suggestions}}

### 中长期改进（多次评审持续推进）

{{long_term_suggestions}}

### 跨仓库共性发现（如适用）

| # | 共性问题描述 | 涉及仓库 |
|---|-------------|---------|
| {{cross_repo_number}} | {{cross_repo_finding}} | {{affected_repositories}} |

---

## 八、评审质量与覆盖

| 评估项 | 结果 |
|--------|------|
| 评审完整性 | {{review_completeness}} |
| 已跳过文件 / 路径 | {{skipped_files}} |
| 已排除规则 | {{excluded_rules}} |
| 评审中遇到的异常 | {{review_warnings_or_errors}} |
| 评审来源（自动化 / 人工） | {{review_source}} |

---

## 九、附录

### A. 排除项说明

| 排除类型 | 排除内容 | 排除原因 |
|---------|---------|---------|
| {{exclusion_type}} | {{exclusion_content}} | {{exclusion_reason}} |

### B. 术语表

| 术语 | 说明 |
|------|------|
| Daily Review | 增量评审，针对前一天提交 |
| Weekly Review | 全量评审，针对当前分支全部代码 |
| Feature Branch Review | 针对需求分支相对主分支的 Diff 评审 |
| Critical | 严重：必须修复，存在阻塞性问题（如逻辑错误、安全风险） |
| Major | 重要：应在合并前修复，存在明显质量或架构问题 |
| Minor | 一般：建议改进，多为可读性或最佳实践偏离 |
| Positive | 优秀实践：值得在团队内推广的做法 |

### C. 报告元数据

| 字段 | 值 |
|------|-----|
| 报告版本 | {{report_version}} |
| 模板版本 | 1.0.0 |
| 生成工具 | {{generation_tool}} |
| 评审人 / Agent | {{reviewer}} |
| 审核人 | {{report_reviewer}} |

---

> **说明**：本报告由 Code Review Agent 自动生成，结合既定工程规范与多维度评审策略产出。Critical 与 Major 级别问题建议进行人工复核确认；评审结论反映的是评审时刻的代码状态，后续代码变更可能影响结论。如发现安全高危问题，将自动升级至 Engineering Team Leader Agent 处理。
