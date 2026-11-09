# 技能索引

> 用于登记所有技能文件，便于检索、分发与依赖维护。

| 技能 ID | 技能名称 | 入口文件 | 状态 | 依赖 | 说明 |
|---|---|---|---|---|---|
| SKILL-001 | Agent Browser | [agent-browser-0.2.0/SKILL.md](./agent-browser-0.2.0/SKILL.md) | active | 无 | 浏览器自动化 CLI 技能，用于页面访问、交互、截图和结构化信息提取 |
| SKILL-002 | Export Bundle | [export-bundle/SKILL.md](./export-bundle/SKILL.md) | active | 无 | 按最小可分发原则打包 rules、skills、workflows |
| SKILL-003 | UI Gap Audit | [ui-gap-audit/SKILL.md](./ui-gap-audit/SKILL.md) | active | SKILL-001 | 对比原型页与本地前端页，输出结构化 UI 差距清单 |
| SKILL-004 | UI Restore Implementation | [ui-restore-implementation/SKILL.md](./ui-restore-implementation/SKILL.md) | active | SKILL-001 | 基于 UI 差距清单实施前端代码修改并复验 |
| SKILL-005 | UI Prototype Restore | [ui-prototype-restore/SKILL.md](./ui-prototype-restore/SKILL.md) | active | SKILL-001、SKILL-003、SKILL-004 | 端到端驱动前端 UI 原型还原流程 |
| SKILL-006 | Repository Documentation | [repository-documentation/SKILL.md](./repository-documentation/SKILL.md) | active | 无 | 全量分析现有代码仓库，生成系统概览、架构、业务/运行流程和术语文档 |
| SKILL-007 | Git Branch Name Generator | [git-branch-name-generator/SKILL.md](./git-branch-name-generator/SKILL.md) | active | 无 | 配置驱动生成 Git 分支名称，内置多套命名规范，支持自定义规范、语义提炼与最终校验，只生成不执行 |
| SKILL-008 | Technical Content Sanitizer | [technical-content-sanitizer/SKILL.md](./technical-content-sanitizer/SKILL.md) | active | 无 | 审查研发资料中的敏感信息，保护技术事实，并生成脱敏文档或公开技术文章 |
| SKILL-009 | 前端需求分析 | [frontend-requirement-analysis/SKILL.md](./frontend-requirement-analysis/SKILL.md) | active | 无 | 分析完整 PRD 及相关资料，重构前端需求，交付分析资料与模块化需求文档，并执行三层来源追溯和覆盖检查 |
| SKILL-010 | Frontend Lite Defect Guard | [frontend-lite-defect-guard/SKILL.md](./frontend-lite-defect-guard/SKILL.md) | active | 无 | 识别并安全修复前端常见小型缺陷，默认先完成检查并报告，再经确认修复 |
