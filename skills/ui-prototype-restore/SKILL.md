---
name: ui-prototype-restore
description: 当需要将本地前端页面对齐到公网原型时使用；通过 agent-browser 对比“本地实现 vs 原型站点”，产出差距清单，并循环修改代码直到视觉和交互还原度显著提升。
---

# UI Prototype Restore

本 skill 用于端到端驱动“前端 UI 还原”流程，适合以下场景：

- 用户提供了可访问的原型公网地址。
- 本地有可运行的前端项目，需要启动后进行页面对比。
- 目标是持续迭代代码，而不是一次性给建议。

## Required Companion Skills

执行前，按顺序读取并使用以下 skills：

1. `/Users/apple/Desktop/project/ai-toolkit/skills/agent-browser-0.2.0/SKILL.md`
2. `/Users/apple/Desktop/project/ai-toolkit/skills/ui-gap-audit/SKILL.md`
3. `/Users/apple/Desktop/project/ai-toolkit/skills/ui-restore-implementation/SKILL.md`

如果任一 skill 缺失，先提示缺失项，再用当前可用能力继续。

## Inputs

最少需要这些输入：

- `prototype_url`: 原型公网地址（必须可访问）。
- `local_url`: 本地页面地址（例如 `http://127.0.0.1:3000`）。
- `route_mappings`: 原型路由与本地路由映射列表（至少 1 个）。

如果用户没有给全，默认假设：

- `local_url = http://127.0.0.1:3000`
- `route_mappings = [{ id: "home", prototype_route: "/", local_route: "/" }]`

## Copy-Paste Kickoff Template

在实际任务开始时，可直接使用以下输入模板：

```text
请使用 ui-prototype-restore 执行 UI 还原任务：
- prototype_url: https://your-prototype-domain.com
- local_url: http://127.0.0.1:3000
- route_mappings:
  - id: home
    prototype_route: /
    local_route: /
  - id: pricing
    prototype_route: /pricing-v2
    local_route: /pricing
  - id: dashboard
    prototype_route: /workspace
    local_route: /dashboard
- restore_goal: 优先修复布局和核心视觉，随后修复交互状态
- constraints:
  - 不修改业务逻辑
  - 不重构无关代码
```

如用户未给全参数，按默认值执行并在输出中声明假设。

## End-to-End Workflow

1. 启动本地前端项目
2. 对每个 `route_mapping` 分别对比原型页与本地页
3. 输出结构化差距清单（布局、尺寸、间距、字体、颜色、状态、交互）
4. 修改代码并验证
5. 循环直到达到停止条件

## Step 1: Start Local Frontend

先在项目根目录探测可用启动命令，优先顺序：

1. `npm run dev`
2. `pnpm dev`
3. `yarn dev`
4. `npm start`

启动后确认：

- 本地服务可访问（`local_url` 返回页面）。
- 如果端口被占用，自动切换端口并同步更新 `local_url`。

## Step 2: Pairwise Compare Per Route

对每个映射项 `m`：

- 原型页：`prototype_url + m.prototype_route`
- 本地页：`local_url + m.local_route`
- 路由标识：`m.id`

调用 `ui-gap-audit` 子 skill，生成该路由的差距清单与优先级。

## Step 3: Implement Highest-Impact Fixes

调用 `ui-restore-implementation` 子 skill，按优先级修复：

- P0: 结构与布局错误（错位、层级、溢出、响应式断裂）
- P1: 关键视觉差异（字号、字重、色值、间距、圆角、阴影）
- P2: 状态与动效（hover/active/disabled、过渡时长/曲线）

每轮只做“可验证的小批量改动”，避免一次改太多导致回归难定位。

## Step 4: Re-verify

每轮改动后：

- 重新打开两端页面并 snapshot/screenshot。
- 对比差距是否缩小。
- 记录“已解决 / 未解决 / 新引入”。

## Iteration Stop Conditions

满足任一条件即可停止：

- 高优先级差距（P0/P1）已清零。
- 连续 2 轮无明显提升。
- 用户要求停止并输出当前最佳结果。

## Output Contract

每一轮都输出：

- 修改了哪些文件与关键变更点
- 修复了哪些差距（按 P0/P1/P2）
- 仍存在的差距和下一轮计划

最终输出：

- 还原结果摘要
- 剩余差距（如有）
- 建议的后续优化项

## Round Summary Template

```text
Round {N}
RouteMapping: {route_mapping_id}
PrototypeRoute: {prototype_route}
LocalRoute: {local_route}

Changed files:
- {file_path_1}
- {file_path_2}

Resolved:
- {gap_id}

Partial:
- {gap_id}: {note}

Blocked:
- {gap_id}: {reason}

Regression:
- {gap_id}: {note}

Next round focus:
- {next_gap_id_1}
- {next_gap_id_2}
```
