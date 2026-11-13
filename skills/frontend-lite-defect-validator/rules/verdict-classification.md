# Verdict 与 Confidence 分类

## 1. Verdict

每个输入问题必须且只能有一个 Verdict。

| Verdict | 中文说明 | 判定标准 |
|---|---|---|
| Confirmed | 已确认 | 有充分证据证明缺陷真实存在 |
| Likely | 高度疑似 | 有较强证据表明问题存在，但缺少关键验证或上下文 |
| Unverified | 无法确认 | 当前证据、信息或环境不足以可靠判断 |
| False Positive | 误报 | 有充分反证证明原始报告描述的问题不成立 |

### Confirmed

需要能够说明：
- 具体代码行为或位置。
- 合理的触发条件或执行路径。
- 当前行为违反的正确性约束或业务预期。
- 实际或可推导的错误影响。

不要求必须通过测试复现。静态代码证据足够充分时可以直接 Confirmed。

### Likely

适用于已发现具体风险代码和合理触发路径，且存在潜在实际影响，但缺少某个关键业务信息、运行时证据或依赖上下文的情况。

不能仅因为代码没有采用某种最佳实践就判定 Likely。

### Unverified

适用于关键业务约束缺失、必要代码不可访问、运行环境不可用，或证据相互矛盾而无法可靠判断的情况。

必须说明：
- 已经确认了什么。
- 尚缺少什么。
- 为什么缺少的信息会影响结论。

### False Positive

必须提供积极反证，例如：
- 原始报告误解代码执行逻辑。
- 报告声称的触发条件在实际流程中不成立。
- 已有保护机制完整覆盖当前问题路径。
- 当前行为符合可确认的业务预期。
- 报告声称的影响不会发生。

未复现、未发现或未能理解，不构成 False Positive 的依据。

## 2. Confidence

每个问题还必须有一个 Confidence：
- **High**：证据充分、直接且相互一致，结论可靠。
- **Medium**：主要证据已具备，但存在有限的不确定因素。
- **Low**：判断依据有限，结论可靠程度较低。

Confidence 表示对当前 Verdict 的把握程度，不是问题严重程度。

## 3. Verdict 与 Confidence 的独立性

示例：
- Confirmed + High：问题成立，证据充分。
- Likely + Medium：风险较强，但仍缺关键验证。
- Unverified + Low：缺少必要信息，无法可靠判断。
- False Positive + High：反证充分，确认报告不成立。

不要用 High Confidence 代替 Confirmed，也不要因为 Severity 高而提高 Verdict。

## 4. Severity

Severity 不是本 Skill 必须输出的核实字段。若原始报告包含严重程度，可以原样保留为输入元数据，但不能用 Severity 推导 Verdict，也不要求 Validator 重新评估严重程度。

## 5. 统计约束

报告中的数量按输入问题条目计算，不按根因或去重后问题计算：

输入总数 = Confirmed 数量 + Likely 数量 + Unverified 数量 + False Positive 数量。
