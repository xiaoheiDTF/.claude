# DDD 多模块项目开发规则 — 总览

> 架构模式：多模块 DDD（完整模式）
> 适用场景：大型项目、多团队协作、复杂业务逻辑
> 最后更新：2026-04-11

---

## 模块结构

```
project/
├── project-client/              [Maven Module] 对外 API 定义
│   └── src/main/java/.../client/
│       └── api/                     ← 接口定义、DTO
│
├── project-model/               [Maven Module] 共享模型
│   └── src/main/java/.../model/
│       ├── dto/                     ← 内外部共用 DTO
│       ├── enums/                   ← 枚举
│       └── constant/                ← 常量
│
├── project-application/         [Maven Module] 应用层
│   └── src/main/java/.../application/
│       ├── command/                 ← CQRS 写操作
│       ├── query/                   ← CQRS 读操作
│       └── assembler/              ← DTO ↔ 领域对象转换
│
├── project-domain/              [Maven Module] 领域层（核心！）
│   └── src/main/java/.../domain/
│       ├── model/
│       │   ├── aggregate/           ← 聚合根
│       │   ├── entity/              ← 实体
│       │   └── valueobject/         ← 值对象
│       ├── service/                 ← 领域服务
│       ├── repository/              ← 仓储接口（无实现）
│       ├── event/                   ← 领域事件
│       └── exception/               ← 领域异常
│
├── project-infrastructure/      [Maven Module] 基础设施层
│   └── src/main/java/.../infrastructure/
│       ├── repository/              ← 仓储实现
│       ├── persistence/             ← PO、Mapper、XML
│       ├── gateway/                 ← 外部 API 调用
│       ├── mq/                      ← 消息队列
│       └── cache/                   ← 缓存
│
└── project-starter/             [Maven Module] 启动模块
    └── src/main/java/
        └── Application.java
```

## 模块依赖规则

```
                    ┌──────────────┐
                    │   starter    │
                    └──────┬───────┘
           ┌───────────────┼───────────────┐
           ↓               ↓               ↓
    ┌──────────┐   ┌──────────┐   ┌────────────────┐
    │  client  │   │application│   │ infrastructure  │
    └────┬─────┘   └────┬─────┘   └───────┬────────┘
         │              │                 │
         ↓              ↓                 ↓
    ┌──────────┐   ┌──────────┐           │
    │  model   │   │  domain  │ ←─────────┘
    └──────────┘   └──────────┘
                       ↑
                  (依赖倒置：infrastructure 实现 domain 的接口)

domain → 不依赖任何外部模块！纯 Java
model → 不依赖任何外部模块！纯 Java
```

## 各层职责速查

| 模块 | 职责 | 包含技术 | 不包含 |
|------|------|---------|--------|
| client | 对外 API 定义 | Feign/Dubbo 接口、DTO | 业务逻辑 |
| model | 共享模型 | 纯 POJO、枚举、常量 | 业务逻辑、技术框架 |
| application | 业务编排 | Spring 事务、DTO 转换 | 核心业务规则 |
| domain | 核心业务 | **纯 Java**（无框架注解）| 数据库、MQ、缓存 |
| infrastructure | 技术实现 | MyBatis、Redis、MQ | 业务逻辑 |
| starter | 启动入口 | Spring Boot | 业务代码 |

## 选用建议

**适用多模块 DDD 的场景**：
- 团队 5+ 人，多个团队协作
- 业务逻辑复杂、规则多变
- 需要领域模型长期沉淀
- 微服务架构，限界上下文明确

**不适用多模块 DDD 的场景**：
- 简单 CRUD 应用 → 用单模块 DDD 或 MVC
- 团队小、项目急 → 用单模块 DDD
- 业务规则稳定不变 → 用 MVC

## 规则文件索引

| 文件 | 对应包 | 说明 |
|------|--------|------|
| [client/api-rules.md](client/api-rules.md) | client/api | 对外接口定义规则 |
| [model/shared-model-rules.md](model/shared-model-rules.md) | model | 共享模型规则 |
| [application/command-rules.md](application/command-rules.md) | application/command | 写操作编排规则 |
| [application/query-rules.md](application/query-rules.md) | application/query | 读操作规则 |
| [application/assembler-rules.md](application/assembler-rules.md) | application/assembler | 对象转换规则 |
| [domain/aggregate-rules.md](domain/aggregate-rules.md) | domain/model/aggregate | 聚合根规则 |
| [domain/entity-rules.md](domain/entity-rules.md) | domain/model/entity | 实体规则 |
| [domain/valueobject-rules.md](domain/valueobject-rules.md) | domain/model/valueobject | 值对象规则 |
| [domain/service-rules.md](domain/service-rules.md) | domain/service | 领域服务规则 |
| [domain/repository-rules.md](domain/repository-rules.md) | domain/repository | 仓储接口规则 |
| [domain/event-rules.md](domain/event-rules.md) | domain/event | 领域事件规则 |
| [domain/exception-rules.md](domain/exception-rules.md) | domain/exception | 领域异常规则 |
| [infrastructure/repository-impl-rules.md](infrastructure/repository-impl-rules.md) | infrastructure/repository | 仓储实现规则 |
| [infrastructure/persistence-rules.md](infrastructure/persistence-rules.md) | infrastructure/persistence | 持久化规则 |
| [infrastructure/gateway-rules.md](infrastructure/gateway-rules.md) | infrastructure/gateway | 外部调用规则 |
| [infrastructure/mq-cache-rules.md](infrastructure/mq-cache-rules.md) | infrastructure/mq+cache | MQ/缓存规则 |
| [starter-rules.md](starter-rules.md) | starter | 启动模块规则 |
