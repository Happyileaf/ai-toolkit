# 命名规范（NAMING-001）

## 1. 目标
- 统一项目中的命名风格，提高代码可读性和一致性，降低团队协作成本。

## 2. 适用范围
- 适用场景：项目中所有变量、常量、函数、类、文件、文件夹的命名。
- 不适用场景：第三方库、自动生成的代码、配置文件中的特定字段。

## 3. 规则内容

### 3.1 变量命名规范

#### 3.1.1 普通变量
- 必须使用 `camelCase`（小驼峰）命名。
- 必须见名知义，避免使用无意义缩写。
- 布尔类型变量建议使用 `is`、`has`、`can`、`should` 等前缀。

#### 3.1.2 常量
- 必须使用 `UPPER_SNAKE_CASE`（全大写下划线）命名。
- 必须使用 `const` 声明。

#### 3.1.3 函数命名
- 必须使用 `camelCase` 命名。
- 必须以动词开头，如 `get`、`set`、`fetch`、`handle`、`on`、`render` 等。
- 异步函数建议添加 `async` 后缀或使用 `fetch`、`load` 等动词。

#### 3.1.4 类与接口命名
- 必须使用 `PascalCase`（大驼峰）命名。
- 接口名称建议以 `I` 开头（可选，根据项目约定）。
- 类型别名必须使用 `PascalCase`。

#### 3.1.5 枚举命名
- 必须使用 `PascalCase` 命名。
- 枚举变量名必须以 `Enum` 结尾。
- 枚举属性名与属性值必须一致。

### 3.2 文件命名规范

#### 3.2.1 组件文件
- 必须使用 `kebab-case`（短横线）命名。
- 组件入口文件必须命名为 `index.tsx`。
- 组件文件夹名称与组件功能相关，使用 `kebab-case`。

#### 3.2.2 工具函数文件
- 必须使用 `kebab-case` 命名。
- 文件名必须与导出的主要函数名相关。

#### 3.2.3 类型定义文件
- 必须使用 `kebab-case` 命名。
- 类型文件建议命名为 `types.ts` 或 `interfaces.ts`。

#### 3.2.4 样式文件
- 必须使用 `kebab-case` 命名。
- 样式文件必须与关联的组件文件同名（扩展名不同）。

#### 3.2.5 常量文件
- 必须使用 `kebab-case` 命名。
- 常量文件建议命名为 `constants.ts`。

### 3.3 文件夹命名规范

#### 3.3.1 通用规则
- 必须使用 `kebab-case` 命名。
- 必须使用小写字母。
- 必须使用英文单词，禁止使用拼音。
- 禁止使用特殊字符，仅允许字母、数字和短横线。

#### 3.3.2 组件文件夹
- 必须使用 `kebab-case` 命名。
- 文件夹名称必须体现组件功能。

#### 3.3.3 模块文件夹
- 必须使用 `kebab-case` 命名。
- 常见模块命名：
  - `components` - 组件目录
  - `hooks` - 自定义 Hooks
  - `utils` - 工具函数
  - `constants` - 常量定义
  - `types` - 类型定义
  - `api` - API 接口
  - `assets` - 静态资源
  - `styles` - 样式文件

## 4. 输出要求
- 命名必须使用英文单词，禁止使用拼音。
- 命名必须避免使用保留字和关键字。
- 命名长度建议控制在 2-30 个字符内。

## 5. 示例

### 合规示例

#### 变量命名
```ts
// 普通变量 - camelCase
const userName = 'John';
const isLoading = true;
const hasPermission = false;

// 常量 - UPPER_SNAKE_CASE
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = 'https://api.example.com';

// 函数 - camelCase + 动词开头
function getUserInfo() {}
function handleButtonClick() {}
async function fetchUserData() {}

// 类与接口 - PascalCase
class UserService {}
interface IUserInfo {}
type UserRole = 'admin' | 'user';

// 枚举 - PascalCase + Enum后缀
enum StatusEnum {
  Active = 'Active',
  Inactive = 'Inactive',
}
```

#### 文件命名
```
// 组件文件
user-profile/
  index.tsx
  user-profile.tsx
  user-profile.module.css

// 工具函数文件
date-utils.ts
format-helpers.ts

// 类型定义文件
types.ts
interfaces.ts

// 常量文件
constants.ts
```

#### 文件夹命名
```
src/
  components/
    user-profile/
    order-list/
  hooks/
    use-user-info.ts
  utils/
    date-helpers.ts
  constants/
    index.ts
  types/
    user.ts
    order.ts
  api/
    user-api.ts
```

### 不合规示例

```ts
// 变量命名错误
const UserName = 'John';        // 应使用 camelCase
const user_name = 'John';       // 应使用 camelCase
const loading = true;           // 布尔值建议加 is/has 前缀
const maxRetryCount = 3;        // 常量应使用 UPPER_SNAKE_CASE

// 函数命名错误
function userInfo() {}          // 缺少动词
function GetUser() {}          // 应使用 camelCase

// 文件命名错误
UserProfile.tsx                 // 应使用 kebab-case
user_profile.tsx               // 应使用 kebab-case
UserProfileComponent.tsx       // 应使用 kebab-case

// 文件夹命名错误
UserProfile/                    // 应使用 kebab-case
user_profile/                   // 应使用 kebab-case
Components/                     // 应使用 kebab-case
```

## 6. 自检清单
- [ ] 变量是否使用 camelCase
- [ ] 常量是否使用 UPPER_SNAKE_CASE
- [ ] 函数是否以动词开头
- [ ] 类与接口是否使用 PascalCase
- [ ] 文件是否使用 kebab-case
- [ ] 文件夹是否使用 kebab-case
- [ ] 命名是否见名知义
- [ ] 命名是否使用英文而非拼音

## 7. 版本记录
- v1.0 - 新增命名规范