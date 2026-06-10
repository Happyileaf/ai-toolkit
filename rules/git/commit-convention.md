# Commit 规范（GIT-COMMIT-001）

## 1. 目标
- 统一 Git Commit Message 格式，提高提交历史可读性，便于代码审查、版本追踪和自动化工具解析。

## 2. 适用范围
- 适用场景：所有项目的 Git Commit Message 编写。
- 不适用场景：初始仓库初始化提交（允许简短描述）。

## 3. 规则内容

### 3.1 Commit Message 格式

Commit Message 必须遵循以下结构：

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### 3.1.1 type（必填）
- 必须：使用以下预定义类型之一：

| 类型 | 说明 |
|---|---|
| feat | 新功能 |
| fix | 修复 Bug |
| docs | 文档变更 |
| style | 代码格式调整（不影响逻辑） |
| refactor | 重构（既非新功能也非修复） |
| perf | 性能优化 |
| test | 添加或修改测试 |
| chore | 构建工具或辅助工具变更 |
| ci | CI/CD 配置变更 |
| revert | 回滚提交 |

- 禁止：使用非预定义类型或自定义类型。

#### 3.1.2 scope（选填）
- 建议：标明影响范围，如模块名、包名、组件名。
- 格式：使用小写英文，如 `user`、`auth`、`api`。
- 多个范围时使用 `/` 分隔，如 `user/api`。

#### 3.1.3 subject（必填）
- 必须：简短描述本次变更目的。
- 必须：使用中文。
- 禁止：超过 50 个字符。
- 禁止：以句号结尾。
- 禁止：使用模糊描述（如"修改代码"、"更新文件"）。

#### 3.1.4 body（选填）
- 建议：详细描述变更原因、变更内容和影响范围。
- 必须：使用中文。
- 建议：与 subject 之间空一行。

#### 3.1.5 footer（选填）
- 必须：当存在关联 Issue 时，使用 `Closes #<issue-id>` 或 `Fixes #<issue-id>` 标注。
- 必须：当为回滚提交时，使用 `Reverts <commit-hash>` 标注。
- 建议：标注 BREAKING CHANGE 时，以 `BREAKING CHANGE:` 开头，后跟详细说明。

### 3.2 禁止事项
- 禁止提交无意义的 Commit Message（如 `update`、`fix bug`、`修改`）。
- 禁止在一次提交中混合多个不相关的变更。
- 禁止在 Commit Message 中包含敏感信息（密码、密钥等）。
- 禁止使用 emoji 或特殊符号。
- 禁止省略 type 前缀。

## 4. 输出要求
- Commit Message 必须遵循 `<type>(<scope>): <subject>` 格式。
- subject 必须使用中文，简明准确。
- body 和 footer 如有则必须使用中文。

## 5. 示例

### 合规示例

```
feat(user): 新增用户注册功能

添加邮箱注册和手机号注册两种方式，
支持注册成功后自动登录。

Closes #123
```

```
fix(api): 修复接口超时问题

当请求并发数超过 100 时，接口返回 503 错误。
原因是连接池配置未根据并发量动态调整。

Fixes #456
```

```
refactor(auth): 重构认证模块为策略模式

将原有的 if-else 认证逻辑重构为策略模式，
便于后续扩展新的认证方式。
```

```
chore(deps): 升级依赖版本至最新稳定版
```

### 不合规示例

```
// 问题1：缺少 type 前缀
修复了一个bug

// 问题2：subject 模糊无意义
update

// 问题3：subject 超过 50 字符
feat(user): 新增了一个非常长的描述导致超过50个字符限制的提交信息

// 问题4：混合多个不相关变更
feat: 新增功能A并修复BugB还重构了模块C

// 问题5：包含敏感信息
fix: 修复数据库连接，密码改为 admin123
```

## 6. 自检清单
- [ ] 是否包含 type 前缀且为预定义类型
- [ ] scope 是否使用小写英文
- [ ] subject 是否简明准确且不超过 50 字符
- [ ] subject 是否使用中文
- [ ] body 是否与 subject 之间有空行
- [ ] 是否关联了相关 Issue
- [ ] 是否避免混合不相关变更
- [ ] 是否避免敏感信息

## 7. 版本记录
- v1.0 - 新增 Commit 规范