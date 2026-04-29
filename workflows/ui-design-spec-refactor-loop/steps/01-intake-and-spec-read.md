# Step 01: Intake and Spec Read

## Goal

收集输入参数并完成设计规范读取，不做任何代码修改。

## Inputs

- `design_spec_path`
- `frontend_project_root`
- `target_pages`
- `max_rounds_per_page`
- `acceptance_threshold`
- `constraints`

## Actions

1. 校验 `design_spec_path` 是否存在且可读。
2. 若 `design_spec_path` 指向目录，且目录内存在 `README.md`，先重点阅读 `README.md`，提取其对规范结构、术语、优先级和适用范围的定义。
3. 读取设计规范全文并建立“可引用章节索引”：
   - 不预设分类，不强行套用固定模板
   - 严格按设计规范原始结构抽取章节/小节
   - 对每条可执行规则保留来源定位（章节标题、编号、段落或锚点）
4. 输出“规范理解摘要”：
   - 不少于 8 条可执行规则
   - 每条规则附规范章节来源
5. 明确禁止项：此步骤及后续步骤都不得改业务逻辑。

## Exit Criteria

- 成功读取规范文件
- 生成规范章节索引
- 生成可执行规则清单
- 明确“只改 UI，不改功能”

## Output Template

```text
[Step01 Completed]
- design_spec_path: ...
- spec_sections_indexed: N
- executable_rules:
  1) ...
  2) ...
- constraints_confirmed:
  - 只改 UI，不改功能
```
