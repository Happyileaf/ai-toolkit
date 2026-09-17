# 项目布局

> 全栈应用的目录结构、模块边界、单仓/多仓形态约定。

## 1. 仓库形态

### 1.1 单仓（Monorepo，默认）

适用于中小型团队，前端、后端、共享包在同一仓库。

```text
.
├── apps/
│   ├── web/            # 前端应用
│   └── api/            # 后端应用
├── packages/
│   ├── shared/         # 前后端共享类型、工具
│   ├── ui/             # 共享组件库（如有）
│   └── config/        # 共享配置（eslint、tsconfig 等）
├── docs/
├── .github/workflows/
├── package.json
└── README.md
```

### 1.2 多仓（Polyrepo）

适用于独立演进的团队，每个仓库自带 CI、独立版本。仓库内布局参考单仓的 `apps/<name>` 子目录。

## 2. 前端目录（apps/web）

```text
apps/web/
├── src/
│   ├── pages/          # 路由级页面
│   ├── features/       # 按业务域划分的功能模块
│   │   └── <domain>/
│   │       ├── components/
│   │       ├── hooks/
│   │       ├── api/
│   │       ├── types.ts
│   │       └── index.ts
│   ├── components/     # 跨域通用组件
│   ├── hooks/         # 跨域通用 hooks
│   ├── utils/          # 纯函数工具
│   ├── api/            # API client 与请求封装
│   ├── stores/         # 全局状态
│   ├── routes/         # 路由定义
│   ├── styles/         # 全局样式与设计 token
│   └── app/           # 应用入口、Provider 组装
├── public/
├── tests/
└── tsconfig.json
```

**原则**：
- `features/` 内按业务域自闭包，跨域依赖通过 `index.ts` 显式导出。
- `components/` 只放跨域通用组件，业务组件留在对应 feature 内。
- `utils/` 只放纯函数，禁止放含副作用的代码。

## 3. 后端目录（apps/api）

```text
apps/api/
├── src/
│   ├── modules/        # 按业务域划分的模块
│   │   └── <domain>/
│   │       ├── routes/        # 路由定义
│   │       ├── controllers/    # 请求处理
│   │       ├── services/      # 业务逻辑
│   │       ├── repositories/  # 数据访问
│   │       ├── dto/          # 请求/响应数据结构
│   │       └── index.ts
│   ├── middlewares/
│   ├── guards/         # 鉴权守卫
│   ├── interceptors/
│   ├── pipes/          # 参数校验
│   ├── filters/        # 异常过滤
│   ├── config/         # 配置加载
│   ├── shared/         # 跨模块共享工具
│   └── main.ts
├── prisma/              # Prisma schema 与 migration（如使用）
├── tests/
└── tsconfig.json
```

**原则**：
- 模块按业务域自闭包，禁止跨模块直接 import `repositories`。
- 跨模块通信通过 `services` 显式导出的接口。
- 分层顺序：`routes -> controllers -> services -> repositories`，禁止跨层调用。

## 4. 共享包（packages/）

- `packages/shared/`：前后端共享的 TypeScript 类型、枚举、校验 schema。
- `packages/ui/`：跨应用复用的组件库，必须独立构建。
- `packages/config/`：eslint、prettier、tsconfig 等共享配置。

**原则**：
- 共享包不得反向依赖 `apps/`。
- 共享包之间可依赖，但需避免循环依赖。

## 5. 命名约定

- 目录与文件名：`kebab-case`（如 `user-profile/`、`auth-service.ts`）。
- React 组件文件：`PascalCase`（如 `UserProfile.tsx`）。
- 测试文件：与源文件同目录，`.test.ts` / `.spec.ts` 后缀。
- 类型文件：`types.ts` 或 `*.types.ts`。

## 6. 禁止

- 在 `utils/` 或 `shared/` 放业务逻辑。
- 在 `components/` 放业务专属组件。
- 跨层 import（如 controller 直接 import repository）。
- 在 feature 模块外直接引用其内部文件（必须通过 `index.ts`）。
