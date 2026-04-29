# Step 03: Refactor Loop

## Goal

针对当前页面，按轮次执行 UI 重构。一轮即一次完整“修改-验证”循环。

## Loop Controls

- 循环：`round = 1..max_rounds_per_page`

## Per-Round Procedure

1. 轮次开始前，输出：
   - 当前页面与轮次
   - 本轮将引用的设计规范章节（必须明确章节标题/编号）
2. 从“候选改造项池”中选择本轮改造项并执行 UI 代码调整（仅样式、结构层的 UI 表达、设计 token、组件外观）。
3. 本轮结束后进行规范对比复核：
   - 与本轮声明的规范章节逐条对照
   - 记录符合项/偏差项
4. 判定：
   - 若达到 `acceptance_threshold`，当前页面通过并退出循环
   - 若未达到且未超出 `max_rounds_per_page`，进入下一轮
   - 若达到轮次上限仍未达标，输出未达标项并进入 Step 04

## Allowed Changes

- CSS/SCSS/LESS/样式变量/设计 token
- 组件外观相关属性（className、样式 props）
- 非功能性 DOM 结构微调（仅为满足布局/语义样式挂载）

## Forbidden Changes

- 业务逻辑、状态机、接口调用、数据转换
- 权限、路由守卫、埋点逻辑
- 与当前页面无关的代码调整

## Per-Round Output Template

```text
[Refactor Round]
- page: ...
- round: R / max_rounds_per_page
- spec_sections_used:
  - [章节编号/标题] ...
  - [章节编号/标题] ...
- planned_refactors: ...
- changed_files:
  - ...
- spec_comparison:
  - compliant: ...
  - partial: ...
  - non_compliant: ...
- decision:
  - next_round | page_accepted | page_stopped_at_limit
```
