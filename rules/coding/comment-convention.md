# 注释规范（COMMENT-001）

## 1. 目标
- 统一代码注释风格，提高代码可读性和可维护性，便于团队协作和代码审查。

## 2. 适用范围
- 适用场景：TypeScript/JavaScript 项目中所有变量、常量、函数、类、接口、类型、枚举的注释。
- 不适用场景：第三方库代码、自动生成的代码、配置文件。

## 3. 规则内容

### 3.1 变量注释规范

#### 3.1.1 普通变量
- 必须使用多行注释（`/** ... */`）。
- 注释内容必须说明变量的用途或含义。
- 注释必须位于变量声明上方。

#### 3.1.2 常量
- 必须使用多行注释（`/** ... */`）。
- 注释内容必须说明常量的用途和含义。
- 注释必须位于常量声明上方。

#### 3.1.3 对象属性
- 必须使用多行注释（`/** ... */`）。
- 注释必须位于属性上方或行尾（推荐上方）。
- 注释内容必须说明属性的用途。

### 3.2 函数注释规范

#### 3.2.1 函数声明
- 必须使用 JSDoc 格式的多行注释（`/** ... */`）。
- 注释必须位于函数声明上方。
- 注释必须包含以下内容：
  - 函数功能描述
  - 空行
  - `@description` - 详细描述
  - `@param` - 参数说明（如有参数）
  - `@returns` - 返回值说明（如有返回值）
  - `@throws` - 异常说明（如可能抛出异常）
  - `@example` - 使用示例

#### 3.2.2 参数说明
- 每个参数必须使用 `@param` 标注。
- 参数说明格式：`@param {类型} 参数名 - 参数说明`。
- 对象参数的属性必须使用 `@param` 嵌套说明。

#### 3.2.3 返回值说明
- 有返回值的函数必须使用 `@returns` 标注。
- 返回值说明格式：`@returns {类型} 返回值说明`。

### 3.3 类与接口注释规范

#### 3.3.1 类注释
- 必须使用多行注释（`/** ... */`）。
- 注释必须位于类声明上方。
- 注释内容必须说明类的用途。

#### 3.3.2 接口注释
- 必须使用多行注释（`/** ... */`）。
- 注释必须位于接口声明上方。
- 接口属性必须逐个添加注释。

#### 3.3.3 类型别名注释
- 必须使用多行注释（`/** ... */`）。
- 注释必须位于类型声明上方。

### 3.4 枚举注释规范

#### 3.4.1 枚举声明注释
- 必须使用多行注释（`/** ... */`）。
- 注释必须位于枚举声明上方。
- 注释内容必须说明枚举的用途。

#### 3.4.2 枚举属性注释
- 必须使用多行注释（`/** ... */`）。
- 注释必须位于枚举属性上方。
- 注释内容必须说明该属性的含义。

### 3.5 禁止事项
- 禁止使用单行注释（`//`）作为正式文档注释。
- 禁止注释与代码不一致。
- 禁止无意义的注释（如重复代码含义）。
- 禁止注释掉的代码保留在代码库中。

## 4. 输出要求
- 注释必须使用中文。
- 注释必须使用多行注释格式（`/** ... */`）。
- 注释必须简洁明了，避免冗余。

## 5. 示例

### 合规示例

#### 变量注释
```ts
/** 用户名称 */
const userName = 'John';

/** 最大重试次数 */
const MAX_RETRY_COUNT = 3;

/** 用户信息对象 */
const userInfo = {
  /** 用户ID */
  id: 1,
  /** 用户名称 */
  name: 'John',
  /** 用户年龄 */
  age: 25,
};
```

#### 函数注释
```ts
/**
 * 获取用户信息
 *
 * @description 根据用户ID获取用户详细信息
 * @param userId - 用户ID
 * @returns 用户信息对象
 * @example
 * const user = getUserInfo(1);
 * console.log(user.name);
 */
function getUserInfo(userId: number): UserInfo {
  // ...
}

/**
 * 创建新用户
 *
 * @description 创建一个新的用户账号
 * @param options - 创建选项
 * @param options.name - 用户名称
 * @param options.age - 用户年龄
 * @returns 创建的用户对象
 * @throws {Error} 当名称为空时抛出异常
 * @example
 * const user = createUser({ name: 'John', age: 25 });
 */
function createUser(options: { name: string; age: number }): User {
  // ...
}

/**
 * 异步获取用户列表
 *
 * @description 分页获取用户列表数据
 * @param page - 页码
 * @param pageSize - 每页数量
 * @returns 用户列表
 * @example
 * const users = await fetchUserList(1, 10);
 */
async function fetchUserList(page: number, pageSize: number): Promise<User[]> {
  // ...
}
```

#### 类与接口注释
```ts
/**
 * 用户服务类
 * 用于处理用户相关的业务逻辑
 */
class UserService {
  /** 用户仓库实例 */
  private userRepository: UserRepository;

  /**
   * 获取用户详情
   *
   * @description 根据用户ID获取用户详细信息
   * @param userId - 用户ID
   * @returns 用户详情
   * @example
   * const userService = new UserService();
   * const userDetail = userService.getUserDetail(1);
   */
  getUserDetail(userId: number): UserDetail {
    // ...
  }
}

/**
 * 用户信息接口
 */
interface IUserInfo {
  /** 用户ID */
  id: number;
  /** 用户名称 */
  name: string;
  /** 用户邮箱 */
  email: string;
}

/**
 * 用户角色类型
 */
type UserRole = 'admin' | 'user' | 'guest';
```

#### 枚举注释
```ts
/**
 * 用户状态枚举
 */
enum UserStatusEnum {
  /** 激活状态 */
  Active = 'Active',
  /** 未激活状态 */
  Inactive = 'Inactive',
  /** 已禁用状态 */
  Disabled = 'Disabled',
}

/**
 * 用户状态名称映射
 */
const UserStatusLabelMap = {
  /** 激活 */
  [UserStatusEnum.Active]: '激活',
  /** 未激活 */
  [UserStatusEnum.Inactive]: '未激活',
  /** 已禁用 */
  [UserStatusEnum.Disabled]: '已禁用',
};
```

### 不合规示例

```ts
// 问题1：使用单行注释
// 用户名称
const userName = 'John';

// 问题2：注释与代码不一致
/** 用户年龄 */
const userName = 'John';

// 问题3：缺少参数说明
/**
 * 获取用户信息
 */
function getUserInfo(userId: number): UserInfo {
  // ...
}

// 问题4：缺少 @description
/**
 * 获取用户信息
 * @param userId - 用户ID
 * @returns 用户信息对象
 */
function getUserInfo(userId: number): UserInfo {
  // ...
}

// 问题5：缺少返回值说明
/**
 * 创建用户
 * @param name - 用户名称
 */
function createUser(name: string): User {
  // ...
}

// 问题6：缺少 @example
/**
 * 获取用户信息
 *
 * @description 根据用户ID获取用户详细信息
 * @param userId - 用户ID
 * @returns 用户信息对象
 */
function getUserInfo(userId: number): UserInfo {
  // ...
}

// 问题7：枚举属性缺少注释
/**
 * 用户状态枚举
 */
enum UserStatusEnum {
  Active = 'Active',
  Inactive = 'Inactive',
}

// 问题8：无意义注释
/** 设置 name 为 name */
function setName(name: string) {
  this.name = name;
}
```

## 6. 自检清单
- [ ] 变量是否使用多行注释
- [ ] 函数是否使用 JSDoc 格式注释
- [ ] 函数是否有 `@description` 详细描述
- [ ] 函数参数是否都有 `@param` 说明
- [ ] 函数返回值是否有 `@returns` 说明
- [ ] 函数是否有 `@example` 使用示例
- [ ] 类和接口是否都有注释
- [ ] 接口属性是否逐个添加注释
- [ ] 枚举声明和属性是否都有注释
- [ ] 注释是否使用中文
- [ ] 注释是否与代码保持一致

## 7. 版本记录
- v1.0 - 新增注释规范