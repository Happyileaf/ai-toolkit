# Workflow: UI Prototype Restore Loop

## Purpose

将“公网原型页面”和“本地前端实现”进行持续对比，循环修复 UI 差距，直到达到可接受还原度。

该文件是 **AI 执行入口文件**。后续调用 AI 时，优先将本文件作为输入。

## Skills Used

按顺序使用以下 skills：

1. `/Users/apple/Desktop/project/ai-toolkit/skills/agent-browser-0.2.0/SKILL.md`
2. `/Users/apple/Desktop/project/ai-toolkit/skills/ui-gap-audit/SKILL.md`
3. `/Users/apple/Desktop/project/ai-toolkit/skills/ui-restore-implementation/SKILL.md`
4. `/Users/apple/Desktop/project/ai-toolkit/skills/ui-prototype-restore/SKILL.md`

## Required Inputs

- `prototype_url`: 原型公网地址（必填）
- `local_project_root`: 本地前端项目根目录（必填）
- `local_url`: 本地服务地址（默认 `http://127.0.0.1:3000`）
- `route_mappings`: 原型路由与本地路由映射数组（默认见下）
- `max_rounds`: 最大迭代轮次（默认 `8`）
- `viewport`: 默认 `1440x900`
- `constraints`: 约束条件（如“不改业务逻辑”）

`route_mappings` 数据结构：

```yaml
route_mappings:
  - id: home
    prototype_route: /
    local_route: /
  - id: pricing
    prototype_route: /pricing-v2
    local_route: /pricing
```

## Execution Flow

详细步骤见：

- `./steps/01-bootstrap.md`
- `./steps/02-audit.md`
- `./steps/03-implement.md`
- `./steps/04-loop-and-stop.md`

严格按上述顺序执行。

## AI Run Contract

每轮都必须输出：

1. 本轮目标差距（gap ids）
2. 修改文件清单
3. 验证结果（resolved/partial/blocked/regression）
4. 下一轮计划

若遇到阻塞，输出阻塞原因和最小可行替代方案，不得直接中止。

## Copy-Paste Input Template

```text
请按 workflow 入口文件执行：
/Users/apple/Desktop/project/ai-toolkit/workflows/ui-prototype-restore-loop/WORKFLOW.md

输入参数：
- prototype_url: https://your-prototype-domain.com
- local_project_root: /absolute/path/to/frontend-project
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
- max_rounds: 8
- viewport: 1440x900
- constraints:
  - 不修改业务逻辑
  - 不做无关重构
```
