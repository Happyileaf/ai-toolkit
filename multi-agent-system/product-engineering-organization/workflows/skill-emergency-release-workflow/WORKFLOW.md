---
name: skill-emergency-release-workflow
description: 安全问题与重大 Bug 的快速修复通道，确保紧急问题在最短时间内修复并发布。
version: 1.0.0
entry: WORKFLOW.md
status: active
type: workflow
category: skill-management
tags:
  - skill
  - emergency
  - security
  - hotfix
dependencies:
  - ../../agents/skills-team/skills-evolution-agent.md
  - ../../agents/skills-team/skills-review-agent.md
  - ../../agents/skills-team/skills-generation-agent.md
  - ../../agents/skills-team/skills-librarian-agent.md
steps:
  - steps/01-emergency-assessment.md
  - steps/02-quick-audit.md
  - steps/03-quick-fix.md
  - steps/04-quick-review.md
  - steps/05-immediate-release.md
inputs:
  - issue_report
  - severity_data
outputs:
  - emergency_assessment
  - fix_result
  - quality_report
  - release_record
  - announcement
requires_agents:
  - Evolution Agent
  - Review Agent
  - Generation Agent
  - Librarian Agent
---

# Workflow: Skill Emergency Release

## Purpose

安全问题与重大 Bug 的快速修复通道，确保紧急问题在最短时间内修复并发布。

## Agents Involved

| 步骤 | 负责 Agent | 主要产出 |
|------|-----------|----------|
| Emergency Assessment | Evolution Agent | 紧急评估结果 |
| Quick Audit | Review Agent | 快速审计结果 |
| Quick Fix | Generation Agent | 修复方案 |
| Quick Review | Review Agent | 质量报告 |
| Immediate Release | Librarian Agent | 发布记录 |

## Emergency Definition

| 类型 | 条件 | 时间要求 |
|------|------|----------|
| **安全问题** | 存在安全漏洞或风险 | 24 小时内 |
| **重大 Bug** | 影响 > 50% 用户 | 48 小时内 |
| **严重故障** | Skill 完全无法使用 | 48 小时内 |

## Required Inputs

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|----------|
| `issue_report` | object | 是 | 问题报告 |
| `severity_data` | object | 是 | 严重性数据 |

## Execution Flow

详细步骤见：

- `./steps/01-emergency-assessment.md` - 紧急判定
- `./steps/02-quick-audit.md` - 快速审计
- `./steps/03-quick-fix.md` - 快速修复
- `./steps/04-quick-review.md` - 快速审核
- `./steps/05-immediate-release.md` - 立即发布

## Normal vs Emergency

| 正常流程 | 紧急流程 | 变化 |
|----------|----------|------|
| Discovery → Design → Generation | 直接 Generation | 跳过前两步 |
| Review 完整审计 | Review 快速审计 | 仅检查阻塞项 |
| 发布窗口（周二/四） | 立即发布 | 跳过窗口限制 |
| 公告周期（2 周） | 同步公告 | 立即公告 |
| 评分 >= 80 | 评分 >= 70 | 阈值降低 |

## State Model

```
emergency_assessment → quick_audit → quick_fix → quick_review → immediate_release
                                        │              │
                                        └──────────────┘
                                    (未通过则返回 quick_fix)
```

## Post-Release Audit

紧急发布后 7 天内完成完整审计：

1. 补充完整文档
2. 补充完整示例
3. 完整质量评分
4. 必要时进行 minor/major 版本更新

## Copy-Paste Input Template

```text
请按 workflow 入口文件执行：
./workflows/skill-emergency-release-workflow/WORKFLOW.md

输入参数：
- issue_report:
    type: security
    description: "安全漏洞导致数据泄露"
    affected_users: "100%"
- severity_data:
    severity: critical
    time_requirement: "24 hours"
```

## Output Contract

最终输出必须包含：

1. `emergency_assessment`: 紧急评估结果
2. `fix_result`: 修复方案与结果
3. `quality_report`: 质量报告
4. `release_record`: 发布记录
5. `announcement`: 公告信息

## Emergency Release Permissions

| 角色 | 权限 |
|------|------|
| Evolution Agent | 触发紧急判定 |
| Librarian Agent | 批准紧急发布 |
| Review Agent | 执行快速审核 |
| Generation Agent | 执行快速修复 |
