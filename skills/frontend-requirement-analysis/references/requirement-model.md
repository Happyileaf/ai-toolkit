# 需求信息模型

## 一、模型目标

使用稳定、结构化的记录，使来源覆盖、提取信息、前端相关性、需求范围和最终文档映射能够独立核对，而不是仅依赖文本相似度。

## 二、推荐记录结构

```yaml
- id: FE-ORDER-001
  module: order-management
  feature: order-list
  description: 订单列表展示订单状态
  category: display-rule
  frontend_relevance: direct
  certainty: confirmed
  sources:
    - source_id: SRC-001
      section: "2.2 订单状态"
      locator: "第 18 页"
      evidence: "订单列表需展示订单状态"
  dependencies: []
  scope: modify
  notes: null
  output_mapping:
    status: included
    targets:
      - frontend-requirements.md#order-management
    related_requirement_ids: []
    reason: null
```

只有来源中确实存在页码/行号时，才能记录对应定位。否则使用已核实的章节、页面名称、流程图节点或文件级定位。不得编造精确位置。

## 三、必需字段与允许值

| 字段 | 取值/含义 |
|---|---|
| id | 稳定且唯一的 ID，例如 FE-ORDER-001 或 FE-SHARED-001 |
| module | 业务模块标识；跨模块信息使用 shared |
| feature | 适用时填写页面/功能标识 |
| description | 一条原子化、可追溯的信息或需求 |
| category | business-context、page、interaction、display-rule、business-rule、permission、data、dependency、exception |
| frontend_relevance | direct、collaborative、contextual、irrelevant |
| certainty | confirmed、inferred、uncertain、conflicted |
| sources | 一个或多个来源 ID，并提供可靠定位/证据 |
| dependencies | 需求 ID 或明确命名的外部依赖；没有依赖时可省略 |
| scope | new、modify、retain、out-of-scope、unknown |
| notes | 推断依据、排除原因、约束或其他说明 |
| output_mapping | included、merged、referenced、excluded、pending，以及适用的目标位置和原因 |

字段名和枚举值作为机器可读标识保留英文；文档中的说明、内容和面向用户的表达默认使用中文。

## 四、身份标识与关联关系

- 同一次分析中的 ID 必须唯一且稳定。修改记录时，不要为了让编号连续而随意重排 ID。
- 一个来源可以产生多条需求；一条需求可以引用多个来源。
- 一条需求可以映射到最终主文档或必要子文档中的多个位置。
- 多条需求可以合并为最终文档中的一段描述，映射中必须保留所有参与合并的需求 ID。
- 依赖关系必须指向现有需求记录，或明确标记为外部依赖。

## 五、输出映射详情

| 状态 | 必须记录的内容 |
|---|---|
| included | 默认指向 `frontend-requirements.md` 的具体章节锚点 |
| merged | 合并后的目标位置，以及所有参与合并的需求 ID |
| referenced | 主文档中的统一规则位置，或确有必要时 references 子文档中的详细内容 |
| excluded | 明确的排除原因 |
| pending | 原因，以及关联的待确认问题/质量异常 |

目标路径优先使用 `frontend-requirements.md#<section-anchor>`。只有确有必要拆分时，才使用 `references/<topic>.md#<section-anchor>`。所有 references 子文档都必须能从主文档直接或经由清晰的章节导航到达。

不得使用 excluded 隐藏尚未完成的分析。处理结果尚未确定时，应使用 pending。

## 六、原子性

当一条描述包含可独立验证的多条规则、不同确定性的信息，或可能相互冲突的不同来源时，应拆分记录。如果拆分会破坏语义，则保留相关条件在同一条记录中。不要仅为每个名词或字段都建立独立记录，只有存在明确前端影响时才拆分。
