---
description: 让 evaluator 对当前前端代码状态执行评估
argument-hint: 可选 - 指定要评估的 contract 或 spec
---

# 质量保障（QA Gate）

对当前实现执行完整评估流程，并将验证结果写入 QA 报告。

## 流程

1. 自动选择目标 contract（有参数则用参数）。
2. 运行 QA Runner：

```bash
python3 .harness/scripts/qa_runner.py --target-dir . --contract "<contract 文件>"
```

3. QA Runner 默认执行：
- frontend_doctor
- convention-check
- lint
- typecheck
- unit
- build
- e2e（按 required/advisory）
- agent review closeout

4. 读取 `qa_report` 与 `result.json`，输出评分与门禁结论。

若 Gate FAIL：进入修复循环。
若 Gate PASS：可进入 mark_pass 前置检查。
