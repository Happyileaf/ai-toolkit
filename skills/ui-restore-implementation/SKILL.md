---
name: ui-restore-implementation
description: 基于 UI 差距清单实施前端代码修改，并通过 agent-browser 复验迭代，持续提升页面对原型的还原度。
---

# UI Restore Implementation

本 skill 专注“改代码并验证”，输入应来自 `ui-gap-audit` 的结构化差距清单。

## Must Use Tooling

必须先读取：

- `/Users/apple/Desktop/project/ai-toolkit/skills/agent-browser-0.2.0/SKILL.md`

验证环节必须使用 `agent-browser` 对比原型页和本地页。

## Inputs

- `gap_list`: 按优先级排序的差距项
- `prototype_page_url`
- `local_page_url`
- `codebase_root`

## Copy-Paste Implementation Prompt

```text
请使用 ui-restore-implementation 执行一轮 UI 还原：
- prototype_page_url: {PROTOTYPE_PAGE_URL}
- local_page_url: {LOCAL_PAGE_URL}
- codebase_root: {PROJECT_ROOT}
- gap_list:
  - GAP-001 (P0): Hero 区域布局错位
  - GAP-002 (P1): 主按钮视觉不一致

要求：
1) 先做 1-3 个高优先级项，控制改动范围。
2) 改完必须用 agent-browser 对比复验。
3) 输出 resolved/partial/blocked/regression 结果。
```

## Implementation Strategy

1. 按优先级切片
- 每轮只处理少量高价值项（通常 1-3 个 P0/P1）。
- 避免跨太多模块的大爆改。

2. 根因优先
- 先修公共 token / 基础样式变量 / 组件基类，再修页面局部。
- 若多个差距同源（如 spacing token 偏差），合并一次修复。

3. 变更最小化
- 不做与还原无关的重构。
- 不顺手改业务逻辑，除非影响 UI 正确性。

## Verification Loop

每轮修改后执行：

1. 打开原型页与本地页并统一 viewport。
2. 使用 snapshot/screenshot 验证本轮目标差距。
3. 标记状态：
- `resolved`: 已修复
- `partial`: 部分改善
- `blocked`: 暂无法修复（需额外信息/资源）
- `regression`: 引入新问题

4. 根据结果决定下一轮。

## Regression Guardrails

- 若改动影响多个页面，至少抽查 1 个相邻页面。
- 若样式来自设计系统组件，确认不会破坏其他使用方。
- 若出现回归，优先回退该点并改用更小影响面的方案。

## Round Output Contract

每轮固定输出：

```text
Round N
Changed files:
- path/to/fileA
- path/to/fileB

Resolved:
- GAP-001

Partial:
- GAP-004 (button shadow closer but still darker)

Regression:
- GAP-009 (mobile navbar height changed unexpectedly)

Next:
- 修复 GAP-002 / GAP-003
```

## Batch Planning Template

执行前先给出本轮计划，格式如下：

```text
Batch Plan
- Scope: GAP-001, GAP-002
- Suspected files:
  - src/pages/Home.tsx
  - src/components/Button.tsx
  - src/styles/tokens.css
- Risk:
  - 可能影响其他页面按钮样式
- Guardrail:
  - 抽查 /pricing 按钮样式是否回归
```

## Completion Criteria

当满足以下任一条件可结束：

- 所有 P0/P1 差距关闭。
- 用户接受当前还原度并停止。
- 剩余项均为低优先级微调。
