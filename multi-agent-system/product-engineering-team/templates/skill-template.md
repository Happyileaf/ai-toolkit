---
name: {{skill_name}}
description: {{skill_description}}
version: 1.0.0
entry: SKILL.md
status: active
type: skill
category: {{category}}
tags:
  - {{tag1}}
  - {{tag2}}
dependencies:
  - {{dependency_list}}
inputs:
  - {{input_list}}
outputs:
  - {{output_list}}
requires_tools:
  - {{tool_list}}
---

# {{skill_name}}

## Purpose

{{purpose_description}}

## Triggers

{{trigger_conditions}}

## Inputs

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| {{input_name}} | {{input_type}} | {{required}} | {{input_description}} |

## Outputs

| 输出 | 类型 | 说明 |
|------|------|------|
| {{output_name}} | {{output_type}} | {{output_description}} |

## Workflow

{{workflow_steps}}

1. {{step_1}}
2. {{step_2}}
3. {{step_3}}

## Examples

### Example 1: {{example_title}}

```text
{{example_content}}
```

### Example 2: {{example_title_2}}

```text
{{example_content_2}}
```

## Constraints

{{constraints_list}}

## Failure Handling

| 场景 | 处理 |
|------|------|
| {{failure_scenario}} | {{failure_handling}} |

## Metadata

- Version: 1.0
- Owner: Skills Team
- Last Updated: {{date}}
- Tags: {{tag_list}}