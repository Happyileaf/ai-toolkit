---
step_id: cr-05
step_name: Performance & Architecture Review
responsible_agent: Code Review Agent
inputs:
  - project_analysis
  - change_summary
  - logic_issues
  - quality_issues
outputs:
  - performance_issues
  - architecture_issues
  - architecture_verdict
next_step: steps/06-report-generation.md
failure_step: steps/04-code-quality-standards-review.md
---

# Step 5: Performance & Architecture Review - 性能与架构审查

## Purpose

审查代码的性能风险（不必要的渲染、重复计算、资源泄漏）和架构一致性（模块职责、跨模块边界、设计合理性）。

## Responsible Agent

**Code Review Agent**（协作: **Architect Agent**，当涉及高影响架构改动时引入）

## Input Requirements

| 参数 | 来源 | 说明 |
|------|------|------|
| `project_analysis` | Step 02 输出 | 项目结构与核心模块分析 |
| `change_summary` | Step 02 输出 | 变更摘要与影响范围 |
| `logic_issues` | Step 03 输出 | 已发现的逻辑问题 |
| `quality_issues` | Step 04 输出 | 已发现的质量问题 |

## Execution Steps

对每个仓库依次执行以下检查：

### 1. 性能风险检查

#### 1.1 不必要的渲染（React 场景）
```yaml
checklist:
  - use_memo: 复杂计算是否缺少 useMemo
  - use_callback: 回调函数是否缺少 useCallback（当作为 props 传递时）
  - component_memo: 频繁重渲染的组件是否用 React.memo 包裹
  - inline_objects: 是否在 JSX 中内联创建对象/函数导致子组件重渲染
  - list_keys: 列表渲染 key 是否稳定且唯一
```

#### 1.2 重复计算
```yaml
checklist:
  - computed_properties: 是否存在在渲染函数中重复计算的逻辑
  - cache_opportunities: 是否存在可缓存的昂贵计算
  - loop_complexity: 循环中是否有不必要的重复操作
```

#### 1.3 资源泄漏
```yaml
checklist:
  - event_listeners: 事件监听器是否及时移除
  - timers: setTimeout/setInterval 是否清理
  - subscriptions: 订阅是否在卸载时取消
  - large_objects: 是否有大对象/大数组未释放引用
  - image_assets: 图片资源是否过大，是否需要懒加载
```

#### 1.4 数据获取
```yaml
checklist:
  - fetch_on_mount: 组件挂载时是否发起不必要的 API 调用
  - cache_strategy: 数据获取是否有缓存策略
  - waterfall_requests: 是否存在串行请求可改为并行的场景
  - pagination: 列表数据是否缺少分页或虚拟滚动
```

### 2. 架构一致性检查

#### 2.1 模块职责
```yaml
checklist:
  - single_responsibility: 模块/组件是否职责单一
  - layer_boundary: 是否跨层调用（如组件直接调用 API 而非通过 Service）
  - dependency_direction: 依赖方向是否正确（抽象不应依赖具体）
```

#### 2.2 跨模块边界
```yaml
checklist:
  - module_coupling: 模块间耦合度是否在合理范围
  - circular_dependency: 是否存在循环依赖
  - public_api: 模块暴露的接口是否最小化
  - internal_import: 是否导入了模块内部实现而非公共接口
```

#### 2.3 设计合理性
```yaml
checklist:
  - pattern_consistency: 是否遵循项目现有的设计模式
  - over_engineering: 是否存在过度设计（不必要的抽象层）
  - under_engineering: 是否存在设计不足（简单逻辑复杂化）
  - extensibility: 当前设计是否便于后续扩展
```

### 3. 高影响改动升级

对于跨越模块边界、修改核心架构或引入新设计模式的变更：

- 生成架构影响评估
- 引入 **Architect Agent** 进行架构签署
- 记录架构决策上下文

## Output Contract

```json
{
  "performance_issues": [
    {
      "id": "PRF-001",
      "repo_name": "bookmark-lite",
      "file": "src/components/BookmarkList.tsx",
      "line": 34,
      "severity": "major",
      "category": "不必要的渲染",
      "description": "BookmarkCard 组件未使用 React.memo，父组件重渲染时所有卡片会全部重绘",
      "suggestion": "对 BookmarkCard 包裹 React.memo，并确保 props 引用稳定"
    },
    {
      "id": "PRF-002",
      "repo_name": "bookmark-lite",
      "file": "src/components/BookmarkList.tsx",
      "line": 50,
      "severity": "minor",
      "category": "重复计算",
      "description": "sortedBookmarks 在每次渲染时重新排序，列表较大时可能影响性能",
      "suggestion": "使用 useMemo 缓存排序结果，仅在 bookmarks 变更时重新计算"
    }
  ],
  "architecture_issues": [
    {
      "id": "ARC-001",
      "repo_name": "bookmark-lite",
      "file": "src/components/BookmarkList.tsx",
      "line": 10,
      "severity": "major",
      "category": "模块职责",
      "description": "BookmarkList 组件直接调用 API 获取数据，绕过了 Service 层",
      "suggestion": "将数据获取逻辑移至 Service 层或使用数据获取 Hook 封装"
    }
  ],
  "architecture_verdict": {
    "repo_name": "bookmark-lite",
    "high_impact_change": false,
    "architect_review_required": false,
    "major_count": 2,
    "minor_count": 1,
    "summary": "架构整体合理，存在局部优化机会"
  }
}
```

## Quality Criteria

| 指标 | 阈值 | 检查方式 |
|------|------|----------|
| React.memo 检查 | 列表渲染组件需使用 | 模式匹配 |
| 循环依赖检查 | 0 处 | 依赖分析 |
| 架构签署要求 | 高影响改动必须签署 | Architect 确认 |
| 性能问题分级 | 符合实际影响 | 人工复核 |

## Failure Handling

| 场景 | 处理 |
|------|------|
| 架构偏离严重 | 引入 Architect Agent 仲裁，记录偏差 |
| 性能问题阻塞 | 标记为 Major+，建议修复 |
| 依赖分析工具不可用 | 使用文件导入关系分析替代 |

## Handoff

- **complete**: 转入 `steps/06-report-generation.md`