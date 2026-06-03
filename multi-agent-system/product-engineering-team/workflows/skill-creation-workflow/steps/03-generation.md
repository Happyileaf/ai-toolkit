---
step_id: creation-03
step_name: Generation
responsible_agent: Generation Agent
inputs:
  - skill_design_doc
  - skill_template
  - coding_standards
outputs:
  - skill_files
  - self_check_report
next_step: steps/04-review.md
failure_step: steps/02-design.md
---

# Step 3: Generation - 文件生成与自检

## Purpose

根据设计文档生成符合规范的 Skill 文件包。

## Responsible Agent

**Generation Agent** - 参考: `../../../agents/skills-team/generation-agent.md`

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `skill_design_doc` | Step 02 输出 | 设计文档 |
| `skill_template` | `../../../templates/` | Skill 模板库 |
| `coding_standards` | `rules/coding/` | 编码规范 |

## Execution Steps

1. **模板选择**
   - 根据设计选择合适模板
   - 模板路径: `../../../templates/skill-template.md`

2. **SKILL.md 编写**
   ```markdown
   ---
   name: skill-name
   description: Skill 描述
   version: 1.0.0
   entry: SKILL.md
   status: active
   type: skill
   category: category-name
   tags: [tag1, tag2]
   dependencies:
     - skills/skill-001/SKILL.md
   inputs:
     - input_name
   outputs:
     - output_name
   ---
   
   # Skill Name
   
   ## Purpose
   ## Triggers
   ## Inputs
   ## Outputs
   ## Workflow
   ## Examples
   ## Constraints
   ```

3. **元数据生成**
   - 生成 `_meta.json`
   - Schema: `../../../schemas/skill-package.schema.json`

4. **示例编写**
   - 至少 2 个使用示例
   - 覆盖主要场景
   - 示例可执行

5. **自检执行**
   - 规范合规检查
   - 模板完整性检查
   - 依赖声明检查

## Output Contract

```json
{
  "skill_files": {
    "skill_id": "SKILL-XXX",
    "files": [
      {
        "path": "skills/skill-name/SKILL.md",
        "type": "main",
        "size": "500 lines"
      },
      {
        "path": "skills/skill-name/_meta.json",
        "type": "metadata"
      },
      {
        "path": "skills/skill-name/examples/example-01.md",
        "type": "example"
      }
    ],
    "total_files": 3
  },
  "self_check_report": {
    "compliance_check": {
      "naming": "passed",
      "structure": "passed",
      "comments": "passed"
    },
    "template_check": {
      "required_fields": "all_present",
      "optional_fields": "3_present"
    },
    "dependency_check": {
      "declared": ["SKILL-001"],
      "missing": [],
      "version_specified": true
    },
    "overall_status": "ready_for_review"
  }
}
```

## File Structure

```
skills/skill-name/
├── SKILL.md          # 主文件（必须）
├── _meta.json        # 元数据（必须）
├── examples/
│   ├── example-01.md # 示例 1
│   └── example-02.md # 示例 2
└── tests/            # 测试（可选）
    └── test-01.md
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 规范合规率 | 100% | 自动 lint |
| 文档完整度 | >= 95% | Schema 验证 |
| 示例数量 | >= 2 | 文件计数 |
| 依赖声明 | 必须显式 | 自动检查 |

## Generation Rules

| 规则 | 要求 |
|------|------|
| 模板优先 | 使用现有模板保证一致性 |
| 语言一致 | 文档语言与用户语言一致 |
| 不超范围 | 不生成设计文档未定义的功能 |
| 版本声明 | 依赖版本必须显式 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 模板不匹配 | 请求 Design Agent 澄清或创建新模板 |
| 规范冲突 | 标记问题，请求规则更新 |
| 自检失败 | 自动修复或返回 Design |

## Handoff

- **成功**: 转入 `steps/04-review.md`
- **自检失败**: 自动修复后重试，最多 2 次
- **无法修复**: 返回 `steps/02-design.md`

## Duration Estimate

- 正常: 2-4 小时
- 复杂 Skill: +2 小时
