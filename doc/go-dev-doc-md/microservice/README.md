# Go 微服务架构开发规则 — 总览

> 架构模式：微服务架构
> 适用场景：大规模系统、独立部署、团队分布式、高并发
> 最后更新：2026-04-11

---

## 核心原则

- 每个微服务独立部署、独立数据库
- 服务间通过 gRPC（内部）或 REST（外部）通信
- 异步场景使用消息队列（Kafka, RabbitMQ, NATS）
- 共享库通过独立 Go Module 管理

---

## 单个微服务内部结构

```
service-order/
├── cmd/
│   └── server/
│       └── main.go              ← 服务入口
├── internal/
│   ├── handler/
│   │   ├── grpc/                ← gRPC Handler
│   │   │   └── order_handler.go
│   │   └── http/                ← REST Handler
│   │       └── order_handler.go
│   ├── service/                 ← 业务逻辑
│   ├── repository/              ← 数据访问
│   ├── model/                   ← 领域模型
│   ├── dto/                     ← 数据传输对象
│   ├── middleware/               ← 中间件
│   ├── config/                  ← 配置
│   └── event/                   ← 领域事件 / 消息发布
├── api/
│   ├── proto/
│   │   └── order.proto          ← gRPC Proto 定义
│   └── openapi/
│       └── order.yaml           ← OpenAPI 定义
├── scripts/
│   └── migrate.sh
├── Dockerfile
├── go.mod
├── go.sum
├── Makefile
└── .golangci.yml
```

## 多服务仓库结构（Monorepo）

```
project-root/
├── services/
│   ├── order-service/
│   ├── user-service/
│   ├── product-service/
│   └── payment-service/
├── pkg/                         ← 共享库
│   ├── logger/
│   ├── tracing/
│   ├── middleware/
│   └── errors/
├── api/
│   └── proto/                   ← 共享 Proto 定义
│       ├── order/
│       ├── user/
│       └── common/
├── deployments/
│   ├── docker-compose.yml
│   └── k8s/
├── scripts/
├── go.work                      ← Go Workspace
└── go.work.sum
```

## 通信模式选型

| 场景 | 推荐方案 | 说明 |
|------|---------|------|
| 外部 API | REST (HTTP/JSON) | 兼容性好，易于调试 |
| 内部服务间同步调用 | gRPC (HTTP/2) | 高性能，强类型 |
| 异步事件通知 | 消息队列 (Kafka/NATS) | 解耦，削峰 |
| 服务发现 | Consul / etcd / K8s Service | 动态路由 |
| 配置中心 | Consul / etcd / K8s ConfigMap | 集中管理 |

## 与标准分层 / Clean Architecture 的关系

微服务的每个服务内部，可以使用标准分层或 Clean Architecture。本节关注的是微服务特有的关注点：
- gRPC 通信
- 消息队列
- API Gateway
- 服务间共享

## 规则文件索引

| 文件 | 说明 |
|------|------|
| [grpc-rules.md](grpc-rules.md) | gRPC 通信规则 |
| [messaging-rules.md](messaging-rules.md) | 消息队列规则 |
| [api-gateway-rules.md](api-gateway-rules.md) | API Gateway 规则 |
| [service-rules.md](service-rules.md) | 微服务内部结构规则 |
| [shared-rules.md](shared-rules.md) | 共享库规则 |

> 核心参考来源：
> - [Go Microservices in 2025](https://medium.com/@QuarkAndCode/go-microservices-in-2025-architecture-grpc-vs-rest-frameworks-09159c95a8d0) (B)
> - [Building High-Performance Microservices with Go](https://asyncsquadlabs.com/blog/microservices-go-best-practices/) (B)
> - [Architecting a Maintainable Go Microservice](https://dev.to/sagarmaheshwary/go-microservices-boilerplate-series-from-hello-world-to-production-part-1-46k5) (B)
> - [gRPC & Protocol Buffers Guide](https://www.youngju.dev/blog/culture/2026-03-24-grpc-protocol-buffers-microservices-guide-2025.en) (B)
