# 系统分析

追踪系统的真实工作方式。

1. 识别启动路径、public entry points 和 runtime lifecycle。
2. 根据职责和实际依赖边界，将源文件归纳为不同模块。
3. 追踪重要的 imports、calls、events、messages 和 API boundaries。
4. 识别数据结构、schemas、persistence mechanisms、caches 和 state ownership。
5. 检查外部服务、network calls、filesystem access、browser/platform APIs 和 third-party integrations。
6. 追踪典型的成功、校验失败、异常、重试和清理路径。
7. 使用 tests 辅助验证行为，但不能用 tests 替代实现分析。
8. 为每项重要结论记录证据，包括文件路径和 symbol；条件允许时补充行号范围。

不要仅根据文件名或注释推断 runtime behavior。如果静态检查无法确认某项行为，应将其标记为未知或假设。
