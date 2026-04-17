# Step 03: Implement High-Priority Fixes

## Goal

基于 gap list 做小批量代码修复，并立即复验。

## Must Use

- `/Users/apple/Desktop/project/ai-toolkit/skills/ui-restore-implementation/SKILL.md`
- `/Users/apple/Desktop/project/ai-toolkit/skills/agent-browser-0.2.0/SKILL.md`

## Actions

1. 每轮选择 1-3 个高优先级 gap（优先 P0/P1）。
2. 修改代码时遵循：
   - 优先修公共 token/基础组件，再修页面局部
   - 不做无关重构
   - 不改业务逻辑（除非影响 UI 正确性）
3. 修改后立即用 `agent-browser` 复验对应页面。
4. 标记每个 gap 状态：
   - `resolved`
   - `partial`
   - `blocked`
   - `regression`

## Output

- 本轮改动文件
- 各 gap 状态结果
- 回归项（如有）及处理计划

