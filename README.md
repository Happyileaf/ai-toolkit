# AI Toolkit
AI Toolkit - Rules, Skills &amp; Workflows for Multimodal Models

该仓库用于维护一系列 **LLM 生成内容规则、技能与工作流**。每条规则、技能、工作流使用独立的 Markdown 文件管理，便于审阅、版本追踪与协作。

## 目录结构

```text
.
├── README.md
├── package.json
├── .gitignore
├── rules/
│   ├── README.md
│   ├── coding/
│   │   ├── index.md
│   │   ├── _template.md
│   │   ├── enum-definition.md
│   │   ├── react-component.md
│   │   ├── naming-convention.md
│   │   └── comment-convention.md
│   ├── prompts/
│   └── agents/
├── skills/
│   ├── README.md
│   └── examples/
└── workflows/
    ├── README.md
    └── examples/
```

## 使用方式

### 规则（Rules）

1. 在 `rules/` 对应子目录下新增规则文件（如：`rules/coding/new-rule.md`）。
2. 参考 `rules/coding/_template.md` 填写规则内容。
3. 在 `rules/coding/index.md` 中登记该规则。
4. 提交 Git 变更。

### 技能（Skills）

1. 在 `skills/examples/` 下新增技能文件。
2. 参考 `skills/README.md` 填写技能内容。
3. 提交 Git 变更。

### 工作流（Workflows）

1. 在 `workflows/examples/` 下新增工作流文件。
2. 参考 `workflows/README.md` 填写工作流内容。
3. 提交 Git 变更。

## 建议的 Git 流程

根据维护的内容类型，使用对应的 commit message 格式：

```bash
git status
git add .

# 规则相关
git commit -m "feat(rules): add <rule-name>"
git commit -m "feat(rules): update <rule-name>"
git commit -m "docs(rules): update <rule-name> description"

# 技能相关
git commit -m "feat(skills): add <skill-name>"
git commit -m "feat(skills): update <skill-name>"
git commit -m "docs(skills): update <skill-name> description"

# 工作流相关
git commit -m "feat(workflows): add <workflow-name>"
git commit -m "feat(workflows): update <workflow-name>"
git commit -m "docs(workflows): update <workflow-name> description"

# 项目配置相关
git commit -m "chore: update package.json dependencies"
git commit -m "chore: update .gitignore"
git commit -m "chore: init project structure"

# 文档相关
git commit -m "docs: update README.md"
git commit -m "docs: add contribution guide"

# 其他
git commit -m "style: format code"
git commit -m "refactor: reorganize directory structure"
git commit -m "test: add test cases"
```

## 规则索引

详见 [rules/coding/index.md](./rules/coding/index.md)。