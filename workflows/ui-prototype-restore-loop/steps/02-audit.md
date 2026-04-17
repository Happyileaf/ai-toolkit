# Step 02: Audit Prototype vs Local

## Goal

对每个路由输出结构化 gap list，作为代码修复输入。

## Must Use

- `/Users/apple/Desktop/project/ai-toolkit/skills/agent-browser-0.2.0/SKILL.md`
- `/Users/apple/Desktop/project/ai-toolkit/skills/ui-gap-audit/SKILL.md`

## Actions

对每个 `route_mapping` 执行：

1. 打开 `prototype_url + prototype_route` 和 `local_url + local_route`。
2. 统一 viewport（默认 `1440x900`）。
3. 使用 `agent-browser` 采集：
   - `snapshot -i`
   - 首屏 screenshot
   - 关键区块 screenshot
4. 识别并输出差距，按优先级排序：
   - P0 结构/布局
   - P1 视觉样式
   - P2 状态/交互

其中每条差距需带 `route_mapping_id`，用于回写到对应映射项。

## Output Format

每条 gap 至少包含：

- `id`
- `priority`
- `location`
- `evidence`
- `likely_root_cause`
- `fix_hint`
