---
name: git-branch-name-generator
description: 根据用户提供的需求信息生成 Git Branch Name。支持多套预置命名规范、用户自定义规范、语义提炼及灵活的 Code/LLM 处理方式。当用户要求生成、起一个 Git 分支名称，或切换/自定义分支命名规范时使用。只生成名称，不创建分支、不执行 Git 命令。
---

# Git Branch Name Generator

## 1. Skill 目标

根据用户提供的需求信息，按照指定的命名规范生成符合要求的 Git Branch Name。

Skill 内置多套 Naming Presets，用户可以在对话中选择预置规范，也可以直接描述新的命名规范。

Skill 负责理解需求、提取必要信息、执行语义处理、组装分支名称，并验证最终结果。

## 2. 核心原则

### 2.1 规范驱动

所有分支名称的生成都由 Naming Configuration 驱动。

Skill 不预设固定的字段结构，也不预设某个字段必须由 Code 或 LLM 处理。

每个字段的数据来源和处理方式由对应的 Naming Configuration 决定。

### 2.2 多规范支持

Skill 内置多个 Naming Presets。

用户可以：
- 直接使用默认规范。
- 选择指定的预置规范。
- 在对话中临时指定新的命名规范。
- 修改当前使用的命名规范。

### 2.3 Code 与 LLM 分工

根据处理任务的性质决定执行方式：

- Code：负责确定性、可重复的处理任务。
- LLM：负责需要语义理解、推理、提炼或分类的任务。

LLM 只负责配置指定的语义处理任务，不负责最终完整分支名称的组装。

### 2.4 简单可维护

命名规范发生变化时，优先直接修改 Skill 中的 Naming Configuration 或相关代码。

不构建复杂的通用规则引擎、动态插件系统或自定义 DSL。

### 2.5 只生成，不执行

Skill 只负责生成 Git Branch Name。

不创建 Git Branch，不执行 Git 命令，也不修改仓库内容。

---

## 3. 命名规范管理

### 3.1 Naming Presets

Skill 内置以下 Naming Presets，配置位于 [`presets.mjs`](./presets.mjs)：

| Preset | 说明 | 示例 |
|---|---|---|
| standard | 标准规范：类型/日期-需求编号-英文描述（默认启用） | feature/20261102-123-add-user-login |
| conventional | Conventional 风格：type/英文描述 | feat/add-user-login |
| gitflow | GitFlow 风格：feature/英文描述 | feature/add-user-login |
| simple | 简洁命名规范：仅英文描述 | add-user-login |

不同 Preset 可以拥有不同的：
- 字段定义
- 数据来源
- Processor
- Template
- 校验规则

不要求所有 Preset 使用相同的字段结构。

### 3.2 默认规范

Default Preset 为 `standard`（由 `presets.mjs` 中的 `DEFAULT_PRESET` 记录，preset 本身用语义化名称而非 `default`）。

当用户没有指定命名规范，也没有提供其他有效的配置覆盖时，直接使用 Default Preset。

不得因为用户没有指定规范而额外询问用户。

### 3.3 用户选择预置规范

用户可以通过自然语言选择预置规范。

例如：

- 使用 Conventional 规范。
- 切换到 GitFlow。
- 这次使用简洁格式。

识别用户意图并选择对应的 Preset。预设名称关键词映射：

| 用户表达 | Preset |
|---|---|
| 默认、标准、standard、default | standard |
| conventional、Conventional、规范提交风格 | conventional |
| gitflow、GitFlow、标准 git 流 | gitflow |
| simple、简洁、简短 | simple |

如果用户指定的规范名称不明确，才需要进一步确认。

### 3.4 用户自定义规范

用户可以直接通过自然语言描述新的命名规范。

例如：

「分支名称使用 feat/需求编号-英文描述 的格式，英文描述最多 8 个单词。」

应根据用户描述生成对应的 Naming Configuration，并应用到当前请求或当前对话。

自定义规范不要求写入 Skill 文件，也不要求永久保存。

如果用户的描述与已有 Preset 不同，应以用户明确指定的规范为准。

---

## 4. 配置生命周期与优先级

### 4.1 Default Configuration

Skill 内置的默认配置。

### 4.2 Session Configuration

用户在当前对话中指定的配置。例如：「接下来都使用 GitFlow 规范。」

该配置在当前对话持续生效，直到用户修改、切换或重置。

### 4.3 Request Configuration

用户在当前请求中指定的配置。例如：「这次使用 Conventional 格式。」

该配置只对当前请求生效，不影响 Session Configuration。

### 4.4 配置优先级

从高到低：

1. Request Configuration
2. Session Configuration
3. Preset Selection
4. Default Configuration

用户没有明确指定生命周期时，根据表达判断；无法判断且会影响后续使用时，再向用户确认。

### 4.5 局部覆盖与完整覆盖

- 完整覆盖：用户提供一套新的完整命名规范，替换当前使用的规范。
- 局部覆盖：用户只修改当前规范中的某些部分（日期格式、单词上限、分隔符、新增需求编号等），其余配置保持不变，不应意外丢失其他配置。

---

## 5. Naming Configuration

内置配置使用带注释的 ESM 模块维护（[`presets.mjs`](./presets.mjs)），脚本直接 import；用户在对话中提供的自定义规范仍以等价的 JSON 结构通过 `config` 传入。每个 preset 只声明「由哪几个字段组成、每个字段的性质、枚举范围与拼接模板」，不维护同义词映射表。

### 5.1 基本结构

单个 preset 的 JSON 结构（`presets.mjs` 中为等价的带注释写法）：

```json
{
  "max_length": 64,
  "fields": {
    "type": {
      "source": "input",
      "required": true,
      "processor": {
        "type": "llm",
        "operation": "enum-select",
        "options": { "values": { "feature": "新功能与需求开发", "fix": "缺陷修复" } }
      },
      "normalize": "slug"
    },
    "id": {
      "source": "input",
      "required": true,
      "processor": { "type": "passthrough" },
      "normalize": "token"
    },
    "description": {
      "source": "input",
      "required": true,
      "processor": { "type": "llm", "operation": "semantic-slug", "options": { "language": "en", "max_words": 10 } },
      "normalize": "slug"
    },
    "date": {
      "source": "datetime",
      "required": true,
      "processor": { "type": "transform", "format": "%Y%m%d" }
    }
  },
  "template": "{type}/{date}-{id}-{description}"
}
```

`options.values` 声明该字段合法值的枚举范围：对象形式时 key 为合法值、value 为值的性质说明；也支持字符串数组。近义词归并由 LLM 按说明完成，脚本只校验结果是否落在枚举内。

### 5.2 Fields

每个字段至少需要定义：

- `source`：字段的数据来源。
- `processor`：字段的处理方式（缺省视为 `passthrough`）。
- `required`：是否为必需字段（缺省为 `false`）。
- `normalize`：Code 最终规范化模式，可取 `slug`（默认，小写且非字母数字转为连字符）、`token`（保留大小写）、`none`。

字段名称由 Naming Configuration 自行定义，不预设固定字段。

### 5.3 Source

| Source | 说明 |
|---|---|
| input | 从用户输入中提取 |
| datetime | 从当前日期或时间获取（须配合 transform processor 与 format） |
| static | 使用 processor.value 中定义的固定值 |

### 5.4 Processor

#### Code Processor

| Processor | 说明 |
|---|---|
| passthrough | 原样传递 |
| transform | 执行确定性的格式转换；第一版仅支持 datetime 来源的日期格式（`%Y %m %d %H %M %S`） |

#### LLM Processor

用于需要语义理解的处理任务，可应用于任何字段。支持预置 operation 或自定义 instruction：

```json
{ "type": "llm", "operation": "semantic-slug", "options": { "language": "en", "max_words": 10 } }
```

```json
{
  "type": "llm",
  "operation": "enum-select",
  "options": { "values": { "feature": "新功能与需求开发", "fix": "缺陷修复" } }
}
```

```json
{ "type": "llm", "instruction": "根据需求内容识别核心模块，只返回简短的英文模块名称" }
```

预置 operation：

| Operation | 说明 | options |
|---|---|---|
| semantic-slug | 将需求提炼为简洁、准确的英文 kebab-case 标识（见第 7 节） | `language`、`max_words` |
| enum-select | 按枚举的性质说明，将用户表达归类为枚举中的某个合法值，只返回该值本身 | `values`：对象（值→性质说明）或字符串数组 |

归类示例：用户说「功能 / 需求 / 优化 / feat」时，按枚举说明归为 `feature`（GitFlow 范围）或 `feat`（Conventional 范围）；「紧急修复」在 GitFlow 范围归为 `hotfix`，在 Conventional 范围归为 `fix`。无法在枚举中找到合理归属时，先向用户确认，不猜测返回范围外的值——脚本会以 `INVALID_ENUM_VALUE` 拒绝范围外结果。

第一版只实现实际使用到的处理任务，不提前实现所有可能的语义操作。

### 5.5 Template

Template 引用已处理完成的字段并按顺序组装，例如：

```text
{type}/{date}-{id}-{description}
```

最终组装由脚本完成，不交给 LLM 自由生成。可选字段（`required: false`）为空时，脚本会折叠因此产生的连续连字符、去除片段首尾连字符并丢弃空路径片段。

---

## 6. 输入信息处理

### 6.1 自动识别

根据当前生效的 Naming Configuration 识别所需信息（需求编号、需求描述、需求类型、模块、日期等），不得假定所有规范需要相同输入。

### 6.2 缺失信息处理

必需字段无法从输入提取、也无法通过其 Source 获取时，应先询问用户，不输出不完整结果。

可选字段按配置跳过。不得反复询问已经能够合理推断的信息。

### 6.3 信息提取与语义处理

- 确定性提取或转换由脚本完成。
- 需要理解上下文的字段由 LLM 完成。
- 语义不明确时优先结合上下文判断，必要时询问用户。

---

## 7. LLM 语义处理

### 7.1 职责

LLM 只负责配置中指定的语义任务：语义提炼、翻译、摘要、分类、模块识别、关键词提取等，不负责最终完整组装。

### 7.2 Semantic Slug

目标不是逐字翻译，而是理解需求核心目的，提炼简洁、准确的英文标识。

输入：「增加用户登录失败次数限制，防止暴力破解。」
输出：`add-login-attempt-limit`

要求：

- 保留需求核心含义。
- 优先使用简洁、明确的英文表达。
- 避免冗余词汇。
- 全小写，单词之间使用单个连字符，仅包含字母、数字、连字符。
- 不进行机械逐字翻译。
- 输出仅包含 slug 本身，不带解释、代码块或标点。

### 7.3 Enum Select

按 `options.values` 声明的枚举范围归类：

- 阅读每个枚举值附带的性质说明，理解用户表达后选择最贴切的一个值。
- 输入可以是中英文近义词、口语化描述（如「做个需求」「线上出 bug 了要紧急修」），输出必须且只能是枚举中的某个 key 本身，不带解释或标点。
- 只在枚举范围内选择；没有合理归属、或在多个值之间存在实质歧义时，先向用户确认，不返回范围外的值。
- 枚举范围以当前生效配置为准。例如修复类需求：GitFlow 范围在 `bugfix` / `hotfix` 间区分，Conventional 范围统一归为 `fix`。

### 7.4 长度约束

默认最多 10 个单词，具体以配置 `options.max_words` 为准。

如果生成结果超过限制：
1. 将结果交给 LLM 重新提炼。
2. 保留核心语义。
3. 再次检查单词数量。
4. 满足限制后交给脚本处理。

不得直接通过代码机械截断单词。

---

## 8. Code 处理与最终组装

确定性处理统一由 [`scripts/generate-branch-name.mjs`](./scripts/generate-branch-name.mjs) 完成：

1. 根据 Source 获取字段数据。
2. 执行 Code Processor（passthrough / transform）。
3. 接收 LLM Processor 的处理结果（enum-select / semantic-slug 等，由调用方通过 `llm_values` 传入）。
4. 对字段进行格式规范化（slug / token / none）。
5. 根据 Template 组装完整分支名称并清洗可选字段产生的多余分隔符。
6. 执行最终格式与枚举范围校验。

### 脚本契约

输入为 JSON（标准输入或第一个命令行参数）：

```json
{
  "preset": "standard",
  "config": null,
  "inputs": { "type": "功能", "id": "123", "description": "增加用户登录功能" },
  "llm_values": { "type": "feature", "description": "add-user-login" },
  "now": "2026-11-02"
}
```

字段说明：

- `preset`：预置规范名称，缺省使用 `DEFAULT_PRESET` 指向的 preset（当前为 `standard`）。
- `config`：完整的自定义 Naming Configuration，提供时优先于 preset（用于用户自定义/局部覆盖后的配置）。
- `inputs`：从用户输入提取的字段原始值（source 为 input 的字段），如类型的原始表达、需求原文。
- `llm_values`：LLM 已完成语义处理的字段值（processor.type 为 llm 的字段），如 enum-select 的归类结果、semantic-slug 的英文 slug。
- `now`：可选，ISO 或 `YYYY-MM-DD`，用于确定性的日期字段，缺省为系统当前时间。

成功输出：

```json
{
  "ok": true,
  "preset": "standard",
  "branch": "feature/20261102-123-add-user-login",
  "fields": { "type": "feature", "date": "20261102", "id": "123", "description": "add-user-login" }
}
```

失败输出（退出码为 1）：

```json
{
  "ok": false,
  "errors": [ { "code": "MISSING_REQUIRED_FIELD", "field": "id", "message": "缺少必需字段: id" } ]
}
```

常见错误码：

| code | 含义 | 调用方处理 |
|---|---|---|
| MISSING_REQUIRED_FIELD | 缺少必需 input 字段（用户未提供原始输入） | 向用户追问该字段 |
| MISSING_LLM_VALUE | 已有原始输入，但字段需要先执行 LLM 语义处理 | 先执行 enum-select / semantic-slug 等处理，再通过 llm_values 传入重试 |
| INVALID_ENUM_VALUE | LLM 归类结果不在 options.values 枚举范围内 | 交回 LLM 重新归类，或请用户确认后重试 |
| WORD_LIMIT_EXCEEDED | 描述超过 max_words | 交回 LLM 重新提炼后重试，禁止机械截断 |
| INVALID_CHARACTER / INVALID_SEPARATOR / TOO_LONG | 最终名称不合法或过长 | 修正对应字段后重新组装 |
| UNKNOWN_PRESET / INVALID_CONFIG | 配置问题 | 修正配置后重试 |

调用示例：

```bash
echo '{"preset":"standard","inputs":{"type":"功能","id":"123","description":"增加用户登录功能"},"llm_values":{"type":"feature","description":"add-user-login"}}' \
  | node skills/git-branch-name-generator/scripts/generate-branch-name.mjs
```

---

## 9. 分支名称校验

脚本执行的校验：

- 所有必需字段非空。
- Template 引用的字段均已定义。
- 最终名称仅包含字母、数字、`/`、`.`、`_`、`-`，且以字母或数字开头。
- 不存在连续 `/` 或 `-`、首尾 `/` 或 `-`、`/-`、`-/`。
- 不包含 `..`，不以 `.` 或 `.lock` 结尾。
- 长度不超过配置的 `max_length`（默认 64）。
- 声明了 `options.values` 的字段，最终值必须在枚举范围内。
- LLM 字段的单词数不超过 `options.max_words`。

校验失败时，优先修正对应字段或重新执行相关处理，不直接输出无效结果。

---

## 10. 执行流程

每次生成分支名称时：

1. 读取当前生效的 Naming Configuration（Request > Session > Preset > Default）。
2. 判断用户是否切换 Preset、提供新规范或局部覆盖；局部覆盖基于当前配置合并。
3. 根据配置识别需要的输入字段。
4. 提取用户已提供的信息。
5. 对缺失的必需信息进行必要询问。
6. 对 processor.type 为 `llm` 的字段执行语义处理：enum-select 字段按枚举性质归类，semantic-slug 字段提炼英文标识；超长则重新提炼直至满足 `max_words`。
7. 调用 `generate-branch-name.mjs`，传入 `preset` 或完整 `config`、`inputs`（含原始表达）、`llm_values`（归类/提炼结果）、`now`。
8. 若返回错误：`MISSING_REQUIRED_FIELD` 向用户追问，`MISSING_LLM_VALUE`/`INVALID_ENUM_VALUE`/`WORD_LIMIT_EXCEEDED` 重新执行对应 LLM 步骤（枚举无法归类时向用户确认），其他错误修正后重试。
9. 校验通过后输出生成结果。

---

## 11. 用户交互

- 用户没有指定规范：直接使用 Default Preset，不额外询问。
- 用户选择预置规范：切换到对应 Preset，根据表达判断作用范围（本次 vs 后续持续）。
- 用户指定新规范：理解描述生成 Naming Configuration，缺少必要规则时再询问。
- 用户修改规范：局部覆盖时保留其他配置，不整体重置。
- 用户重置规范：清除对话中的覆盖，恢复 Default Preset。
- 连续生成多个名称时持续使用当前 Session Configuration；Request Configuration 不影响后续请求。

## 12. 输出格式

默认简洁输出最终分支名称：

```text
feature/20261102-123-add-user-login
```

可在名称下用一行小字补充当前使用的 Preset（例如 `（standard 规范）`），除非用户明确要求其他格式。

缺少必需信息时先询问，不输出不完整结果。用户要求生成多个名称时，按相同规范分别输出。

## 13. 扩展与维护

增加或修改命名规范时，优先修改 [`presets.mjs`](./presets.mjs)：枚举、字段常量、Source、Processor、Template、校验规则。文件内含维护注释：新增类型值改对应枚举对象；字段统一定义为字段常量（如 `dateField`、`idField`、`descriptionField`）供各 preset 引用组合，新增 preset 复制最接近的一个、复用已有字段常量后改 fields/template，不在 preset 内重复写字段定义。

需要新的确定性处理时，再修改 `generate-branch-name.mjs`；需要新的语义任务时，通过 LLM Processor 的 `operation` 或 `instruction` 描述，并在本文件补充执行说明。

不为增加一套规范引入复杂的通用规则解析系统。

## 14. 第一版范围

包含：
- 多套预置命名规范与 Default Preset。
- 用户选择 Preset、用户自定义规范。
- Session Configuration 与 Request Configuration。
- 局部覆盖与完整覆盖。
- 基于配置的字段提取、Code Processor、LLM Processor、Template 组装、最终格式校验。

暂不包含：
- 创建 Git Branch、执行 Git 命令、自动提交代码。
- 项目级配置文件、远程配置同步、永久保存用户自定义规范。
- 复杂规则引擎、动态插件系统、通用工作流编排。

## 15. 最终设计思想

```text
Naming Presets / User Configuration
→ Input Extraction
→ Field Processing（Code / LLM）
→ Code Composition
→ Validation
→ Git Branch Name
```

- Naming Configuration 决定生成规则。
- Code 负责确定性处理和最终组装。
- LLM 负责配置指定的语义理解任务。
- Presets 开箱即用；Session / Request Configuration 提供灵活覆盖。

保持底层逻辑简单、职责清晰，后续增加命名规范主要通过修改配置完成。
