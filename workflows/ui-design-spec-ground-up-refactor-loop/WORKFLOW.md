# Workflow: UI Design Spec Ground-Up Refactor Loop

## Purpose

在**功能保持不变**的前提下，以设计规范为唯一主驱动，对既有页面进行更大胆、更全面、更彻底的 UI 重构。

该 workflow 的核心是“去锚点（Zero-Anchor）”：
- 不以现有 UI 实现作为设计起点
- 先按规范重建设计蓝图，再映射到现有功能代码
- 用流程机制避免“小修小补式”改动

## Required Inputs

- `design_spec_path`：设计规范文件路径（必填）
- `frontend_project_root`：前端项目根目录（必填）
- `target_pages`：待重构页面列表（必填，按优先级排序）
- `max_rounds_per_page`：每个页面最大重构轮数（默认 `6`，一轮=一次“修改-验证”循环）
- `acceptance_threshold`：可接受范围定义（默认见下）
- `constraints`：约束（默认包含“只改 UI，不改功能”）

默认 `acceptance_threshold`：
- 与设计规范关键视觉规则一致（颜色、间距、字号层级、组件状态）
- 页面无明显视觉冲突
- 功能与交互行为保持原样

## Execution Flow

按顺序执行：

1. `./steps/01-intake-and-functional-lock.md`
2. `./steps/02-spec-deconstruction-and-blueprint.md`
3. `./steps/03-page-zero-anchor-plan.md`
4. `./steps/04-ground-up-refactor-loop.md`
5. `./steps/05-acceptance-and-next-page.md`

## Mandatory Rules

1. 在任何代码改动前，必须完整读取并理解 `design_spec_path`。
2. 必须按 `target_pages` 逐页执行，禁止一次性全项目重构。
3. 每一页开始前，必须先产出“Spec-Only 页面蓝图”（不引用现有样式实现）。
4. 每轮必须声明“本轮引用的规范章节”和“本轮要落地的蓝图条目”。
5. 未通过规范对齐与功能等价验证，不得判定页面完成。
6. 若改动被判定为“补丁式微调”，必须触发下一轮“去锚点重做”而不是结束。
7. 全程仅允许 UI 层改动，不得改业务逻辑、数据流、接口契约。

## Ground-Up Quality Gate

当前页面只有在以下条件同时满足时才可 `accepted`：

1. `spec_coverage` 达到 `acceptance_threshold`（或更高）。
2. `functional_parity` 为 `pass`（关键交互和业务结果不变）。
3. `boldness_gate` 为 `pass`：
   - 至少完成 2 项“宏观视觉重构”（如信息层级、布局骨架、组件外观体系、排版系统中的任意两项）
   - 且不是仅通过零散样式修补达成

## AI Run Contract

每轮必须输出：

1. 当前页面与轮次（如 `Page: /settings, Round: 2/6`）
2. 本轮引用规范章节（标题/编号/路径）
3. 本轮落地蓝图条目
4. 本轮计划改动点
5. 本轮实际改动文件清单
6. 验证结论：
   - `spec_coverage`（符合/部分符合/不符合 + 关键差异）
   - `functional_parity`（pass/fail）
   - `boldness_gate`（pass/fail + 理由）
7. 是否进入下一轮及原因

## Copy-Paste Input Template

```text
请按以下 workflow 执行：
/Users/apple/Desktop/project/ai-toolkit/workflows/ui-design-spec-ground-up-refactor-loop/WORKFLOW.md

输入参数：
- design_spec_path: /absolute/path/to/design-spec.md
- frontend_project_root: /absolute/path/to/frontend-project
- target_pages:
  - /dashboard
  - /settings
  - /profile
- max_rounds_per_page: 6
- acceptance_threshold:
  - 颜色、间距、排版层级符合设计规范
  - 组件状态一致（hover/active/disabled）
  - 不改变任何业务功能
- constraints:
  - 只改 UI，不改功能
  - 不做与页面目标无关的重构
```
