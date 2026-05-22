# 冲刺契约：{{FEATURE_NAME}}

## 元信息（Meta）

- **规格文件（Spec）**：`.harness/docs/specs/{{FEATURE_NAME}}.md`
- **创建时间（Created）**：{{DATE}}
- **状态（Status）**：draft
- **最大迭代次数（Max Iterations）**：3
- **执行门禁（Execution Gate）**：required 门禁通过（convention-check + lint + typecheck + unit + build + required e2e + required Agent Review）

## 范围（Scope）

### 假设（Assumptions）

| 假设 | 证据/来源 | 如果错误的影响 | 处理方式 |
|---|---|---|---|
| | | | |

### 歧义与自动决策（Ambiguities & Decisions）

| 问题 | 影响面 | 自动决策 | 证据/风险/验证方式 |
|---|---|---|---|
| | | | |

### 取舍（Tradeoffs）

| 方案 | 优点 | 代价/风险 | 结论 |
|---|---|---|---|
| 最小方案 | | | |
| 替代方案 | | | |

### 范围内（In Scope）

-

### 范围外（Out of Scope）

-

## 前端门禁（Frontend Gates）

- [ ] 响应式：覆盖桌面与移动关键断点
- [ ] 无障碍：键盘可达、语义标签、图片 alt
- [ ] 状态流：加载态、空态、错误态
- [ ] 性能预算：首屏/包体/交互延迟（按项目约束）
- [ ] 设计系统一致性：优先 token/CSS 变量，不散落魔法值

## 验收标准（Acceptance Criteria）

| # | 标准（Criterion） | 验证方法（Verification Method） | 状态（Status） |
|---|---|---|---|
| 1 | | unit | [ ] |
| 2 | | build | [ ] |
| 3 | | e2e | [ ] |
| 4 | | a11y | [ ] |
| 5 | | manual | [ ] |

## 集成测试矩阵（Integration Test Matrix）

| ID | 验收项 | 场景/页面 | 测试入口（test_class） | 核心断言 | 异常场景 | 门禁 |
| --- | --- | --- | --- | --- | --- | --- |
| IT-01 | 无 | 无 | 无 | 无 | 无 | advisory |

门禁取值：
- `required`：失败则禁止 `passes=true`
- `advisory`：失败进入 QA 报告，但不阻塞
- `manual`：必须人工确认

## 冲刺日志（Sprint Log）

| 迭代轮次 | Generator 输出 | Evaluator 评分 | 问题 |
|---|---|---|---|
| | | | |

## 执行确认（Execution Sign-off）

- **Generator**：[ ] 同意标准与范围
- **Evaluator**：[ ] 同意验证方式
- **User Input**：[ ] 用户输入默认已确认；本契约记录自动决策、风险和验证方式
