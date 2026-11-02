# 项目类型指南

完成扫描后，使用以下类型调整分析重点。一个 Repository 可能同时包含多种类型。

| 类型 | 主要分析对象 |
|---|---|
| Frontend | Routes、pages、components、state、rendering、Browser API、network contracts、用户交互 |
| Backend | Bootstrap、routes/controllers、middleware、services、domain logic、persistence、queues、integrations |
| Full-stack | Frontend 与 Backend 边界、共享 contracts、authentication、跨层 data flow |
| Library/toolkit | Public exports、capability units、API contracts、dependency graph、支持的 runtime、使用方式 |
| CLI | 可执行入口、参数解析、命令分发、执行 pipeline、输出和 exit codes |
| SDK | Client 配置、public API、transport、serialization、errors、兼容性和 examples |
| Monorepo | Workspace 边界、package 归属、共享 packages、build graph、部署单元 |

对于不熟悉的项目，根据 entry points、manifests、runtime configuration 和代码结构推导合适的类型。如果证据表明项目形态不同，不要强行归类。
