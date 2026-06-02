---
step_id: creation-02
step_name: Design
responsible_agent: Design Agent
inputs:
  - skill_proposal
  - existing_skills
  - dependency_graph
outputs:
  - skill_design_doc
  - interface_contract
  - dependency_analysis
next_step: steps/03-generation.md
failure_step: steps/01-discovery.md
---

# Step 2: Design - 架构设计与契约定义

## Purpose

根据提案设计 Skill 架构，定义边界、接口契约与依赖关系。

## Responsible Agent

**Design Agent** - 参考: `../../agents/skills-team/design-agent.md`

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `skill_proposal` | Step 01 输出 | Skill 提案文档 |
| `existing_skills` | Librarian Agent 查询 | 现有 Skill 库 |
| `dependency_graph` | Librarian Agent 查询 | 依赖关系图 |

## Execution Steps

1. **边界分析**
   - 分析提案场景
   - 定义职责范围（单一职责原则）
   - 明确不做的事情

2. **重复检查**
   - 搜索现有 Skill 库
   - 检测功能重叠
   - 标记冲突或合并候选

3. **接口设计**
   ```yaml
   interface_contract:
     inputs:
       - name: input_name
         type: string | object | array
         required: true | false
         default: null
         description: 输入说明
     outputs:
       - name: output_name
         type: string | object | array
         description: 输出说明
     triggers:
       - condition: 触发条件
         description: 触发说明
   ```

4. **依赖分析**
   - 识别必需依赖
   - 检查循环依赖
   - 计算依赖深度（必须 <= 3）

5. **风险评估**
   ```yaml
   risk_assessment:
     technical_risks: [技术风险列表]
     dependency_risks: [依赖风险列表]
     mitigation_strategies: [缓解策略]
   ```

6. **设计文档生成**
   - Schema: `skills/schemas/skill-design.schema.json`

## Output Contract

```json
{
  "skill_design_doc": {
    "skill_id": "SKILL-XXX",
    "title": "Skill 名称",
    "scope": {
      "includes": ["职责列表"],
      "excludes": ["不做的事项"]
    },
    "interface_contract": {
      "inputs": [...],
      "outputs": [...],
      "triggers": [...]
    },
    "dependencies": {
      "required": ["SKILL-001"],
      "optional": [],
      "depth": 1
    },
    "risk_assessment": {
      "technical_risks": [],
      "dependency_risks": [],
      "mitigation_strategies": []
    },
    "naming_convention": {
      "skill_name": "skill-name",
      "category": "category"
    }
  },
  "interface_contract": { ... },
  "dependency_analysis": {
    "graph_node": "SKILL-XXX",
    "dependencies": ["SKILL-001"],
    "dependents": [],
    "depth": 1,
    "circular_check": "passed"
  }
}
```

## Design Principles

| 原则 | 要求 |
|------|------|
| 单一职责 | 每个 Skill 只做一件事 |
| 最小依赖 | 仅依赖必需的其他 Skill |
| 可组合性 | 设计可被其他 Skill 组合 |
| 命名一致 | 遵循既定命名规范 |

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 职责数量 | <= 3 | 人工评审 |
| 依赖深度 | <= 3 | 自动计算 |
| 循环依赖 | 无 | 自动检测 |
| 接口完整性 | 100% | Schema 验证 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 边界模糊 | 返回 Step 01 补充，最多 2 次重试 |
| 功能重叠 | 提出合并方案或终止 |
| 循环依赖 | 提出替代方案 |
| 依赖深度 > 3 | 建议拆分或简化 |

## Handoff

- **成功**: 转入 `steps/03-generation.md`
- **需澄清**: 返回 `steps/01-discovery.md`
- **冲突**: 升级至 Librarian Agent 仲裁

## Duration Estimate

- 正常: 2-4 小时
- 需澄清返回: +1 天