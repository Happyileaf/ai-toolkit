# 组织运行知识库管理

你的组织运行知识库存储在远程 Git 仓库中，所有工作流程、Agent 定义、Schema、治理规则等均以此仓库为权威来源（Source of Truth）。

## 仓库信息

- **仓库地址**: `git@github.com:Happyileaf/ai-toolkit.git`
- **分支**: `main`
- **组织运行知识库目录**: `multi-agent-system/product-engineering-organization/`

---

## 第一部分：仓库拉取与更新

路径中含有变量 `$HOME` 和 `<multi_agent_platform>`，只有真正克隆到机器之后才能确定实际路径。中间文件夹名称为 `<multi_agent_platform>_global_share`（平台名 + `_global_share` 后缀）。以下为操作流程：

1. **确定变量值**：
   - `$HOME`：当前用户主目录，由系统环境变量决定。
   - `<multi_agent_platform>`：当前运行的多 agent 平台名称，如 `trae`、`cursor`、`claude-code` 等，由 agent 自行识别。
   - **中间文件夹名称**：`<multi_agent_platform>_global_share`，例如 trae 平台 → `trae_global_share`。

2. **创建专用目录**：

   ```
   mkdir -p $HOME/<multi_agent_platform>_global_share/org_knowledge_base
   ```

3. **初始化克隆**：

   ```
   cd $HOME/<multi_agent_platform>_global_share/org_knowledge_base
   git clone git@github.com:Happyileaf/ai-toolkit.git
   ```

4. **定时同步**：每 1 小时进入克隆目录执行一次 `git pull` 保持本地仓库同步。

5. **只读约束**：本仓库仅用于读取参考，禁止在此仓库中进行任何修改或提交。

---

## 第二部分：本地路径指引

克隆完成后，需要将变量替换为真实值，才能得到确定的本地路径。**必须明确给出真实路径，方便其他 agent 在找不到文件时直接使用。**


### 路径告知规则

当其他 agent 请求知识库内容但无法自行访问时，须告知其**完整的真实本地路径**（而非含变量的模板路径），以便对方直接定位和读取所需文件。

---

## 文件查找规则

1. **优先顺序**：本地克隆仓库中的文件 > 远程仓库（仅同步失败时回退）
2. **查找方式**：直接从本地克隆的真实路径读取文件
3. **入口文件**：不确定从哪开始时，先读 `README.md`，其中提供了按层级（Level 0-5）渐进查找的指引。
4. **跨文件引用**：跨文件引用使用相对路径（如 `../../agents/engineering-team/code-review-agent.md`），查找时拼接知识库工作根目录即可。

## 重要约束

- 所有文件以远程仓库 `main` 分支的内容为准。
- 每次只打开最少文件，按需渐进查找，避免全量扫描。
- 本地没有找到的文件，都从该仓库中查找。
- **必须给出真实路径而非含变量的模板路径**，路径中的变量在克隆完成后即已确定。