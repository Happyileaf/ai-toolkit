# Step 04: Loop Control and Stop Criteria

## Goal

按轮次持续迭代，直到满足停止条件。

## Loop Rule

执行顺序：

1. 运行 `02-audit`
2. 运行 `03-implement`
3. 更新剩余 gap 列表
4. 若未满足停止条件，继续下一轮

## Stop Criteria

满足任一即可停止：

1. P0/P1 gap 全部关闭
2. 连续 2 轮无明显提升
3. 达到 `max_rounds`
4. 用户主动停止并接受当前结果

## Final Output

结束时必须输出：

1. 还原结果摘要（按路由）
2. 已关闭 gap 列表
3. 剩余 gap 列表（含原因）
4. 建议后续优化项

