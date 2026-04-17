# 枚举定义规范（ENUM-001）

## 1. 目标
- 统一枚举相关代码的生成方式，保证 `Enum`、名称映射 `LabelMap`、选项数据源 `Options` 三者语义一致、命名一致、顺序一致。

## 2. 适用范围
- 适用场景：TypeScript/JavaScript 中需要定义业务枚举并提供下拉选项数据源的场景。
- 不适用场景：仅需临时常量且不需要展示文案与选项数据源的场景。

## 3. 规则内容

### 3.1 枚举值定义规范
- 生成枚举时，必须同时生成以下 3 个变量：
  - 枚举变量（`XXXEnum`）
  - 名称映射（`XXXLabelMap`）
  - 选项数据源（`XXXOptions`）
- 命名派生规则：
  - 当枚举变量名为 `XXXEnum` 时：
    - 名称映射必须命名为 `XXXLabelMap`
    - 选项数据源必须命名为 `XXXOptions`

### 3.2 枚举变量规范
1. 枚举变量名、枚举属性名必须见名知义，并贴合业务语义。
2. 枚举属性名与属性值必须保持一致，且都使用字符串。
3. 命名使用 PascalCase。
4. 枚举声明与每个枚举属性都必须使用多行注释，注释内容为中文解释。

### 3.3 名称Map规范
1. 名称Map变量名必须为 `XXXLabelMap`。
2. 名称Map的属性键必须与枚举属性一致（推荐使用 `[XXXEnum.属性名]`）。
3. 名称Map的属性值必须为该属性的中文解释。
4. 名称Map声明与每个属性都必须使用多行注释，注释内容为中文解释。

### 3.4 选项数据源规范
1. 选项数据源变量名必须为 `XXXOptions`。
2. 选项数据源必须是数组。
3. 选项数据源必须由枚举和名称Map组合生成。
4. 数组每一项必须是对象，且仅包含 `label`、`value` 两个属性。
5. `label` 必须是枚举属性的中文解释（来自 `XXXLabelMap`）。
6. `value` 必须是枚举属性值（来自 `XXXEnum`）。
7. 选项顺序必须与枚举属性定义顺序一致。

## 4. 输出要求
- 输出语言：TypeScript。
- 输出结构必须按以下顺序：
  1. `XXXEnum`
  2. `XXXLabelMap`
  3. `XXXOptions`
- 注释必须为中文多行注释（`/** ... */`）。

## 5. 示例

### 合规示例
```ts
/**
 * SPU管理枚举
 */
export enum SPUManagementEnum {
  /**
   * SKU
   */
  SKU = 'SKU',
}

/**
 * SPU管理名称Map
 */
export const SPUManagementLabelMap = {
  /**
   * SKU
   */
  [SPUManagementEnum.SKU]: 'SKU',
};

/**
 * SPU管理选项数据源
 */
export const SPUManagementOptions = [
  {
    label: SPUManagementLabelMap[SPUManagementEnum.SKU],
    value: SPUManagementEnum.SKU,
  },
];
```

### 不合规示例
```ts
// 问题1：名称Map命名错误（应为 SPUManagementLabelMap）
// 问题2：属性值与属性名不一致（Sku !== SKU）
// 问题3：未使用多行中文注释
export enum SPUManagementEnum {
  SKU = 'Sku',
}

export const SPUManagementMap = {
  [SPUManagementEnum.SKU]: 'SKU',
}
```

## 6. 自检清单
- [ ] 是否同时生成了 `XXXEnum`、`XXXLabelMap`、`XXXOptions`
- [ ] 枚举属性名与属性值是否一致且均为字符串
- [ ] 是否全部使用 PascalCase 命名
- [ ] 枚举与名称Map是否都使用了中文多行注释
- [ ] `Options` 是否只包含 `label` 与 `value`
- [ ] `Options` 顺序是否与枚举定义顺序一致

## 7. 版本记录
- v1.0 - 新增枚举定义规范