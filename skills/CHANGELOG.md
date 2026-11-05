# Skills Changelog

记录 `skills/` 目录下 Skill 资产的发布、更新与退役历史。

## Unreleased

- 新增 `frontend-requirement-analysis` 设计骨架：建立 Skill 入口、Agent 元信息和三份正式设计文档，定义前端需求重构、需求信息模型及三层追溯与覆盖机制；完整执行流程暂未实现。
- 新增 `technical-content-sanitizer`：统一审查研发资料中的敏感信息，支持仅脱敏、脱敏并重构技术博客、仅审计三种模式；包含风险评估、组合风险、名称映射、技术事实保护、最终复审和标准化报告模板。
- 新增 `git-branch-name-generator`：配置驱动的 Git 分支名称生成技能，支持多套命名规范、自定义规范、Session/Request 配置覆盖、LLM 语义提炼与脚本确定性组装校验。
- 新增 `repository-documentation`：全量分析现有代码仓库，生成系统概览、架构、业务/运行流程、术语表及 Mermaid 图表。
