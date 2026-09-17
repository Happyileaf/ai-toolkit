# AI 协作贡献归属

> 本文件定义 AI Agent 参与代码或项目文件生成、修改、实质性协助时的 commit 归属规则。是 Conventional Commits commit trailer 规则的延伸。

## 1. 适用范围

- **适用**：commit 中包含由 AI Agent 直接生成、修改或实质性协助产生的代码或项目文件。
- **不适用**：AI 工具仅用于与本次 commit 内容无关的辅助（如无关问答、查询资料），不添加归属。

## 2. 归属原则

- 人类贡献者始终是 commit 的 author。
- AI Agent 作为 co-author 被记入 commit trailer。
- 仅对实际参与了 commit 内容的 AI Agent 添加归属，不多加。
- 同一 commit 有多个 AI Agent 贡献时，每个 Agent 一条 `Co-authored-by` trailer。

## 3. Trailer 格式

```
Co-authored-by: <agent-name> <email>
```

- 必须位于 commit message 的 footer 区块（与 body 之间空一行）。
- `agent-name` 与 `email` 必须与下方常用 Agent 表一致；表外的 Agent 用其官方署名与联系邮箱。

## 4. 常用 AI Agent 归属表

| Agent | Attribution |
| --- | --- |
| ChatGPT | `Co-authored-by: ChatGPT <chatgpt-codex-connector[bot]@users.noreply.github.com>` |
| Codex | `Co-authored-by: Codex <codex@openai.com>` |
| Claude | `Co-authored-by: Claude <noreply@anthropic.com>` |
| Gemini | `Co-authored-by: Gemini <gemini-cli@users.noreply.github.com>` |
| Copilot | `Co-authored-by: Copilot <copilot-connector[bot]@users.noreply.github.com>` |
| Cursor | `Co-authored-by: Cursor <cursoragent@cursor.com>` |
| Warp | `Co-authored-by: Warp <agent@warp.dev>` |

## 5. 示例

单 Agent 贡献：

```text
feat: add bookmark search

Add keyword search and filtering to the bookmark list.

Co-authored-by: Codex <codex@openai.com>
```

多 Agent 贡献：

```text
feat: add bookmark search

Add keyword search and filtering to the bookmark list.

Co-authored-by: Codex <codex@openai.com>
Co-authored-by: Claude <noreply@anthropic.com>
```

## 6. 禁止

- 把 AI Agent 写成 author（必须由人类担任 author）。
- 为未实际参与本次 commit 内容的 AI 工具添加归属。
- 篡改 Agent 的署名或邮箱（须与官方一致）。
- 把 trailer 写在 body 区块（必须在 footer 区块）。
