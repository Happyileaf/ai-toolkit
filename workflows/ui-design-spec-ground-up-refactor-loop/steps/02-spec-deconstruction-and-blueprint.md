# Step 02: Spec Deconstruction and Blueprint

## Goal

深度理解设计规范并构建“可执行蓝图”，让后续实现由规范直接驱动，而非由现有 UI 驱动。

## Actions

1. 完整阅读 `design_spec_path`，建立“规范章节索引”。
2. 提取可执行规则并按优先级分类：
   - `P0`：必须满足（品牌色、排版层级、关键组件状态、关键布局规则）
   - `P1`：强烈建议满足（间距体系、次级组件、动效节奏）
   - `P2`：可在轮次受限时延后（装饰性细节）
3. 构建“Spec-Only 设计蓝图”（不引用当前实现）：
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

- 规范章节索引完成
- 可执行规则不少于 12 条，且每条有来源定位
- 每个 `target_page` 都有 Spec-Only 蓝图草案
- 去锚点声明已确认

## Output Template

```text
[Step02 Completed]
- spec_sections_indexed: N
- executable_rules:
  - id: R1
    priority: P0
    source: ...
    rule: ...
- per_page_spec_blueprint:
  - page: ...
    blueprint_items:
      - ...
- zero_anchor_statement: confirmed
```
