# Workflow: UI Design Spec Refactor Loop

## Purpose

在**不影响功能**的前提下，基于指定设计规范文件，对现有前端项目进行按页面、可循环、可收敛的 UI 重构。

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

1. `./steps/01-intake-and-spec-read.md`
2. `./steps/02-page-scope-and-baseline.md`
3. `./steps/03-refactor-loop.md`
4. `./steps/04-acceptance-and-next-page.md`

## Mandatory Rules

1. 必须先读取并理解 `design_spec_path`，再开始任何代码修改。
2. 严禁一次性重构整个项目；必须按 `target_pages` 逐页处理。
3. 每轮执行前，必须输出“本次重构使用的设计规范章节”。
4. 每轮必须完成一次完整“修改-验证”循环。
5. 每轮后必须对照规范复核，未达标则进入下一轮，直到达到阈值或达到轮次上限。
6. 全程只允许 UI 层改动，不允许改业务逻辑、数据流、接口契约。

## AI Run Contract

每轮必须输出：

1. 当前页面与轮次（如 `Page: /settings, Round: 2/6`）
2. 本轮引用的设计规范章节（标题/编号/路径）
3. 本轮计划改动点
4. 本轮实际改动文件清单
5. 与设计规范的对比结论（符合/部分符合/不符合）
6. 是否进入下一轮及原因

## Copy-Paste Input Template

```text
请按以下 workflow 执行：
/Users/apple/Desktop/project/ai-toolkit/workflows/ui-design-spec-refactor-loop/WORKFLOW.md

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
