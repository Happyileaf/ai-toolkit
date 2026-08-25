---
description: 基于简短描述执行完整 Plan-Build-Verify 前端冲刺
argument-hint: 功能描述（1-4 句话）
---

# 全流程冲刺

针对以下需求执行完整 `Plan -> Build -> Verify` 周期：$ARGUMENTS

## 冲刺阶段

1. Plan：产出 spec。
2. Contract：固化验收标准、门禁和验证方式。
3. Build：按范围实现。
4. QA：运行 qa_runner，生成报告。
5. Fix loop：最多 3 轮。
6. Complete：required 门禁通过后 mark pass + session_close。

若 3 轮后仍失败：保留 `passes=false`，记录失败并继续下个任务。
