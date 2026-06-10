# Machine-Readable Artifact Standard

## 目标

将多团队工作流产物统一为可被程序校验、路由、审计的机器可判定结构。

## 组织级标准

### 1) 统一封装（Envelope）

所有机器产物统一使用：

- `schemas/organization/artifact-envelope.schema.json`

标准结构：

```json
{
  "artifact_type": "pd-01-intake-output",
  "artifact_meta": {
    "schema_id": "workflow.product-development.step-artifact",
    "schema_version": "v1",
    "workflow_id": "WF-PD-2026-001",
    "step_id": "pd-01",
    "generated_at": "2026-06-10T09:00:00Z",
    "generated_by": "Product Team Leader Agent",
    "source_ref": "a1b2c3d4"
  },
  "data": {}
}
```

### 2) 统一注册（Registry）

所有 schema 通过唯一注册表管理：

- `schemas/schema-registry.json`

运行时解析规则：

1. 读取 `artifact_meta.schema_id`
2. 读取 `artifact_meta.schema_version`
3. 在 registry 中定位 schema 路径
4. 执行 schema 校验

### 3) 统一版本策略

- 兼容变更：同主版本内新增可选字段
- 非兼容变更：升级主版本（`v1 -> v2`）
- 禁止覆盖发布：同路径同版本 schema 不可原地破坏性修改

## 当前落地范围

- Skills Team：已纳入组织级路径（workflow wrapper schema + legacy payload schema 兼容）
- Product Development Workflow：已提供 step artifact 统一 schema

## 责任分工

- Platform Team：维护 envelope、registry、校验策略
- 各业务 Team：维护自身 workflow payload schema
- Workflow Orchestrator：按 schema 门禁拒绝不合规产物

## 门禁要求

以下场景必须通过 schema 校验：

1. 跨 Agent 交接（handoff）
2. 质量门禁判定前
3. 发布决策前
4. 记忆写入前
