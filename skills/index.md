# 技能索引

> 用于登记所有技能文件，便于检索、分发与依赖维护。

| 技能ID | 技能名称 | 入口文件 | 状态 | 依赖 | 说明 |
|---|---|---|---|---|---|
| SKILL-001 | Agent Browser | [`agent-browser-0.2.0/SKILL.md`](./agent-browser-0.2.0/SKILL.md) | active | 无 | 浏览器自动化 CLI 技能，用于页面访问、交互、截图和结构化信息提取 |
| SKILL-002 | Export Bundle | [`export-bundle/SKILL.md`](./export-bundle/SKILL.md) | active | 无 | 按最小可分发原则打包 rules、skills、workflows |
| SKILL-003 | UI Gap Audit | [`ui-gap-audit/SKILL.md`](./ui-gap-audit/SKILL.md) | active | SKILL-001 | 对比原型页与本地前端页，输出结构化 UI 差距清单 |
| SKILL-004 | UI Restore Implementation | [`ui-restore-implementation/SKILL.md`](./ui-restore-implementation/SKILL.md) | active | SKILL-001 | 基于 UI 差距清单实施前端代码修改并复验 |
| SKILL-005 | UI Prototype Restore | [`ui-prototype-restore/SKILL.md`](./ui-prototype-restore/SKILL.md) | active | SKILL-001、SKILL-003、SKILL-004 | 端到端驱动前端 UI 原型还原流程 |
| SKILL-006 | Repository Documentation | [`repository-documentation/SKILL.md`](./repository-documentation/SKILL.md) | active | 无 | 全量分析现有代码仓库，生成系统概览、架构、业务/运行流程和术语文档 |
| SKILL-007 | Git Branch Name Generator | [`git-branch-name-generator/SKILL.md`](./git-branch-name-generator/SKILL.md) | active | 无 | 配置驱动生成 Git 分支名称，内置多套命名规范，支持自定义规范、语义提炼与最终校验，只生成不执行 |
