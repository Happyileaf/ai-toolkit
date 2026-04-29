# Step 01: Intake and Functional Lock

## Goal

确认输入参数有效，锁定“功能不变”边界，为后续激进 UI 重构建立安全护栏。

## Inputs

- `design_spec_path`
- `frontend_project_root`
- `target_pages`
- `max_rounds_per_page`
- `acceptance_threshold`
- `constraints`

## Actions

1. 校验输入完整性与路径可读性（尤其是 `design_spec_path` 与 `frontend_project_root`）。
2. 逐页识别功能不变清单（Functional Invariants）：
   - 关键交互（提交、跳转、筛选、分页、弹窗确认等）
   - 数据结果（请求触发时机、参数语义、渲染结果）
   - 业务约束（权限、校验、错误态处理）
3. 标记“禁止改动区域”：
   - 业务逻辑层
   - 数据流/状态管理核心流程
   - 接口调用契约
4. 输出页面执行顺序与每页功能锁定摘要。

## Exit Criteria

- 输入参数确认完成
- 每个 `target_page` 都有功能不变清单
- 明确“可改 UI / 不可改业务”边界

## Output Template

```text
[Step01 Completed]
- pages_in_scope: ...
- functional_invariants:
  - page: ...
    invariants:
      - ...
- forbidden_change_areas:
  - 业务逻辑
  - 数据流与接口契约
```
