# GitHub Flow 使用规范（GIT-GITHUBFLOW-001）

## 1. 目标
- 统一团队 GitHub Flow 工作流使用方式，明确分支角色与流转规则，确保代码集成的简洁性和可部署性。

## 2. 适用范围
- 适用场景：采用持续部署模式的中小型项目团队，Web/SaaS 产品开发。
- 不适用场景：需要多版本并行维护的项目、有明确版本发布周期的项目（组织已全量切换 GitHub Flow，此类场景需通过 Feature Flag 和环境隔离解决，不再采用已弃用的 GitFlow）。

## 3. 规则内容

### 3.1 核心分支

#### 3.1.1 main / master
- 必须：始终保持稳定可部署状态。
- 必须：所有辅助分支均从 `main` 创建，合入目标均为 `main`。
- 禁止：直接在 main 上提交代码。

### 3.2 辅助分支

> GitHub Flow 中所有辅助分支的流转规则相同：从 `main` 创建 → 通过 PR 合回 `main` → 合入后删除。分支类型仅用于**标注意图**，不改变流程结构。

#### 3.2.1 feature 分支
- 必须：从 `main` 分支创建。
- 必须：命名格式为 `feature/<scope>-<description>`（如 `feature/user-email-register`）。
- 必须：开发完成后通过 PR 合回 `main` 分支。
- 必须：合并后删除该 feature 分支。
- 建议：一个 feature 分支对应一个功能点。
- 禁止：同时开发多个不相关功能。

#### 3.2.2 bugfix 分支
- 必须：从 `main` 分支创建。
- 必须：命名格式为 `bugfix/<scope>-<description>`（如 `bugfix/api-timeout-error`）。
- 必须：修复完成后通过 PR 合回 `main` 分支。
- 必须：合并后删除该 bugfix 分支。

#### 3.2.3 hotfix 分支
- 必须：从 `main` 分支创建（组织已弃用 GitFlow，无需回流 develop）。
- 必须：命名格式为 `hotfix/<scope>-<description>`（如 `hotfix/login-crash`）。
- 必须：修复完成后通过 PR 合回 `main` 分支。
- 必须：合并至 `main` 时建议打 tag（如 `v1.2.1`）。
- 必须：合并后删除该 hotfix 分支。
- 建议：hotfix PR 应标记为紧急，优先 Review 和合入。

#### 3.2.4 refactor 分支
- 必须：从 `main` 分支创建。
- 必须：命名格式为 `refactor/<scope>-<description>`（如 `refactor/auth-strategy-pattern`）。
- 必须：完成后通过 PR 合回 `main` 分支。
- 必须：合并后删除该 refactor 分支。

### 3.3 合入规则

#### 3.3.1 合入方式
- 必须：使用 Pull Request 方式合入，禁止直接 push 合入。
- 必须：PR 必须至少一人 Code Review 通过后方可合入。
- 必须：合入前必须确保 main 的最新代码已合并至当前分支（避免冲突）。
- 建议：合入前 PR 必须通过 CI 自动化检查（测试、Lint、构建）。

#### 3.3.2 合入冲突处理
- 必须：由分支创建者负责解决冲突。
- 必须：解决冲突后必须重新运行测试验证。
- 禁止：使用 `push --force` 解决冲突。

#### 3.3.3 合入后操作
- 必须：合入后在远端删除已合并的辅助分支。
- 建议：合入后清理本地对应的分支引用。
- 建议：合入后触发自动部署流程。

### 3.4 特性开关（Feature Flag）

> GitHub Flow 不依赖 develop 分支隔离未完成功能，推荐使用特性开关控制功能可见性。

- 建议：未完成功能合入 main 时，通过 Feature Flag 关闭对用户的可见性。
- 建议：功能开发完成并验证后，通过 Feature Flag 开放给用户。
- 建议：Feature Flag 稳定运行一段时间后，移除开关代码。

### 3.5 分支流转图

```
main ───────────────────────────────────────────── 所有分支的源与目标
  │
  ├── feature/user-email-register ──────────────── PR 合回 main
  ├── bugfix/api-timeout-error ─────────────────── PR 合回 main
  ├── hotfix/login-crash ───────────────────────── PR 合回 main（建议打 tag）
  └── refactor/auth-strategy-pattern ───────────── PR 合回 main
```

### 3.6 禁止事项
- 禁止直接在 main 上提交代码。
- 禁止使用 `develop`、`release` 等长期辅助分支（避免分支膨胀）。
- 禁止跳过 Code Review 直接合入。
- 禁止使用 `push --force` 操作。
- 禁止保留已合并的辅助分支。

## 4. 输出要求
- 必须严格遵循 GitHub Flow 分支流转规则（单线循环模型）。
- 必须通过 PR 流程合入代码。
- 所有辅助分支必须从 `main` 创建并合回 `main`。

## 5. 示例

### 合规示例

**功能开发流程：**
```
1. 从 main 创建 feature/user-email-register
2. 在 feature 分支上开发并提交
3. 提交 PR 到 main，指定 Reviewer
4. Code Review 通过后合入 main
5. 合入后触发自动部署
6. 删除 feature/user-email-register 分支
```

**紧急修复流程：**
```
1. 从 main 创建 hotfix/login-crash
2. 在 hotfix 分支上修复并提交
3. 提交 PR 到 main，标记为紧急 Review
4. Code Review 通过后合入 main，打 tag v1.2.1
5. 合入后触发自动部署
6. 删除 hotfix/login-crash 分支
```

**使用 Feature Flag 的功能开发：**
```
1. 从 main 创建 feature/new-payment-method
2. 开发功能，使用 Feature Flag 控制可见性（默认关闭）
3. 提交 PR 到 main，合入后功能对用户不可见
4. 功能验证完成后，配置打开 Feature Flag
5. 稳定运行后，移除 Feature Flag 代码
6. 删除 feature/new-payment-method 分支
```

### 不合规示例

```
// 问题1：直接在 main 上提交代码
git checkout main
git commit -m "直接修复"

// 问题2：创建 develop 分支（不符合 GitHub Flow 模型）
git checkout -b develop

// 问题3：创建 release 分支（GitHub Flow 不使用 release 分支）
git checkout -b release/v1.2.0

// 问题4：跳过 Code Review 直接合入
git push origin main

// 问题5：使用 push --force
git push --force origin main

// 问题6：保留已合并的分支不删除
// 分支 feature/old-feature 已合入 main 但仍保留

// 问题7：feature 从非 main 分支创建
git checkout -b feature/new-api develop  // GitHub Flow 中应从 main 创建
```

## 6. 自检清单
- [ ] 分支是否从 `main` 创建
- [ ] 是否通过 PR 流程合入 `main`
- [ ] 是否经过 Code Review
- [ ] 合入前是否同步了 `main` 最新代码
- [ ] 已合并的辅助分支是否已删除
- [ ] 是否避免使用 `develop` / `release` 分支
- [ ] 是否避免 `push --force` 操作
- [ ] 未完成功能是否使用 Feature Flag 控制

## 7. 版本记录
- v1.0 - 新增 GitHub Flow 使用规范
