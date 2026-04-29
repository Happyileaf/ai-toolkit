# Step 05: Acceptance and Next Page

## Goal

完成当前页面验收判定，并在有下一页面时继续执行同样的去锚点重构流程。

## Actions

1. 汇总当前页面全部轮次结果：
   - 已执行的 `bold_transform` 项
   - 规范对齐情况与残留偏差
   - 功能等价验证结果
2. 给出页面最终状态：
   - `accepted`：规范、功能、boldness 全通过
   - `accepted_with_deviation`：轮次到上限，功能通过但存在可接受视觉偏差
   - `not_accepted`：功能或规范关键项未达标
3. 若存在下一个页面，返回 Step 03。
4. 所有页面完成后，输出全局报告。

## Final Report Template

```text
[Workflow Final Report]
- constraints:
  - 只改 UI，不改功能
- pages_total: ...
- pages_accepted: ...
- pages_accepted_with_deviation: ...
- pages_not_accepted: ...
- per_page_summary:
  - page: ...
    rounds_used: ...
    bold_transforms_done: ...
    final_status: accepted | accepted_with_deviation | not_accepted
    remaining_gaps: ...
- global_risks:
  - ...
```
