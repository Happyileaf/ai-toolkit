# Step 03: Spec Deconstruction and Blueprint

## Goal

基于 Step 02 的规范理解结果，构建“可执行蓝图”，让后续实现由规范直接驱动，而非由现有 UI 驱动。

## Actions

1. 消费 Step 02 输出的可执行规则清单（尤其 `P0/P1`）与 `per_page_template_decision`。
2. 若页面 `decision = use_template`，构建“Template-Driven 蓝图”：
   - 以选中的规范模板作为页面结构与视觉主框架
   - 明确模板中需按业务语义适配的区域
3. 若页面 `decision = no_matching_template`，构建“Spec-Only 设计蓝图”（不引用当前实现）：
   - 设计 token（颜色、字号、间距、圆角、阴影）
   - 信息层级与布局骨架
   - 组件外观规则与状态机（hover/active/focus/disabled）
   - 页面级视觉一致性规则
4. 输出“去锚点声明”：
   - 不以当前 className/CSS 结构作为方案起点
   - 现有实现仅用于功能映射，不用于视觉决策

## Guardrails

- 禁止先看现有样式再反推规范。
- 禁止把“当前实现可改动难度”当作视觉决策依据。
- 若规范与现有实现冲突，默认以规范为准（功能边界除外）。

## Exit Criteria

- 每个 `target_page` 都有页面蓝图草案（`template_driven` 或 `spec_only`）
- 去锚点声明已确认

## Output Template

```text
[Step03 Completed]
- per_page_spec_blueprint:
  - page: ...
    blueprint_mode: template_driven | spec_only
    template_used: ... (if template_driven)
    blueprint_items:
      - ...
- zero_anchor_statement: confirmed
```
