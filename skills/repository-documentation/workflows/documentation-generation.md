# 文档生成

根据整合后的分析模型生成文档，不要直接将零散的文件阅读笔记拼接成文档。

生成以下文件：

- `docs/analysis/README.md`
- `docs/analysis/system-overview.md`
- `docs/analysis/architecture.md`
- `docs/analysis/business-flow.md`
- `docs/analysis/glossary.md`

当图示具有解释价值时，创建 `docs/analysis/diagrams/` 并保存 Mermaid `.mmd` 源文件。

编写要求：

- 解释真实实现，而不是理想化架构。
- 先介绍概念，再使用这些概念进行说明。
- 明确描述组件关系和执行顺序。
- 重要结论应链接到 Repository 路径和 symbol。
- 所有文档中的术语保持一致。
- 对不适用的章节简要说明，不要编造内容。
- 明确标记未知信息和假设。
- 避免在多个文档中重复整段内容；使用链接和简洁的交叉引用。
- 不要用简短 README 代替详细的系统概览。

将 `templates/` 中的模板作为结构参考。根据项目实际情况调整章节，不要机械地填充无关标题。
