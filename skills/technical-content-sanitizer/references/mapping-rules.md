# 名称映射与上下文管理（Mapping Rules and Context）

## 1. 三层上下文

- **Global Rules**：跨项目通用规则和统一约束。
- **Project Profiles**：特定项目的实体映射、项目专属敏感信息和额外限制。
- **Task Context**：当前任务内识别的实体、跨文件关系、用户确认结果和未解决问题。

Task Context 默认只在当前任务有效，不自动持久化。

## 2. 外部存储

建议默认根目录为 ~/.config/technical-content-sanitizer/，但路径必须可配置，不得假设目录一定存在。结构示意：

```text
technical-content-sanitizer/
├── settings.yaml
├── global/
│   └── rules.yaml
└── projects/
    ├── project-a.yaml
    └── project-b.yaml
```

第一版只需要支持可选的 Global Rules 和临时 Task Context；Project Profiles 预留设计，不要求实现自动管理。外部存储独立于业务代码仓库，不得擅自在业务仓库创建配置文件，不得自动提交 Git 或同步云端。

## 3. 持久化授权

读取可用配置不等于获得修改授权。新增全局规则或项目映射、修改已有映射/规则/设置、删除配置、将 Task Context 转为长期配置，都必须先获得用户明确授权。用户只授权处理文档，不代表授权保存上下文。

## 4. 映射规则

每个实体映射建议包含 entity_id、original、replacement、category、strategy、rationale、scope 和 confirmation。original 属于敏感配置。示例仅使用虚构值：

```yaml
entities:
  - entity_id: service-user
    original: "InternalUserHub"
    replacement: "User Service"
    category: internal_service
    strategy: replace
    scope: task
    confirmation: confirmed
```

## 5. 一致性和冲突

- 同一实体在同一任务的所有文件中使用同一替代名称。
- 同一原始名称若在不同上下文指向不同实体，先消歧，不直接复用映射。
- 不同实体不得无意映射为同一个公开名称。
- 替代名称必须符合真实职责和技术语义。
- 旧映射与当前证据冲突时，标记冲突并请求确认，不得静默覆盖。
- Project Profiles 可以增加约束，但不能覆盖不可降低的安全底线。

## 6. 配置优先关系

Global Rules 提供通用约束；Project Profiles 补充项目专属限制和映射；Task Context 记录本次发现和用户确认。它们不是简单的后者覆盖前者。发生冲突时，安全底线始终生效，采用更严格要求；实体含义或映射冲突时请求确认。

## 7. 隐私保护

外部配置本身按敏感资料保护。不将完整映射表写入公开文章、审查报告或变更记录；不在没有必要时重复展示原始实体名称；不将原始敏感值作为文件名、日志标题或外部请求参数。若外部配置不可读取，说明未加载即可，Skill 仍应独立运行。
