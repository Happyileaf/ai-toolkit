---
description: 按冲刺工作流实现最近的前端规格说明
argument-hint: 可选 - 指定 .harness/docs/specs/ 中要实现的 spec 文件
---

# 构建功能

使用 Generator-Evaluator 循环实现功能。

**目标**：$ARGUMENTS（为空时默认使用 `.harness/docs/specs/` 中最近修改的规格）

## 流程

1. 读取目标 spec 与 contract。
2. 如 contract 缺失，先基于模板创建。
3. 按 contract 范围实现功能，完成前端自检：
   - 响应式（桌面/移动）
   - a11y 关键项（键盘流/语义/alt）
   - 状态流（加载/空/错误）
4. 运行 QA Gate：`qa_runner.py`。
5. 若失败，进入 fix loop（最多 3 轮）。
6. required 门禁通过后再 mark pass 并 session_close。
