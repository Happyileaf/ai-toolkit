# Requirement Information Model

## Purpose

Use stable, structured records so source coverage, extracted information, frontend relevance, scope, and final-document mapping can be checked independently of prose similarity.

## Recommended record shape

~~~yaml
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
      - requirements/order-management.md#order-list
    related_requirement_ids: []
    reason: null
~~~

Only record a page/line locator when grounded in the source. Otherwise use a verified section, page name, diagram node, or file-level locator. Never fabricate precise locations.

## Required fields and allowed values

| Field | Values / meaning |
|---|---|
| id | Stable unique ID, e.g. FE-ORDER-001 or FE-SHARED-001 |
| module | Business module slug; use shared for cross-module information |
| feature | Page/feature slug when applicable |
| description | One atomic, traceable information item or requirement |
| category | business-context, page, interaction, display-rule, business-rule, permission, data, dependency, exception |
| frontend_relevance | direct, collaborative, contextual, irrelevant |
| certainty | confirmed, inferred, uncertain, conflicted |
| sources | One or more source IDs with grounded locators/evidence |
| dependencies | Requirement IDs or named external dependencies; omit if none |
| scope | new, modify, retain, out-of-scope, unknown |
| notes | Inference basis, exclusion reason, constraints, or other explanation |
| output_mapping | included, merged, referenced, excluded, pending, plus target(s) and reason as applicable |

## Identity and relationships

- IDs must be unique and stable during one analysis. Do not renumber records merely to make them appear contiguous after edits.
- One source can produce multiple records; one record can cite multiple sources.
- One record can map to multiple output locations.
- Multiple records may be merged into one output passage. Preserve all source record IDs in the mapping.
- Dependencies must point to an existing record or be explicitly named as external dependencies.

## Output mapping details

| Status | Required detail |
|---|---|
| included | One or more output targets |
| merged | Target plus IDs of all merged records |
| referenced | Target of the canonical shared rule |
| excluded | Explicit reason |
| pending | Reason and associated open question/quality issue |

Do not use excluded to hide unresolved analysis. Use pending when disposition is not decided.

## Atomicity

Split records when a single description combines independently testable rules, different certainty levels, or different sources that may conflict. Keep related conditions together when separating them would lose meaning. Avoid turning every noun or field into a separate record without a distinct frontend implication.
