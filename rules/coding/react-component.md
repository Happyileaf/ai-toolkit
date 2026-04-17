# React组件规范（REACT-001）

## 1. 目标
- 统一 React 组件的目录组织与命名方式，提升可读性、可维护性与协作效率。

## 2. 适用范围
- 适用场景：React 项目中的通用组件、业务组件、页面级组件。
- 不适用场景：非 React 技术栈或脚手架自动生成且不可改动的历史目录。

## 3. 规则内容

### 3.1 组件目录组织
1. 组件必须使用文件夹组织，一个组件对应一个文件夹。
2. 组件文件夹名称必须使用 kebab-case 命名规范。

### 3.2 入口文件规范
1. 每个组件必须使用 `index.tsx` 作为入口文件。
2. 入口文件名固定为 `index.tsx`，不得使用其他入口文件名替代。

### 3.3 组件命名与导出规范
1. 组件名称必须使用 PascalCase 命名规范。
2. 组件必须使用默认导出（`export default`）。

### 3.4 简单组件规范
1. 当组件逻辑简单（结构少、无复杂状态/副作用）时，直接在 `index.tsx` 中完成实现。

### 3.5 复杂组件拆分规范
1. 当组件逻辑复杂时，必须拆分模块。
2. 模块目录包括：`components`、`constants`、`utils`、`hooks`、`types`、`api`。
3. 模块目录名必须使用 kebab-case 命名规范。

## 4. 输出要求
- 目录结构清晰，符合"单组件单文件夹"原则。
- 命名需同时满足：
  - 文件夹：kebab-case
  - 组件名：PascalCase
- 入口文件固定为 `index.tsx` 且默认导出组件。

## 5. 示例

### 合规示例
```text
product-card/
├── index.tsx
├── components/
├── constants/
├── utils/
├── hooks/
├── types/
└── api/
```

```tsx
// product-card/index.tsx
function ProductCard() {
  return <div>Product Card</div>;
}

export default ProductCard;
```

### 不合规示例
```text
ProductCard/
├── main.tsx
└── helper/
```

```tsx
// 问题：组件名不是 PascalCase + 非默认导出
export const productCard = () => <div>Product Card</div>;
```

## 6. 自检清单
- [ ] 是否一个组件对应一个文件夹
- [ ] 组件文件夹是否为 kebab-case
- [ ] 是否使用 `index.tsx` 作为固定入口
- [ ] 组件名是否为 PascalCase
- [ ] 是否使用默认导出
- [ ] 复杂组件是否按模块拆分（components/constants/utils/hooks/types/api）

## 7. 版本记录
- v1.0 - 新增 React 组件规范