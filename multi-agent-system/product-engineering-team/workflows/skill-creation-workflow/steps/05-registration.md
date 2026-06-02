---
step_id: creation-05
step_name: Registration
responsible_agent: Librarian Agent
inputs:
  - skill_files
  - quality_report
  - decision
outputs:
  - registration_record
  - index_update
next_step: steps/06-release.md
failure_step: null
---

# Step 5: Registration - 注册与索引更新

## Purpose

将 Skill 注册到索引系统，更新依赖关系图。

## Responsible Agent

**Librarian Agent** - 参考: `/Users/apple/Desktop/project/ai-toolkit/multi-agent-system/product-engineering-team/agents/skills-team/librarian-agent.md`

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `skill_files` | Step 03 输出 | Skill 文件包 |
| `quality_report` | Step 04 输出 | 质量报告 |
| `decision` | Step 04 输出 | 审核决策（必须为 pass） |

## Execution Steps

1. **前置验证**
   - 确认 decision.status = pass
   - 确认 quality_report.score >= 80
   - 确认无阻塞问题

2. **Skill ID 分配**
   ```
   skill_id = "SKILL-" + sequence_number
   例如: SKILL-006
   ```

3. **索引更新**
   - 更新 `skills/index.md`
   - 添加新条目
   ```markdown
   | SKILL-006 | Skill Name | [`skill-name/SKILL.md`](./skill-name/SKILL.md) | active | SKILL-001 | 描述 |
   ```

4. **依赖图更新**
   - 在依赖图中添加节点
   - 连接依赖边
   - 验证无循环

5. **注册记录生成**
   - Schema: `skills/schemas/release-record.schema.json`

## Output Contract

```json
{
  "registration_record": {
    "skill_id": "SKILL-006",
    "skill_name": "skill-name",
    "version": "1.0.0",
    "registered_at": "2026-06-02T10:30:00Z",
    "quality_score": 85,
    "dependencies": ["SKILL-001"],
    "status": "registered",
    "registered_by": "Librarian Agent"
  },
  "index_update": {
    "file": "skills/index.md",
    "action": "insert",
    "line": 7,
    "content": "| SKILL-006 | Skill Name | ... |"
  }
}
```

## Index Update Template

```markdown
| 技能ID | 技能名称 | 入口文件 | 状态 | 依赖 | 说明 |
|---|---|---|---|---|---|
| SKILL-006 | Skill Name | [`skill-name/SKILL.md`](./skill-name/SKILL.md) | active | SKILL-001 | Skill 描述 |
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| 决策验证 | 必须为 pass | 自动检查 |
| 索引准确 | 100% | 人工复核 |
| 依赖图正确 | 无循环 | 自动验证 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 决策非 pass | 拒绝注册，返回 Review |
| 依赖冲突 | 召集 Design Agent 协调 |
| 索引写入失败 | 重试，最多 3 次 |

## Handoff

- **成功**: 转入 `steps/06-release.md`
- **失败**: 暂停，协调解决

## Duration Estimate

- 正常: 30 分钟