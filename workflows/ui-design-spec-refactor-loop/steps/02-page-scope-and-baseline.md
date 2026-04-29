# Step 02: Page Scope and Baseline

## Goal

按页面建立重构范围与基线，不做全项目一次性改造。

## Actions

1. 按 `target_pages` 顺序选择当前页面 `current_page`。
2. 为当前页面建立“UI 基线”：
   - 关键区域清单（header/sidebar/content/form/table 等）
   - 核心组件清单（按钮、输入、标签、弹层等）
   - 现状样式问题（与规范不一致项）
3. 将不在 `current_page` 范围内的文件标记为“本轮不改”。
4. 输出当前页的“改造计划候选项池”（用于下一步按轮次执行）。

## Guardrails

- 禁止跨页面打包式重构。
- 禁止提前处理下一页面。
- 禁止改业务逻辑或接口相关代码。

## Exit Criteria

- 当前页面范围明确
- 当前页面 UI 基线明确
- 候选改造项池完成

## Output Template

```text
[Step02 Completed]
- current_page: ...
- page_scope_files: ...
- ui_baseline_summary:
  - ...
- candidate_refactors_count: ...
```
