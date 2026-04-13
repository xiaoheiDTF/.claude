# DDD 单模块项目开发规则 — 总览

> 架构模式：单模块 DDD（简化模式）
> 适用场景：中小型项目、快速迭代、团队 3-5 人
> 最后更新：2026-04-11

---

## 包结构

```
src/main/java/com/company/project/
├── interfaces/                  接口层
│   ├── controller/              ← REST 控制器
│   ├── dto/                     ← Command + Query + VO（合并）
│   └── assembler/               ← DTO ↔ 领域对象转换
│
├── application/                 应用层
│   └── service/                 ← 应用服务（编排，CQRS 简化）
│
├── domain/                      领域层（核心！无技术依赖）
│   ├── model/
│   │   ├── aggregate/           ← 聚合根
│   │   ├── entity/              ← 实体
│   │   └── valueobject/         ← 值对象
│   ├── service/                 ← 领域服务
│   ├── repository/              ← 仓储接口（无实现）
│   ├── event/                   ← 领域事件
│   └── exception/               ← 领域异常
│
├── infrastructure/              基础设施层
│   ├── repository/              ← 仓储实现
│   ├── persistence/             ← PO、Mapper
│   └── mq-cache/                ← MQ + Cache
│
└── Application.java             启动类
```

## 包依赖规则

```
interfaces ──→ application ──→ domain ←── infrastructure

domain 包：
  ✅ 可引用：domain 内部子包、java 标准库
  ❌ 禁止引用：interfaces、application、infrastructure、Spring

interfaces 包：
  ✅ 可引用：application、domain（仅值对象和异常）
  ❌ 禁止引用：infrastructure

application 包：
  ✅ 可引用：domain、interfaces.dto
  ❌ 禁止引用：infrastructure

infrastructure 包：
  ✅ 可引用：domain（实现接口）、Spring、MyBatis 等
  ❌ 禁止引用：interfaces、application
```

## 与多模块 DDD 的对比

| 维度 | 单模块 | 多模块 |
|------|--------|--------|
| 隔离方式 | 包级（package） | 模块级（Maven Module） |
| CQRS | 简化（可混合读写） | 严格分离 command/query |
| 共享模型 | 在 interfaces/dto 中 | 独立 model 模块 |
| 对外接口 | controller 直接暴露 | 独立 client 模块 |
| 应用层 | 合并为 application/service | 分 command/query/assembler |
| 适用场景 | 中小型、3-5 人 | 大型、5+ 人多团队 |

## 规则文件索引

| 文件 | 对应包 | 说明 |
|------|--------|------|
| [interfaces/controller-rules.md](interfaces/controller-rules.md) | interfaces/controller | 控制器规则 |
| [interfaces/dto-rules.md](interfaces/dto-rules.md) | interfaces/dto | DTO/VO 规则 |
| [interfaces/assembler-rules.md](interfaces/assembler-rules.md) | interfaces/assembler | 对象转换规则 |
| [application/service-rules.md](application/service-rules.md) | application/service | 应用服务规则 |
| [domain/aggregate-rules.md](domain/aggregate-rules.md) | domain/model/aggregate | 聚合根规则 |
| [domain/entity-rules.md](domain/entity-rules.md) | domain/model/entity | 实体规则 |
| [domain/valueobject-rules.md](domain/valueobject-rules.md) | domain/model/valueobject | 值对象规则 |
| [domain/service-rules.md](domain/service-rules.md) | domain/service | 领域服务规则 |
| [domain/repository-rules.md](domain/repository-rules.md) | domain/repository | 仓储接口规则 |
| [domain/event-rules.md](domain/event-rules.md) | domain/event | 领域事件规则 |
| [domain/exception-rules.md](domain/exception-rules.md) | domain/exception | 领域异常规则 |
| [infrastructure/repository-impl-rules.md](infrastructure/repository-impl-rules.md) | infrastructure/repository | 仓储实现规则 |
| [infrastructure/persistence-rules.md](infrastructure/persistence-rules.md) | infrastructure/persistence | 持久化规则 |
| [infrastructure/mq-cache-rules.md](infrastructure/mq-cache-rules.md) | infrastructure/mq-cache | MQ/缓存规则 |
| [starter-rules.md](starter-rules.md) | 启动类 | 启动类规则 |
