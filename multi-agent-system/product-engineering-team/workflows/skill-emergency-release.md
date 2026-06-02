# Skill 紧急发布流程

> 安全问题与重大 Bug 的快速修复通道

## 紧急发布定义

| 类型 | 条件 | 时间要求 |
|------|------|----------|
| **安全问题** | 存在安全漏洞或风险 | 24 小时内 |
| **重大 Bug** | 影响 > 50% 用户 | 48 小时内 |
| **严重故障** | Skill 完全无法使用 | 48 小时内 |

---

## 紧急发布流程

### Step 1: 紧急判定

**触发条件**: Evolution Agent 检测到安全/重大问题

```yaml
emergency_assessment:
  type: security
  severity: critical
  affected_users: "100%"
  time_requirement: "24 hours"
  bypass_normal_process: true
```

**决策者**: Librarian Agent

### Step 2: 快速审计

**跳过正常排期，简化审核流程**

| 正常流程 | 紧急流程 | 变化 |
|----------|----------|------|
| Discovery → Design → Generation | 直接 Generation | 跳过前两步 |
| Review 完整审计 | Review 快速审计 | 仅检查阻塞项 |
| 发布窗口（周二/四） | 立即发布 | 跳过窗口限制 |
| 公告周期（2 周） | 同步公告 | 立即公告 |

### Step 3: 快速修复

**Generation Agent 执行**

1. 定位问题根因
2. 实施最小修复
3. 简化测试验证

```yaml
quick_fix:
  scope: minimal
  changes:
    - "修复安全漏洞"
    - "补充必要验证"
  skip_steps: [discovery, design]
```

### Step 4: 快速审核

**Review Agent 执行**

仅检查阻塞项：

| 检查项 | 标准 |
|------|------|
| 安全问题已修复 | 必须 |
| 无新增阻塞问题 | 必须 |
| 基本功能可用 | 必须 |

**评分阈值降低**: >= 70 分（正常为 80）

### Step 5: 立即发布

**Librarian Agent 执行**

1. 立即更新版本（patch）
2. 立即发布公告
3. 通知所有相关方

```yaml
emergency_release:
  version_change: "1.0.0 → 1.0.1"
  release_time: "immediate"
  announcement_channels: ["全员通知", "文档更新", "紧急邮件"]
```

---

## 紧急发布 Checklist

- [ ] 问题已确认为紧急级别
- [ ] 修复方案已实施
- [ ] 安全问题已验证修复
- [ ] 基本功能已验证可用
- [ ] 版本已更新
- [ ] 全员公告已发送
- [ ] 后续完整审计计划已安排

---

## 后续完整审计

紧急发布后 7 天内完成完整审计：

1. 补充完整文档
2. 补充完整示例
3. 完整质量评分
4. 必要时进行 minor/major 版本更新

---

## 紧急发布记录

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

---

## 紧急发布权限

| 角色 | 权限 |
|------|------|
| Evolution Agent | 触发紧急判定 |
| Librarian Agent | 批准紧急发布 |
| Review Agent | 执行快速审核 |
| Generation Agent | 执行快速修复 |

---

## Metadata

- Version: 1.0
- Owner: Skills Team
- Last Updated: 2026-06-02