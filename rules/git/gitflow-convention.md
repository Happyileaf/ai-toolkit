# GitFlow 使用规范（GIT-GITFLOW-001）

## 1. 目标
- 统一团队 GitFlow 工作流使用方式，明确分支角色与流转规则，确保代码集成的有序性和可追溯性。

## 2. 适用范围
- 适用场景：采用 GitFlow 工作流的中大型项目团队协作。
- 不适用场景：个人项目、小型项目（可采用简化版 GitHub Flow）。

## 3. 规则内容

### 3.1 核心分支

#### 3.1.1 main / master
- 必须：始终保持稳定可发布状态。
- 必须：仅接受来自 `release` 和 `hotfix` 分支的合并。
- 禁止：直接在 main 上提交代码。

#### 3.1.2 develop
- 必须：作为日常开发的集成分支，包含最新开发完成的功能。
- 必须：仅接受来自 `feature`、`bugfix`、`refactor` 分支的合并。
- 禁止：直接在 develop 上进行功能开发。

### 3.2 辅助分支

#### 3.2.1 feature 分支
- 必须：从 `develop` 分支创建。
- 必须：开发完成后合并回 `develop` 分支。
- 必须：合并后删除该 feature 分支。
- 建议：一个 feature 分支对应一个功能点。
- 禁止：同时开发多个不相关功能。

#### 3.2.2 bugfix 分支
- 必须：从 `develop` 分支创建。
- 必须：修复完成后合并回 `develop` 分支。
- 必须：合并后删除该 bugfix 分支。

#### 3.2.3 release 分支
- 必须：从 `develop` 分支创建。
- 必须：命名格式为 `release/v<version>`（如 `release/v1.2.0`）。
- 必须：仅允许修复 Bug 和文档更新，禁止新增功能。
- 必须：测试通过后合并至 `main` 和 `develop`。
- 必须：合并至 `main` 时必须打 tag（如 `v1.2.0`）。
- 必须：合并后删除该 release 分支。

#### 3.2.4 hotfix 分支
- 必须：从 `main` 分支创建。
- 必须：命名格式为 `hotfix/v<version>-<description>`（如 `hotfix/v1.2.1-login-error`）。
- 必须：修复完成后合并至 `main` 和 `develop`。
- 必须：合并至 `main` 时必须打 tag（如 `v1.2.1`）。
- 必须：合并后删除该 hotfix 分支。

### 3.3 合入规则

#### 3.3.1 合入方式
- 必须：使用 Merge Request / Pull Request 方式合入，禁止直接 push 合入。
- 必须：MR / PR 必须至少一人 Code Review 通过后方可合入。
- 必须：合入前必须确保目标分支的最新代码已合并至当前分支（避免冲突）。

#### 3.3.2 合入冲突处理
- 必须：由分支创建者负责解决冲突。
- 必须：解决冲突后必须重新运行测试验证。
- 禁止：使用 `push --force` 解决冲突。

#### 3.3.3 合入后操作
- 必须：合入后在远端删除已合并的辅助分支。
- 建议：合入后清理本地对应的分支引用。

### 3.4 分支流转图

```
main ──────────────────────────────────────────── merge from release/hotfix
  │                                              │
  ├── hotfix/v1.2.1-login-error ──────────────── merge back to main + develop
  │
  └─ release/v1.2.0 ──── from develop ────────── merge to main + develop + tag
        │
develop ──────────────────────────────────────── merge from feature/bugfix/refactor
  │
  ├── feature/user-email-register ────────────── merge back to develop
  ├── bugfix/api-timeout-error ───────────────── merge back to develop
  └── refactor/auth-strategy-pattern ─────────── merge back to develop
```

### 3.5 禁止事项
- 禁止直接在 main/develop 上提交代码。
- 禁止跨类型分支合入（如 feature 直接合入 main）。
- 禁止在 release 分支上新增功能。
- 禁止跳过 Code Review 直接合入。
- 禁止使用 `push --force` 操作。
- 禁止保留已合并的辅助分支。

## 4. 输出要求
- 必须严格遵循 GitFlow 分支流转规则。
- 必须通过 MR / PR 流程合入代码。
- 必须在合入 main 时打 tag。

## 5. 示例

### 合规示例

**功能开发流程：**
```
1. 从 develop 创建 feature/user-email-register
2. 在 feature 分支上开发并提交
3. 提交 MR 到 develop，指定 Reviewer
4. Code Review 通过后合入 develop
5. 删除 feature/user-email-register 分支
```

**发布流程：**
```
1. 从 develop 创建 release/v1.2.0
2. 在 release 分支上进行测试和 Bug 修复
3. 测试通过后提交 MR 到 main
4. 合入 main 并打 tag v1.2.0
5. 同步合入 develop
6. 删除 release/v1.2.0 分支
```

**紧急修复流程：**
```
1. 从 main 创建 hotfix/v1.2.1-login-error
2. 在 hotfix 分支上修复并提交
3. 提交 MR 到 main，指定 Reviewer
4. Code Review 通过后合入 main 并打 tag v1.2.1
5. 同步合入 develop
6. 删除 hotfix/v1.2.1-login-error 分支
```

### 不合规示例

```
// 问题1：直接在 main 上提交代码
git checkout main
git commit -m "直接修复"

// 问题2：feature 直接合入 main（绕过 develop）
git checkout main
git merge feature/user-email-register

// 问题3：跳过 Code Review 直接合入
git push origin develop

// 问题4：在 release 分支上新增功能
git checkout release/v1.2.0
git commit -m "feat: 新增功能"

// 问题5：使用 push --force
git push --force origin main

// 问题6：保留已合并的分支不删除
// 分支 feature/old-feature 已合入 develop 但仍保留
```

## 6. 自检清单
- [ ] 分支是否从正确的源分支创建
- [ ] 是否通过 MR / PR 流程合入
- [ ] 是否经过 Code Review
- [ ] 合入目标分支是否正确
- [ ] 合入 main 时是否打 tag
- [ ] 已合并的辅助分支是否已删除
- [ ] 是否避免在 release 分支新增功能
- [ ] 是否避免 push --force 操作

## 7. 版本记录
- v1.0 - 新增 GitFlow 使用规范