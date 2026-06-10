# Schemas

组织级机器可判定产物 Schema 目录。

## 目录约定

- `organization/`: 组织级通用 schema（如统一 envelope）。
- `workflows/<workflow-name>/`: 工作流级产物 schema。
- `schema-registry.json`: 组织级 schema 注册表（唯一索引入口）。

## 使用约定

1. 所有机器可判定产物必须使用组织级 envelope：
   - `schemas/organization/artifact-envelope.schema.json`
2. 具体 payload 由 workflow 级 schema 限定。
3. 运行时应优先按 `schema_id + schema_version` 从 registry 解析 schema 路径。
4. 新增 schema 时必须同步更新 registry。

## 兼容性

- 旧路径 `schemas/skill-*.schema.json` 保留，作为 payload 级 schema。
- 新标准路径为 `schemas/workflows/skill-creation/*.schema.json`。
