---
step_id: emergency-05
step_name: Immediate Release
responsible_agent: Librarian Agent
inputs:
  - emergency_assessment
  - fix_result
  - quality_report
outputs:
  - release_record
  - announcement
next_step: null
---

# Step 5: Immediate Release - 立即发布

## Purpose

立即发布紧急修复版本，通知所有相关方。

## Responsible Agent

**Librarian Agent**

## Execution Steps

1. **立即更新版本（patch）**

```yaml
emergency_release:
  version_change: "1.0.0 → 1.0.1"
  release_time: "immediate"
  announcement_channels: ["全员通知", "文档更新", "紧急邮件"]
```

2. **立即发布公告**
   - 全员通知
   - 文档更新
   - 紧急邮件

3. **通知所有相关方**

4. **记录紧急发布**

```yaml
emergency_release_record:
  skill_id: SKILL-003
  emergency_type: security
  triggered_at: "2026-06-02T08:00:00Z"
  released_at: "2026-06-02T20:00:00Z"
  duration: "12 hours"
  fix_scope: minimal
  quality_score: 72
  full_audit_scheduled: "2026-06-09"
```

## Checklist

- [ ] 问题已确认为紧急级别
- [ ] 修复方案已实施
- [ ] 安全问题已验证修复
- [ ] 基本功能已验证可用
- [ ] 版本已更新
- [ ] 全员公告已发送
- [ ] 后续完整审计计划已安排

## Post-Release: 后续完整审计

紧急发布后 7 天内完成完整审计：

1. 补充完整文档
2. 补充完整示例
3. 完整质量评分
4. 必要时进行 minor/major 版本更新

## Emergency Release Permissions

| 角色 | 权限 |
|------|------|
| Evolution Agent | 触发紧急判定 |
| Librarian Agent | 批准紧急发布 |
| Review Agent | 执行快速审核 |
| Generation Agent | 执行快速修复 |

## Output Contract

```json
{
  "release_record": {
    "skill_id": "SKILL-003",
    "emergency_type": "security",
    "version": "1.0.1",
    "released_at": "2026-06-02T20:00:00Z",
    "duration": "12 hours",
    "quality_score": 72
  },
  "announcement": {
    "channels": ["全员通知", "文档更新", "紧急邮件"],
    "full_audit_scheduled": "2026-06-09"
  }
}
```

## Duration Estimate

- 正常: 30 分钟
