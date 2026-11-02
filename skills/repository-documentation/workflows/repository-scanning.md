# Repository 扫描

在解释实现之前，先建立 Repository 地图。

检查以下内容：

- 顶层目录及有代表性的子目录文件。
- 语言和 framework 标识。
- Package manifests、lockfiles、workspace 配置和依赖声明。
- 应用或 library 的入口及导出接口。
- Build、test、lint、formatting 和 development scripts。
- 环境配置和应用配置。
- Tests、fixtures、examples、migrations、schemas 和生成代码。
- 相关的部署、container、CI 和 runtime 配置。

将文件归类为 source、configuration、tests、documentation、generated output、vendored dependencies 或 assets。除非大型生成目录或 vendor 目录与行为分析相关，否则不必常规检查。

根据证据识别项目类型，不要根据 Repository 名称猜测。对于 monorepo，梳理每个可独立部署或具有独立意义的 package，并解释它们之间的关系。
