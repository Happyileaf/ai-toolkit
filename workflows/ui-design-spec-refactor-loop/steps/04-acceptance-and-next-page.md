# Step 04: Acceptance and Next Page

## Goal

完成当前页面的收敛判定，并决定是否进入下一页面。

## Actions

1. 汇总当前页面各轮结果：
   - 总轮次
   - 每轮修改-验证结论
   - 最终符合度与残留偏差
2. 对当前页面给出最终状态：
   - `accepted`：达到可接受范围
   - `accepted_with_deviation`：达到上限后可接受但存在轻微偏差
   - `not_accepted`：达到上限仍不可接受
3. 若存在下一个页面，回到 Step 02 继续。
4. 所有页面完成后输出总报告。

## Final Report Template

```text
[Workflow Final Report]
- constraints:
  - 只改 UI，不改功能
- pages_total: ...
- pages_accepted: ...
- pages_not_accepted: ...
- per_page_summary:
  - page: ...
    rounds_used: ...
    round_summaries: ...
    final_status: accepted | accepted_with_deviation | not_accepted
    remaining_gaps: ...
- global_risks:
  - ...
```
