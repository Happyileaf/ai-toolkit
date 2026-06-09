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
- **Team Leader**: Engineering Team Leader Agent
- **成员**:
  - Engineering Team Leader Agent
  - Architect Agent
  - Frontend Engineer Agent
  - Backend Engineer Agent
  - AI Engineer Agent
  - DevOps Agent
  - Code Review Agent

### Quality Assurance Team (质量保障团队)
- **层级**: Execution Layer
- **Team Leader**: Quality Assurance Team Leader Agent
- **成员**:
  - Quality Assurance Team Leader Agent
  - Quality Assurance Agent
  - Performance Agent
  - Security Agent

### Product Team (产品团队)
- **层级**: Functional Layer
- **Team Leader**: Product Team Leader Agent
- **成员**:
  - Product Team Leader Agent
  - Product Manager Agent
  - Requirement Analyst Agent
  - User Research Agent

### Data Team (数据团队)
- **层级**: Functional Layer
- **Team Leader**: Data Team Leader Agent
- **成员**:
  - Data Team Leader Agent
  - BI Agent
  - Data Analyst Agent

### Design Team (设计团队)
- **层级**: Functional Layer
- **Team Leader**: Design Team Leader Agent
- **成员**:
  - Design Team Leader Agent
  - UX Agent
  - UI Design Agent

### Platform Team (平台团队)
- **层级**: Infrastructure Layer
- **Team Leader**: Platform Team Leader Agent
- **成员**:
  - Platform Team Leader Agent
  - Workflow Orchestrator Agent
  - Memory Manager Agent

### Delivery Team (交付团队)
- **层级**: Management Layer
- **Team Leader**: Delivery Team Leader Agent
- **成员**:
  - Delivery Team Leader Agent
  - Project Manager Agent
  - Release Manager Agent

### Skills Team (技能团队)
- **层级**: Infrastructure Layer
- **Team Leader**: Skills Team Leader Agent
- **成员**:
  - Skills Librarian Agent
  - Skills Team Leader Agent
  - Skills Discovery Agent
  - Skills Design Agent
  - Skills Generation Agent
  - Skills Review Agent
  - Skills Refactor Agent
  - Skills Evolution Agent

## Team Leader 汇总

| 团队 | Team Leader | 核心决策权限 |
|------|-------------|-------------|
| Corporate Strategy Office | CEO Agent | 战略议题治理、升级路径、执行纠偏 |
| Engineering Team | Engineering Team Leader Agent | 任务分派、迭代排期、质量门禁 |
| Quality Assurance Team | Quality Assurance Team Leader Agent | 发布决策、测试策略、缺陷优先级 |
| Product Team | Product Team Leader Agent | 需求优先级、分派排期、范围治理 |
| Data Team | Data Team Leader Agent | 数据优先级、口径治理、分析发布 |
| Design Team | Design Team Leader Agent | 体验标准、设计门禁、评审放行 |
| Platform Team | Platform Team Leader Agent | 平台优先级、容量治理、架构演进 |
| Delivery Team | Delivery Team Leader Agent | 交付节奏、风险升级、发布窗口 |

## 层级关系

```
Executive Layer
    └── Corporate Strategy Office (CEO Agent)
            │
            ├── Management Layer
            │       └── Delivery Team (Delivery Team Leader Agent)
            │
            ├── Functional Layer
            │       ├── Product Team (Product Team Leader Agent)
            │       ├── Data Team (Data Team Leader Agent)
            │       └── Design Team (Design Team Leader Agent)
            │
            ├── Execution Layer
            │       ├── Engineering Team (Engineering Team Leader Agent)
            │       └── Quality Assurance Team (Quality Assurance Team Leader Agent)
            │
            └── Infrastructure Layer
                    ├── Platform Team (Platform Team Leader Agent)
                    └── Skills Team (Skills Team Leader Agent)
```
