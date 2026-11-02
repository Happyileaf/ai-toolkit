# Repository 准备

1. 确认 Repository 根目录和当前工作区。
2. 检查当前 branch、working tree 状态及相关 remotes。
3. 如果能够获取相关信息，确认当前 branch 与 upstream 的同步情况。
4. 检查 `docs/analysis/` 下已有文档，以及可能受到影响的用户文件。
5. 未经明确许可，不要切换 branch、pull、reset、stash、clean 或覆盖任何更改。
6. 如果 working tree 存在未提交更改，应予以保留，避免触碰无关文件。
7. 在开始扫描前记录 Repository 状态和相关约束。

如果无法检查 Repository metadata 或 remote 状态，应说明限制，并且只进行安全的只读分析。
