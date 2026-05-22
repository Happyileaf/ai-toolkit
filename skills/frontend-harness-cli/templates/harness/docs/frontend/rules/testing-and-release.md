# 测试与发布规则

本文件适用于质量门禁、自动化测试、发布回归和验收归档相关改动。

## 1. 触发条件

- 修改 lint/typecheck/unit/build/e2e 脚本。
- 新增或修改测试用例、测试配置、测试数据。
- 调整 QA Gate、发布前检查或回滚流程。

## 2. 核心门禁

1. **基础门禁稳定**：lint/typecheck/unit/build 必须可执行且通过。
2. **场景门禁明确**：required/advisory/manual 场景定义清晰。
3. **失败可定位**：失败日志、复现步骤、修复建议明确。
4. **结果可归档**：QA 报告和 result JSON 必须落盘。
5. **发布可回归**：关键路径有回归清单与回滚方案。

## 3. 执行建议

- required 场景优先自动化；无法自动化时提供稳定手测步骤和证据模板。
- e2e 用例优先覆盖主链路、异常链路和权限边界。
- 保持测试命名和目录结构与项目现状一致，避免并行体系。
- Agent Review 设置为 required 时，accepted/actionable finding 必须一次性清零。

## 4. 验收证据

- `.harness/docs/qa/<feature>.md` 与 `.result.json` 已生成。
- QA 报告包含 required 门禁通过统计与失败项列表。
- 发布前人工检查项在 contract 中有明确完成记录。

