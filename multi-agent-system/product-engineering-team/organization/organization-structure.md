# 组织架构

## 分层

- Executive Layer
- Management Layer
- Functional Layer
- Execution Layer
- Infrastructure Layer

## 团队

### Corporate Strategy Office (企业战略办公室)
- **层级**: Executive Layer
- **Team Leader**: CEO Agent
- **成员**:
  - CEO Agent
  - Orchestrator Agent

### Engineering Team (工程团队)
- **层级**: Execution Layer
- **Team Leader**: Engineering Manager Agent
- **成员**:
  - Engineering Manager Agent
  - Architect Agent
  - Frontend Engineer Agent
  - Backend Engineer Agent
  - AI Engineer Agent
  - DevOps Agent
  - Code Review Agent

### Quality Assurance Team (质量保障团队)
- **层级**: Execution Layer
- **Team Leader**: Quality Assurance Leader Agent
- **成员**:
  - Quality Assurance Leader Agent
  - Quality Assurance Agent
  - Performance Agent
  - Security Agent

### Product Team (产品团队)
- **层级**: Functional Layer
- **Team Leader**: Product Manager Agent
- **成员**:
  - Product Manager Agent
  - Requirement Analyst Agent
  - User Research Agent

### Data Team (数据团队)
- **层级**: Functional Layer
- **Team Leader**: BI Agent
- **成员**:
  - BI Agent
  - Data Analyst Agent

### Design Team (设计团队)
- **层级**: Functional Layer
- **Team Leader**: UX Agent
- **成员**:
  - UX Agent
  - UI Design Agent

### Platform Team (平台团队)
- **层级**: Infrastructure Layer
- **Team Leader**: Workflow Orchestrator Agent
- **成员**:
  - Workflow Orchestrator Agent
  - Memory Manager Agent

### Delivery Team (交付团队)
- **层级**: Management Layer
- **Team Leader**: Project Manager Agent
- **成员**:
  - Project Manager Agent
  - Release Manager Agent

### Skills Team (技能团队)
- **层级**: Infrastructure Layer
- **Team Leader**: Skills Team Orchestrator Agent
- **成员**:
  - Skills Librarian Agent
  - Skills Team Orchestrator Agent
  - Skills Discovery Agent
  - Skills Design Agent
  - Skills Generation Agent
  - Skills Review Agent
  - Skills Refactor Agent
  - Skills Evolution Agent

## Team Leader 汇总

| 团队 | Team Leader | 核心决策权限 |
|------|-------------|-------------|
| Corporate Strategy Office | CEO Agent | 战略方向、预算分配、风险处置 |
| Engineering Team | Engineering Manager Agent | 任务分派、迭代排期、质量门禁 |
| Quality Assurance Team | Quality Assurance Leader Agent | 发布决策、测试策略、缺陷优先级 |
| Product Team | Product Manager Agent | 需求优先级、发布范围、验收标准 |
| Data Team | BI Agent | 数据指标、数据治理、分析报告 |
| Design Team | UX Agent | 体验标准、设计规范、设计评审 |
| Platform Team | Workflow Orchestrator Agent | 工作流调度、资源分配、平台架构 |
| Delivery Team | Project Manager Agent | 项目排期、资源协调、发布窗口 |

## 层级关系

```
Executive Layer
    └── Corporate Strategy Office (CEO Agent)
            │
            ├── Management Layer
            │       └── Delivery Team (Project Manager Agent)
            │
            ├── Functional Layer
            │       ├── Product Team (Product Manager Agent)
            │       ├── Data Team (BI Agent)
            │       └── Design Team (UX Agent)
            │
            ├── Execution Layer
            │       ├── Engineering Team (Engineering Manager Agent)
            │       └── Quality Assurance Team (Quality Assurance Leader Agent)
            │
            └── Infrastructure Layer
                    ├── Platform Team (Workflow Orchestrator Agent)
                    └── Skills Team (Librarian Agent)
```