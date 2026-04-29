# Step 05: Ground-Up Refactor Loop

## Goal

在当前页面执行按轮次迭代的“规范驱动重构”，每轮都必须完成“修改-验证-判定”闭环。

## Loop Controls

- 循环：`round = 1..max_rounds_per_page`

## Per-Round Procedure

1. 轮次开始前声明：
   - 当前页面与轮次
   - 本轮引用的规范章节
   - 本轮要落地的蓝图条目
   - 当前页面蓝图模式（`template_driven` 或 `spec_only`）
   - 本轮计划执行的 `bold_transform` 项
2. 执行 UI 重构（仅 UI 层）：
   - 优先改 token/样式体系，再改组件外观，再改页面布局表达
   - 允许非功能性 DOM 结构调整（只为满足布局与视觉语义）
3. 执行验证：
   - `spec_coverage`：逐条对照规范与蓝图
   - `functional_parity`：关键交互与业务结果不变
   - `boldness_gate`：是否达成非补丁式、结构化重构
4. 判定：
   - 若三者均通过，当前页面 `accepted`
   - 若未通过且仍有轮次，进入下一轮
   - 若达到上限，输出残留差距并交由 Step 06 汇总

## Allowed Changes

- CSS/SCSS/LESS/样式变量/设计 token
- 组件外观相关属性（className、样式 props、主题配置）
- 非功能性 DOM 结构重排（不影响业务逻辑）

## Forbidden Changes

- 业务逻辑、状态机、接口调用、数据转换
- 权限、路由守卫、埋点逻辑
- 当前页面范围外的无关改动
- 对于 `template_driven` 页面，禁止绕过已选模板进行无依据视觉重定义

## Per-Round Output Template

```text
[Ground-Up Refactor Round]
- page: ...
- round: R / max_rounds_per_page
- spec_sections_used:
  - [章节编号/标题] ...
- blueprint_items_applied:
  - ...
- blueprint_mode: template_driven | spec_only
- template_reference: ... (if template_driven)
- bold_transforms_executed:
  - ...
- changed_files:
  - ...
- validation:
  - spec_coverage: pass | partial | fail
  - functional_parity: pass | fail
  - boldness_gate: pass | fail
- decision:
  - next_round | page_accepted | page_stopped_at_limit
```
