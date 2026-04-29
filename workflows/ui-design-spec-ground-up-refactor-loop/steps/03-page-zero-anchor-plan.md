# Step 03: Page Zero-Anchor Plan

## Goal

针对当前页面先生成“从零开始”的重构方案，再映射到现有代码，避免受旧 UI 惯性影响。

## Actions

1. 按 `target_pages` 顺序选取 `current_page`。
2. 基于 Step 02 蓝图产出页面级“Ground-Up 方案”：
   - 页面骨架与信息层级
   - 关键组件视觉体系
   - 视觉节奏（留白、密度、分组）
3. 设定本页 `bold_transform_candidates`（至少 3 项）：
   - 布局骨架重排
   - 排版系统替换
   - 组件样式体系重建
   - 状态反馈规则统一
4. 建立实现映射：
   - UI 可改文件范围
   - 功能逻辑保护范围（只读）
   - 每轮优先落地顺序

## Guardrails

- 禁止以“微调现有样式”为主计划。
- 禁止跨页面打包式改造。
- 禁止引入与规范无关的风格决策。

## Exit Criteria

- 当前页 Ground-Up 方案明确
- 已定义可执行的大胆改造候选项
- 实现映射清晰（可改与不可改边界清晰）

## Output Template

```text
[Step03 Completed]
- current_page: ...
- ground_up_plan:
  - layout: ...
  - typography: ...
  - component_system: ...
- bold_transform_candidates:
  - ...
- ui_edit_scope_files:
  - ...
- logic_protection_files:
  - ...
```
