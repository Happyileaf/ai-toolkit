---
step_id: creation-06
step_name: Release
responsible_agent: Librarian Agent
inputs:
  - registration_record
outputs:
  - release_record
  - changelog
  - announcement
next_step: null
failure_step: null
---

# Step 6: Release - 发布与公告

## Purpose

正式发布 Skill，生成变更日志与发布公告。

## Responsible Agent

**Librarian Agent** - 参考: `../../../agents/skills-team/skills-librarian-agent.md`

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `registration_record` | Step 05 输出 | 注册记录 |

## Execution Steps

1. **发布准备**
   - 确认发布窗口（周二/四）
   - 确认无依赖阻塞
   - 准备发布公告

2. **版本号分配**
   ```
   version = "1.0.0"  # 首次发布
   ```
   - 遵循语义化版本规范
   - 参考: `../../../skill-versioning-policy.md`

3. **变更日志生成**
   ```markdown
   ## v1.0.0 - 2026-06-02
   
   ### New
   - 新增 Skill: skill-name
   - 功能描述
   
   ### Dependencies
   - 依赖: SKILL-001
   
   ### Quality
   - 质量评分: 85
   ```

4. **发布公告**
   ```markdown
   # Skill 发布公告
   
   ## 发布信息
   - Skill ID: SKILL-006
   - Skill 名称: skill-name
   - 版本: 1.0.0
   - 发布时间: 2026-06-02
   
   ## 功能说明
   - 使用场景: ...
   - 主要功能: ...
   
   ## 使用方式
   - 触发条件: ...
   - 输入参数: ...
   - 输出结果: ...
   
   ## 依赖
   - SKILL-001
   
   ## 注意事项
   - 约束条件: ...
   ```

5. **状态更新**
   - 更新 SKILL.md status: active
   - 更新 index.md status: active

## Output Contract

```json
{
  "release_record": {
    "skill_id": "SKILL-006",
    "version": "1.0.0",
    "released_at": "2026-06-02T11:00:00Z",
    "release_type": "new",
    "quality_score": 85,
    "dependencies": ["SKILL-001"],
    "changelog": "CHANGELOG.md 新增条目",
    "status": "active"
  },
  "changelog": {
    "file": "skills/CHANGELOG.md",
    "entry": "## v1.0.0 - 2026-06-02\n### New\n- 新增 Skill: skill-name"
  },
  "announcement": {
    "title": "Skill 发布公告: skill-name v1.0.0",
    "content": "...",
    "channels": ["团队公告", "文档更新"]
  }
}
```

## Release Checklist

- [ ] 版本号符合语义化规范
- [ ] 变更日志已更新
- [ ] 发布公告已发送
- [ ] SKILL.md status 已更新
- [ ] index.md 已更新
- [ ] 依赖图已更新

## Failure Handling

| 场景 | 处理 |
|------|------|
| 发布失败 | 执行回滚，记录故障 |
| 依赖阻塞 | 暂停发布，协调解决 |

## Workflow Completion

此步骤完成后，Skill 创建工作流结束。

输出最终报告:
```json
{
  "workflow_result": {
    "status": "completed",
    "skill_id": "SKILL-006",
    "version": "1.0.0",
    "quality_score": 85,
    "total_duration": "6 hours",
    "steps_completed": 6
  }
}
```

## Duration Estimate

- 正常: 30 分钟
