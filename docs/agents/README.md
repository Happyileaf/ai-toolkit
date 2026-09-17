# docs/agents

本目录存放面向全栈应用的 Agent 指南与子规则文档。入口为 [`AGENTS.md`](./AGENTS.md)，其余文件按关注点拆分，遵循渐进式披露原则。

## 文件清单

| 文件 | 关注点 | 何时阅读 |
|---|---|---|
| [`AGENTS.md`](./AGENTS.md) | Agent 顶层入口与路由 | 任何任务开始前 |
| [`agent-execution-contract.md`](./agent-execution-contract.md) | 行为门禁、范围控制、执行循环 | 任何非平凡改动前 |
| [`project-layout.md`](./project-layout.md) | 目录结构、模块边界、单仓/多仓 | 新建项目或调整目录时 |
| [`ai-attribution.md`](./ai-attribution.md) | AI 协作 commit trailer 归属 | commit 含 AI 生成或协助内容时 |

> 代码风格、Git 工作流、前端/后端/数据库/测试/安全/性能等通用规范遵循行业标准，详见 [`AGENTS.md`](./AGENTS.md) 的"通用规范"一节。

## 阅读顺序

1. 永远从 [`AGENTS.md`](./AGENTS.md) 开始。
2. 按任务类型只打开一个入口子文件。
3. 仅在缺信息时下钻到下一层。
4. 如遇冲突，以更具体的文件为准；仍冲突以 `agent-execution-contract.md` 为最终裁决。

## 维护规则

- 新增子文件必须在 `AGENTS.md` 的路由表与本清单中登记。
- 每个子文件必须可独立阅读，不依赖其他子文件的前置上下文。
- 跨文件引用使用相对链接，避免硬编码绝对路径。
- 文档变更需按 `git-workflow.md` 的 commit 规范提交，类型用 `docs(agents)`。
