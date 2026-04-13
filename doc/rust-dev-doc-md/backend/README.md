# Rust 后端开发规则 — 总览

> 适用场景：Web API 服务、微服务后端
> 框架：框架无关（Axum / Actix-web 通用模式）
> 最后更新：2026-04-11

---

## 推荐目录结构

```
src/
├── main.rs                       ← 入口：启动服务器
├── config.rs                     ← 配置加载
├── error.rs                      ← 统一错误类型
├── state.rs                      ← 应用状态（AppState）
├── routes/                       ← 路由定义
│   ├── mod.rs
│   └── order_routes.rs
├── handlers/                     ← HTTP Handler（对应 Controller）
│   ├── mod.rs
│   └── order_handler.rs
├── services/                     ← 业务逻辑层
│   ├── mod.rs
│   └── order_service.rs
├── repositories/                 ← 数据访问层
│   ├── mod.rs
│   └── order_repository.rs
├── models/                       ← 数据模型
│   ├── mod.rs
│   ├── order.rs                  ← 领域模型
│   └── dto.rs                    ← DTO（请求/响应）
├── middleware/                   ← 中间件
│   ├── mod.rs
│   ├── auth.rs
│   └── logging.rs
└── utils/                        ← 工具函数
```

## 依赖规则

```
handlers → services → repositories
handlers/services → models, error, config

严禁：repositories → services → handlers（反向依赖）
严禁：handlers 直接操作数据库
```

## 规则文件索引

| 文件 | 说明 |
|------|------|
| [handler-rules.md](handler-rules.md) | HTTP Handler 规则 |
| [service-rules.md](service-rules.md) | 业务逻辑层规则 |
| [repository-rules.md](repository-rules.md) | 数据访问层规则 |
| [model-rules.md](model-rules.md) | 数据模型规则 |
| [error-rules.md](error-rules.md) | 错误处理规则 |
| [middleware-rules.md](middleware-rules.md) | 中间件规则 |

> 来源：[Structuring a Rust Backend](https://medium.com/@rivelbab/rust-actix-web-structuring-and-organizing-an-api-like-a-pro-790657e61ba5), [Best Way to Structure Rust Web Services](https://blog.logrocket.com/best-way-structure-rust-web-services/)
