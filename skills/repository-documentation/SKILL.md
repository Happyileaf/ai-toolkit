---
name: repository-documentation
description: 分析现有软件 Repository，并生成结构化、基于证据的技术文档，涵盖系统概览、架构、业务或运行流程以及术语表。适用于用户希望理解、梳理、记录或解释现有代码库的场景。不适用于功能开发、代码重构或业务代码修改。
---

# Repository Documentation

分析 Repository 当前的实际实现，并生成一套连贯的技术文档。以源代码作为主要证据。不要修改应用代码、重构系统或重新设计架构。

## 工作原则

- 每次执行都必须完整分析当前 Repository。不能假设已有报告或 Git diff 可以替代对当前 Repository 的检查。
- 以实际实现为依据。配置、测试、README、注释和 package metadata 可作为辅助证据。
- 不得虚构行为、依赖、数据模型或执行路径。无法确认的结论应标记为未知，或明确标注为假设。
- 重要结论应附带源文件路径；条件允许时，同时提供 symbol 名称和行号范围。
- 明确区分已观察到的事实、分析推断和建议。不要擅自将文档任务扩展为架构评审。
- 生成文档前，先建立统一的分析模型，确保不同文档中的名称、边界和结论一致。
- 根据识别出的项目类型调整分析重点，同时保留通用工作流程。
- 生成的文档统一放在 `docs/analysis/` 下。不要覆盖无关文件。

## 交付文档

生成以下文档：

1. `docs/analysis/system-overview.md`：独立、完整地说明系统的目标、范围、主要能力、用户或调用方、运行环境、核心概念，以及各部分如何协作。帮助新读者在不通读所有源文件的情况下理解系统，同时提供实现位置索引。
2. `docs/analysis/architecture.md`：说明系统分层、模块、职责、依赖关系、入口、数据存储、外部服务和重要架构边界。
3. `docs/analysis/business-flow.md`：说明重要用户或业务场景的执行顺序、分支、数据变化和错误处理。若项目不存在业务流程，则记录运行时或运维流程。
4. `docs/analysis/glossary.md`：整理领域术语、架构概念、技术关键词、缩写和项目专有名称。

同时生成 `docs/analysis/README.md` 作为文档索引。如果图示能实质性帮助理解系统，则在 `docs/analysis/diagrams/` 中生成 Mermaid 源文件。`.mmd` 文件是可编辑图示的权威源文件。

## 工作流程

严格按照顺序执行以下六个阶段。详细要求见 `workflows/` 中对应文件。

1. **Repository Preparation**：确认 Repository 根目录，检查当前 branch 和 working tree 状态，并了解 remote 同步情况。未经许可，不要切换 branch、pull、reset、stash 或覆盖用户更改。
2. **Repository Scanning**：梳理目录结构，识别项目类型、语言、framework、package manifest、入口、配置、scripts、tests 和部署/运行文件。除非与分析相关，否则排除生成文件和 vendored 内容。
3. **System Analysis**：追踪模块职责、imports 和依赖、公开接口、执行路径、数据结构、持久化、外部集成和错误处理。
4. **Knowledge Organization**：将发现整合为统一的系统边界、模块、概念、接口和流程模型。统一命名，并记录证据与不确定性。
5. **Documentation Generation**：基于整合后的模型生成四份核心文档、索引和必要的图示。
6. **Consistency Validation**：检查事实依据、跨文档术语、源文件路径、内部链接和 Mermaid 语法。发现不一致时先修正，再报告完成。

## 按项目类型调整分析重点

先识别 Repository 的实际形态，再确定分析重点。使用通用工作流程，并按需调整关注点：

- **Frontend**：routes、pages、components、state management、Browser API、network interface 和用户交互。
- **Backend**：应用 bootstrap、API endpoints、middleware、services、domain logic、persistence、queues 和 integrations。
- **Full-stack**：Frontend 与 Backend 结构，以及双方的 contracts 和通信方式。
- **Library/toolkit**：public exports、capability units、API、dependency graph、支持的运行环境和使用方式。
- **CLI**：可执行入口、命令解析、options、执行 pipeline、输出和退出行为。
- **SDK**：public API、client 初始化、contracts、transport、errors 和 examples。
- **其他或混合项目**：根据 Repository 证据识别运行环境和组件边界，不要强行套用不合适的分类。

## 图示规范

优先绘制能够解释关系或执行过程的图示：

- 系统级架构及主要外部边界。
- 必要时展示模块级依赖或组合关系。
- 重要场景的业务/运行时 sequence 和 data flow。
- 只有在能实质性解释复杂逻辑时，才绘制 code-level diagram。

使用 Mermaid，源文件保存为 `.mmd`。保持图示易读，准确标注关系，并确保图示与文档描述一致。不要为了增加文档数量而制作没有解释价值的图示。

## 范围边界

本 Skill 只记录现有实现，不负责开发功能、修改业务逻辑、重构代码、引入依赖或设计替代架构。如果用户另行要求修改代码，应将其视为独立任务，并取得必要授权。

## 完成报告

完成后，汇总 Repository 和项目类型，列出生成的文件，指出检查过的关键源代码区域，并说明尚未解决的问题或分析限制。不得声称执行过实际未执行的检查或验证。
