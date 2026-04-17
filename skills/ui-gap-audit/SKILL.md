---
name: ui-gap-audit
description: 使用 agent-browser 对比原型页与本地前端页面，输出结构化 UI 差距清单（含优先级）并给出可执行修复建议。
---

# UI Gap Audit

本 skill 专注“找差距”，不负责大规模代码改动。

## Must Use Tooling

必须先读取：

- `/Users/apple/Desktop/project/ai-toolkit/skills/agent-browser-0.2.0/SKILL.md`

对比时必须使用 `agent-browser`（open/snapshot/screenshot/wait/get 等）。

## Inputs

- `prototype_page_url`
- `local_page_url`
- 可选：`viewport`（默认 `1440x900`）
- 可选：`state_matrix`（如 default/hover/active/focus/disabled）

## Copy-Paste Audit Prompt

```text
请使用 ui-gap-audit 对以下页面进行比对并输出可执行 gap list：
- prototype_page_url: {PROTOTYPE_PAGE_URL}
- local_page_url: {LOCAL_PAGE_URL}
- viewport: 1440x900
- state_matrix: default, hover, focus, active, disabled

要求：
1) 必须使用 agent-browser 采集证据（snapshot/screenshot/wait）。
2) 差距按 P0/P1/P2 排序。
3) 每条差距包含 id、location、evidence、likely_root_cause、fix_hint。
```

## Comparison Procedure

1. 统一环境
- 两端都设置同样 viewport。
- 等待页面加载稳定（`wait --load networkidle`）。
- 必要时滚动到关键区块并截图。

2. 获取证据
- 对两端分别执行 `snapshot -i` 获取交互元素。
- 对首屏和关键区块截图。
- 记录标题、URL、核心节点文本等基础信息。

3. 差距扫描（按优先级）
- P0 结构/布局：区块顺序、网格列数、容器宽度、元素位置、遮挡溢出、响应式断点异常。
- P1 视觉样式：字体族/字号/字重、行高、色值、背景、边框、圆角、阴影、间距。
- P2 状态/交互：hover/focus/active/disabled、可点击反馈、过渡动画、加载/空态/错误态。

4. 输出修复导向清单
- 每条差距包含：`id`、`priority`、`location`、`evidence`、`likely_root_cause`、`fix_hint`。

## Output Template

按以下结构输出：

```text
[Route] /example
1) GAP-001 | P0 | Hero 区域布局错位
- Evidence: 原型中 CTA 与标题同一基线，本地 CTA 下沉约 24px
- Likely cause: flex 对齐方式/容器高度不一致
- Fix hint: 检查 Hero 容器的 align-items、line-height、padding-top

2) GAP-002 | P1 | 主按钮视觉不一致
- Evidence: 原型按钮圆角更大、阴影更浅、字重更高
- Likely cause: 组件 token 未同步
- Fix hint: 对齐 button 的 border-radius/box-shadow/font-weight
```

只保留可执行差距，不写笼统描述。

## Structured Output (Preferred)

如果下游需要程序化消费，优先输出以下结构：

```yaml
route: /example
route_mapping_id: home
prototype_route: /
local_route: /
gaps:
  - id: GAP-001
    priority: P0
    location: Hero
    evidence: CTA 与标题基线不齐，约下沉 24px
    likely_root_cause: flex 对齐策略不一致
    fix_hint: 对齐容器 align-items 和标题行高
  - id: GAP-002
    priority: P1
    location: PrimaryButton
    evidence: 圆角偏小，阴影偏重，字重偏低
    likely_root_cause: token 未同步
    fix_hint: 对齐 border-radius box-shadow font-weight
```
