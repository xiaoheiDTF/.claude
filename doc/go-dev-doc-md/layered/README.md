# Go 标准分层架构开发规则 — 总览

> 架构模式：标准分层（Handler → Service → Repository）
> 适用场景：简单项目、CRUD 居多、团队 1-5 人
> 最后更新：2026-04-11

---

## 包结构

```
project-root/
├── cmd/
│   └── server/
│       └── main.go              ← 程序入口
├── internal/
│   ├── handler/                 ← HTTP/gRPC Handler 层
│   ├── service/                 ← 业务逻辑层
│   ├── repository/              ← 数据访问层
│   ├── model/                   ← 领域模型（实体）
│   ├── dto/                     ← DTO + Request/Response
│   ├── middleware/               ← HTTP 中间件
│   ├── config/                  ← 配置加载
│   └── pkg/                     ← 项目内部公共包
├── api/
│   └── openapi/                 ← OpenAPI/Swagger 定义
├── configs/
│   └── config.yaml              ← 配置文件模板
├── scripts/
│   └── migrate.sh               ← 构建和部署脚本
├── go.mod
├── go.sum
├── Makefile
└── .golangci.yml
```

## 依赖规则

```
handler → service → repository
handler/service → model, dto, config, middleware

严禁：repository → service → handler（反向依赖）
严禁：handler 直接操作 repository
```

## 与 Clean Architecture 的区别

| 维度 | 标准分层 | Clean Architecture |
|------|---------|-------------------|
| 层级 | Handler → Service → Repository | Entity → UseCase → Interface Adapter → Infrastructure |
| 适用 | 简单 CRUD | 复杂业务逻辑 |
| 依赖方向 | 上→下 | 外→内（内层不依赖外层） |
| 复用性 | 低 | 高（UseCase 可被多种 Adapter 复用） |

## 规则文件索引

| 文件 | 说明 |
|------|------|
| [handler-rules.md](handler-rules.md) | Handler 层规则 |
| [service-rules.md](service-rules.md) | Service 层规则 |
| [repository-rules.md](repository-rules.md) | 数据访问层规则 |
| [model-rules.md](model-rules.md) | 领域模型规则 |
| [dto-rules.md](dto-rules.md) | DTO/Request/Response 规则 |
| [config-rules.md](config-rules.md) | 配置规则 |
| [middleware-rules.md](middleware-rules.md) | 中间件规则 |
| [error-rules.md](error-rules.md) | 错误处理规则 |
