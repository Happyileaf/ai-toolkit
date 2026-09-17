# AGENTS

> 本文件是 Agent 在本仓库执行任务的顶层入口。遵循渐进式披露原则：先读本文件确定路由，再按需打开子文件。

## 1. 角色与契约

Agent 在本仓库内承担**全栈应用开发**任务，覆盖前端、后端、数据库、测试、发布全链路。任何代码改动必须可追溯到需求范围或修复项，禁止顺手重构、相邻格式化、隐式扩范围。

详细行为门禁与范围控制见 [`agent-execution-contract.md`](./agent-execution-contract.md)。

## 2. 快速路由（Level 0）

按当前任务类型只选一个入口，不要全量阅读：

| 任务类型 | 入口文件 | 何时打开 |
|---|---|---|
| 项目布局与模块边界 | [`project-layout.md`](./project-layout.md) | 新建项目、调整目录、确认单仓/多仓形态时 |
| Agent 行为门禁与范围控制 | [`agent-execution-contract.md`](./agent-execution-contract.md) | 任何非平凡改动前 |
| AI 协作归属 | [`ai-attribution.md`](./ai-attribution.md) | commit 包含 AI 生成或协助内容时 |

### 2.1 通用规范（遵循行业标准，不另立文档）

以下领域已有成熟行业方案，不在本目录重复成文，以行业标准与项目配置文件为准：

| 领域 | 标准 / 工具 |
|---|---|
| 代码风格 | ESLint + Prettier + 语言官方风格指南，以项目配置文件为准 |
| Git 工作流 | Conventional Commits + GitHub Flow |
| 前端 | React 官方最佳实践 |
| 后端 | 框架官方分层（NestJS / Fastify / FastAPI） |
| 数据库 | 迁移工具（Prisma）惯例 |
| 测试 | 测试金字塔 + Vitest / Playwright 官方实践 |
| 安全 | OWASP Top 10 |
| 性能 | Google Web Vitals |

## 3. 使用方式（渐进式披露）

1. **Level 0**：从上表只选一个入口文件。
2. **Level 1**：若入口文件指向其他子文件，再打开被指向的子文件。
3. **Level 2**：若子文件仍引用更深层的 schema 或示例，再继续下钻。
4. 每次只打开最少文件，避免全量扫描。
5. 若不同文件存在冲突，以更具体的文件为准；若仍冲突，以 [`agent-execution-contract.md`](./agent-execution-contract.md) 的行为门禁为最终裁决。

## 4. 执行循环

任何非平凡改动遵循以下顺序，**不得跳步**：

1. **理解**：读取需求/spec/相关代码，显式列出假设、歧义、范围外事项。
2. **设计**：必要时编写 spec，明确组件边界、验收标准、边界场景。
3. **实现**：按 spec 范围内最小实现，先满足验收标准。
4. **自检**：lint / typecheck / unit / build / e2e（按 contract 要求）+ 验收标准逐条核对。
5. **提交**：按 [`git-workflow.md`](./git-workflow.md) 的 commit 规范提交，附必要上下文。

详细契约见 [`agent-execution-contract.md`](./agent-execution-contract.md)。

## 5. 技术栈约定

本仓库默认按以下技术栈生成文档；若项目实际栈不同，以项目根目录的配置文件（`package.json`、`tsconfig.json`、`pyproject.toml` 等）为准。

- **前端**：React + TypeScript + Vite（或 Next.js）
- **后端**：Node.js（NestJS / Fastify / Express）或 Python（FastAPI）
- **数据库**：PostgreSQL（主）+ Redis（缓存）
- **测试**：Vitest / Jest + Playwright
- **基础设施**：Docker + CI（GitHub Actions）

## 6. 目录索引

完整文件清单与说明见 [`README.md`](./README.md)。
