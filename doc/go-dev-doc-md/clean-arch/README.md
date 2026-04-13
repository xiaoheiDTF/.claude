# Go Clean Architecture 开发规则 — 总览

> 架构模式：Clean Architecture（整洁架构 / 六边形架构）
> 适用场景：复杂业务逻辑、需要高可测试性、长期维护项目
> 最后更新：2026-04-11

---

## 核心原则

```
依赖规则：外层 → 内层（可以调用）
         内层 → 外层（绝对禁止，通过接口反转）

┌─────────────────────────────────────────────┐
│ Frameworks & Drivers (最外层)                │
│  HTTP/gRPC, Database, External Services     │
│  ┌───────────────────────────────────────┐  │
│  │ Interface Adapters                    │  │
│  │  Handlers, Presenters, Gateways      │  │
│  │  ┌───────────────────────────────┐   │  │
│  │  │ Application Business Rules    │   │  │
│  │  │  Use Cases (Interactors)     │   │  │
│  │  │  ┌───────────────────────┐   │   │  │
│  │  │  │ Enterprise Business   │   │   │  │
│  │  │  │ Rules (Entities)     │   │   │  │
│  │  │  └───────────────────────┘   │   │  │
│  │  └───────────────────────────────┘   │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

## 包结构

```
project-root/
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── domain/                   ← Enterprise Business Rules（最内层）
│   │   ├── entity/               ← 实体
│   │   ├── valueobject/          ← 值对象
│   │   ├── repository/           ← Repository 接口（端口）
│   │   ├── service/              ← 领域服务
│   │   └── event/                ← 领域事件
│   ├── usecase/                  ← Application Business Rules
│   │   ├── order_usecase.go      ← 用例（Interactor）
│   │   ├── order_usecase_test.go
│   │   └── port/                 ← 用例所需的端口接口
│   ├── adapter/                  ← Interface Adapters
│   │   ├── handler/              ← HTTP/gRPC 处理器
│   │   ├── presenter/            ← 响应转换器
│   │   └── gateway/              ← 外部服务适配器
│   └── infrastructure/           ← Frameworks & Drivers（最外层）
│       ├── persistence/          ← 数据库实现
│       ├── cache/                ← 缓存实现
│       ├── mq/                   ← 消息队列实现
│       └── config/               ← 配置实现
├── api/
│   └── proto/                    ← gRPC proto 定义
├── go.mod
├── go.sum
├── Makefile
└── .golangci.yml
```

## 依赖规则

```
adapter → usecase → domain
infrastructure → domain (实现 domain 中的接口)
infrastructure → adapter (可选)

严禁：domain → usecase → adapter → infrastructure（内层依赖外层）
严禁：domain 包 import 任何外部包（除标准库）
```

## 关键区别

| 维度 | 标准分层 | Clean Architecture |
|------|---------|-------------------|
| 依赖方向 | 上→下 | 外→内 |
| domain 包 | 可引用 dto | 零外部依赖 |
| Repository | 实现在 repo 层 | 接口在 domain，实现在 infrastructure |
| 测试性 | 需 mock repo | 内层完全独立可测 |
| 框架依赖 | 可能耦合 | 框架是细节，可替换 |

## 规则文件索引

| 文件 | 说明 |
|------|------|
| [entities/entity-rules.md](entities/entity-rules.md) | 实体规则 |
| [entities/valueobject-rules.md](entities/valueobject-rules.md) | 值对象规则 |
| [usecases/usecase-rules.md](usecases/usecase-rules.md) | 用例规则 |
| [usecases/repository-port-rules.md](usecases/repository-port-rules.md) | Repository 端口规则 |
| [interface-adapters/handler-rules.md](interface-adapters/handler-rules.md) | Handler 适配器规则 |
| [interface-adapters/presenter-rules.md](interface-adapters/presenter-rules.md) | Presenter 规则 |
| [interface-adapters/dto-rules.md](interface-adapters/dto-rules.md) | DTO 规则 |
| [infrastructure/repository-impl-rules.md](infrastructure/repository-impl-rules.md) | Repository 实现规则 |
| [infrastructure/external-rules.md](infrastructure/external-rules.md) | 外部服务适配器规则 |
