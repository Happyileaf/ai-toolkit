# Step 02: Spec Read and Understanding

## Goal

将“读取和理解设计规范”作为独立阶段完成，产出可追溯、可执行的规范理解结果，不做任何代码修改。

## Inputs

- `design_spec_path`
- `target_pages`

## Actions

1. 完整阅读 `design_spec_path` 全文，禁止跳读关键章节。
2. 建立“规范章节索引”（章节标题、编号、路径或锚点）。
3. 提取可执行规则并按优先级分类：
   - `P0`：必须满足
   - `P1`：强烈建议满足
   - `P2`：可延后优化
4. 输出“规范理解摘要”：
   - 不少于 12 条可执行规则
   - 每条规则必须附来源定位
5. 识别规范冲突处理原则：
   - 规范内部冲突时的优先级
   - 规范与现有实现冲突时以规范为准（功能边界除外）

## Guardrails

- 禁止在此步骤做任何 UI 或业务代码改动。
- 禁止把现有样式实现当作规范解释依据。

## Exit Criteria

- 完成规范全文阅读
- 规范章节索引完成
- 可执行规则清单完成（不少于 12 条，含来源）
- 规范理解摘要可被后续步骤直接消费

## Output Template

```text
[Step02 Completed]
- spec_sections_indexed: N
- executable_rules:
  - id: R1
    priority: P0 | P1 | P2
    source: ...
    rule: ...
- spec_understanding_summary:
  - ...
- conflict_resolution_principles:
  - ...
```
