# 组织运行知识库服务协议

> 本文档定义了 Knowledge Team 向全组织提供的知识库服务协议，包括仓库信息、服务接口、服务级别承诺（SLA）、操作流程与约束规则。所有团队均以此文档为知识库服务的权威依据。

---

## 服务提供方

- **提供方**: Knowledge Team (Infrastructure Layer)
- **Team Leader**: Knowledge Team Leader Agent
- **核心服务角色**: Knowledge Sync Agent（路径与同步）、Knowledge Curator Agent（内容质量）

---

## 第一部分：仓库信息

- **仓库地址**: `git@github.com:Happyileaf/ai-toolkit.git`
- **分支**: `main`
- **组织运行知识库目录**: `multi-agent-system/product-engineering-organization/`

---

## 第二部分：服务接口

Knowledge Team 向所有团队提供以下服务接口：

### 2.1 路径查询服务

- **提供方**: Knowledge Sync Agent
- **请求方式**: 向 Knowledge Sync Agent 发送路径查询请求
- **响应内容**: 组织运行知识库的真实本地路径（变量已替换为确定性值）
- **响应时效**: 5 分钟内提供真实路径
- **示例路径**: `$HOME/trae_global_share/org_knowledge_base/ai-toolkit/multi-agent-system/product-engineering-organization/`（其中 `$HOME` 和 `trae_global_share` 为变量替换后的真实值）

### 2.2 同步状态查询服务

- **提供方**: Knowledge Sync Agent
- **请求方式**: 向 Knowledge Sync Agent 发送同步状态查询请求
- **响应内容**: 当前同步状态（成功/失败/偏差时长）、最后同步时间
- **响应时效**: 5 分钟内

### 2.3 内容缺失反馈服务

- **提供方**: Knowledge Curator Agent
- **请求方式**: 向 Knowledge Curator Agent 反馈缺失或质量问题
- **响应内容**: 确认收到、补充计划或已知缺失标记
- **处理时效**: 缺失文档 2 个工作日内补充或标记为已知缺失

### 2.4 文档准入服务

- **提供方**: Knowledge Team Leader Agent
- **请求方式**: 向 Knowledge Team Leader Agent 提交文档准入请求
- **响应内容**: 准入决策（通过/不通过/需修改）与依据
- **处理时效**: 战略级文档当日决策，普通文档 2 个工作日内决策

---

## 第三部分：服务级别承诺（SLA）

| 服务指标 | 目标值 | 超标处理 |
|----------|--------|----------|
| 知识库同步成功率 | >= 99% | 连续 3 次同步失败触发告警并升级 |
| 本地副本与远程仓库偏差 | <= 1 小时 | 偏差超过 2 小时触发应急恢复 |
| 路径查询响应时效 | <= 5 分钟 | 超过 15 分钟触发升级告警 |
| 缺失文档补充时效 | <= 2 个工作日 | 超过 3 个工作日标记为已知缺失并通知影响方 |
| 内容准入决策时效 | 战略级当日，普通级 2 个工作日 | 超时自动标记为待决策并升级 |

---

## 第四部分：操作流程

### 4.1 仓库拉取与更新

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

### 4.2 本地路径指引

克隆完成后，需要将变量替换为真实值，才能得到确定的本地路径。**必须明确给出真实路径，方便其他 agent 在找不到文件时直接使用。**

### 4.3 路径告知规则

当其他 agent 请求知识库内容但无法自行访问时，Knowledge Sync Agent 须告知其**完整的真实本地路径**（而非含变量的模板路径），以便对方直接定位和读取所需文件。

### 4.4 文件查找规则

1. **优先顺序**：本地克隆仓库中的文件 > 远程仓库（仅同步失败时回退）
2. **查找方式**：直接从本地克隆的真实路径读取文件
3. **入口文件**：不确定从哪开始时，先读 `README.md`，其中提供了按层级（Level 0-5）渐进查找的指引。
4. **跨文件引用**：跨文件引用使用相对路径（如 `../../agents/engineering-team/code-review-agent.md`），查找时拼接知识库工作根目录即可。

---

## 第五部分：服务降级与应急

| 场景 | 降级方案 | 升级路径 |
|------|----------|----------|
| 知识库同步完全失败 | 直接引用远程仓库作为应急来源 | 1 小时内启动应急恢复，升级至 Knowledge Team Leader Agent |
| 多团队反馈路径不可用 | 提供应急访问方案（直接引用远程仓库） | 30 分钟内响应排查，升级至 Knowledge Team Leader Agent |
| 关键组织文档缺失 | 提供替代文档或手动补充 | 4 小时内补充或提供替代方案 |

---

## 第六部分：重要约束

- 所有文件以远程仓库 `main` 分支的内容为准。
- 每次只打开最少文件，按需渐进查找，避免全量扫描。
- 本地没有找到的文件，都从该仓库中查找。
- **必须给出真实路径而非含变量的模板路径**，路径中的变量在克隆完成后即已确定。
- 知识库本地副本为只读，禁止任何修改或提交。
- 各团队不得自行克隆或维护知识库副本，统一通过 Knowledge Team 获取服务。

---

## 变更历史

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| 1.0 | 2026-06-15 | 从操作手册扩展为服务协议，增加服务接口、SLA、服务降级章节；执行方从 Orchestrator Agent 转移至 Knowledge Team |
