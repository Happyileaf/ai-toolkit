# 组织运作知识库

你的组织运作文档存储在远程 Git 仓库中，所有工作流程、Agent 定义、Schema、治理规则等均以此仓库为权威来源（Source of Truth）。

## 仓库信息

- **仓库地址**: `git@github.com:Happyileaf/ai-toolkit.git`
- **分支**: `main`
- **工作根目录**: `multi-agent-system/product-engineering-organization/`

## 本地克隆管理

1. **稳定路径**：知识库克隆存放在用户主目录下的固定路径中，与 agent 工作空间无关，同一平台的所有 agent 实例均可共享访问。路径以当前 agent 平台名称作为中间层级，agent 平台名称由自身环境识别（如通过环境变量、工作空间目录特征等方式推断）。

   ```
   $HOME/<agent_platform>/org_knowledge_base
   ```

   > `<agent_platform>` 为当前运行的平台名称，如 `trae`、`cursor`、`claude-code` 等，由 agent 自行识别。

2. **专用目录**：创建 `org_knowledge_base` 文件夹作为此知识库仓库的父目录。该文件夹须独立存在，不要与其他需要修改的工作仓库混放。

   ```
   mkdir -p $HOME/<agent_platform>/org_knowledge_base
   ```

3. **初始化克隆**：将仓库克隆到 `org_knowledge_base` 文件夹中。

   ```
   cd $HOME/<agent_platform>/org_knowledge_base
   git clone git@github.com:Happyileaf/ai-toolkit.git
   ```

4. **定时同步**：每 1 小时进入 `$HOME/<agent_platform>/org_knowledge_base/ai-toolkit` 目录执行一次 `git pull` 保持本地仓库同步。

5. **只读约束**：本仓库仅用于读取参考，禁止在此仓库中进行任何修改或提交。

6. **本地读取**：所有文件直接从本地克隆仓库中读取，路径为 `$HOME/<agent_platform>/org_knowledge_base/ai-toolkit/multi-agent-system/product-engineering-organization/<文件路径>`。

## 文件查找规则

1. **优先顺序**：本地克隆仓库中的文件 > 远程仓库（仅同步失败时回退）
2. **查找方式**：直接从本地克隆路径读取文件
3. **入口文件**：不确定从哪开始时，先读 `README.md`，其中提供了按层级（Level 0-5）渐进查找的指引。

## 常用入口

- **产品研发流程** → `workflows/product-development-workflow/WORKFLOW.md`
- **代码评审流程** → `workflows/code-review-workflow/WORKFLOW.md`
- **Skill 创建流程** → `workflows/skill-creation-workflow/WORKFLOW.md`
- **Schema 注册表** → `schemas/schema-registry.json`
- **团队与角色索引** → `organization/agents-index.md`
- **组织分层架构** → `organization/organization-structure.md`

## 重要约束

- 所有文件以远程仓库 `main` 分支的内容为准。
- 跨文件引用使用相对路径（如 `../../agents/engineering-team/code-review-agent.md`），查找时拼接工作根目录前缀即可。
- 每次只打开最少文件，按需渐进查找，避免全量扫描。
- 本地没有找到的文件，都从该仓库中查找。