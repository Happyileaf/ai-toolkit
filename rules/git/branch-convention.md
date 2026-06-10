# 分支命名规范（GIT-BRANCH-001）

## 1. 目标
- 统一 Git 分支命名规则，提高分支识别度，便于团队协作、分支管理和自动化流程解析。

## 2. 适用范围
- 适用场景：所有项目的 Git 分支命名。
- 不适用场景：仓库初始化时的 main/master 分支。

## 3. 规则内容

### 3.1 分支命名格式

分支命名必须遵循以下格式：

```
<type>/<scope>-<description>
```

#### 3.1.1 type（必填）
- 必须：使用以下预定义类型之一：

| 类型 | 说明 |
|---|---|
| feature | 新功能开发 |
| bugfix | Bug 修复 |
| hotfix | 紧急修复（基于生产分支） |
| refactor | 重构 |
| test | 测试相关 |
| docs | 文档变更 |
| chore | 构建/工具/辅助变更 |
| release | 发布分支 |
| support | 维护/支持分支 |

#### 3.1.2 scope（选填）
- 建议：标明影响范围，如模块名、组件名。
- 格式：使用小写英文，如 `user`、`auth`、`api`。

#### 3.1.3 description（必填）
- 必须：简短描述分支目的。
- 必须：使用小写英文，单词间以 `-` 连接（kebab-case）。
- 禁止：超过 30 个字符。
- 禁止：使用中文或大写字母。
- 禁止：使用模糊描述（如 `update`、`fix`）。

### 3.2 特殊分支命名
- `main` / `master`：主分支，必须保持稳定可发布状态。
- `develop` / `dev`：开发分支，日常开发集成分支。
- `release/<version>`：发布分支，格式为 `release/v1.2.0`。
- `hotfix/<version>-<description>`：紧急修复分支，格式为 `hotfix/v1.2.1-login-error`。

### 3.3 禁止事项
- 禁止使用大写字母。
- 禁止使用中文。
- 禁止使用空格（必须用 `-` 替代）。
- 禁止使用下划线 `_`。
- 禁止以数字开头。
- 禁止创建无 type 前缀的分支。
- 禁止在分支名中包含个人姓名或昵称。

## 4. 输出要求
- 分支名必须使用 `<type>/<scope>-<description>` 格式。
- description 必须使用小写英文 kebab-case。
- 分支名总长度不得超过 60 个字符。

## 5. 示例

### 合规示例

```
feature/user-email-register
bugfix/api-timeout-error
hotfix/v1.2.1-login-error
refactor/auth-strategy-pattern
test/user-integration-test
docs/api-usage-guide
chore/upgrade-deps
release/v2.0.0
```

### 不合规示例

```
// 问题1：缺少 type 前缀
user-email-register

// 问题2：使用大写字母
feature/UserEmailRegister

// 问题3：使用中文
feature/用户注册功能

// 问题4：使用空格
feature/user email register

// 问题5：使用下划线
feature/user_email_register

// 问题6：description 模糊
feature/update

// 问题7：包含个人姓名
feature/john-new-login

// 问题8：description 过长超过30字符
feature/user-this-is-a-very-long-description-that-exceeds-limit
```

## 6. 自检清单
- [ ] 是否包含 type 前缀且为预定义类型
- [ ] scope 是否使用小写英文
- [ ] description 是否使用小写英文 kebab-case
- [ ] description 是否不超过 30 字符
- [ ] 是否避免大写、中文、空格、下划线
- [ ] 分支名总长度是否不超过 60 字符

## 7. 版本记录
- v1.0 - 新增分支命名规范