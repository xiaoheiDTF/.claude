# MVC 六层架构开发规则 — 总览

> 架构模式：阿里扩展六层 MVC
> 适用场景：中大型项目、团队 5+ 人、需要服务复用
> 最后更新：2026-04-11

---

## 包结构

```
src/main/java/com/company/project/
├── openapi/          开放接口层 — RPC/HTTP 接口封装、网关控制
├── controller/       Web 层 — 参数校验、调用 Service
├── service/          核心业务层 — 业务编排
│   └── impl/
├── manager/          通用业务层 — 原子服务、第三方封装
│   └── impl/
├── mapper/           数据持久层 — CRUD
├── entity/           实体/DO
├── dto/              DTO + VO + Query + Request
├── config/           配置类
├── exception/        自定义异常
└── common/           常量、枚举、工具类
```

## 依赖规则

```
openapi → service
controller → service
service → manager, entity, dto, common
manager → mapper, entity, dto, common
mapper → entity
```

## 与三层 MVC 的核心区别

| 维度 | 三层 | 六层 |
|------|------|------|
| Service | 包含所有业务逻辑 | **只做编排**，原子操作下沉 Manager |
| Manager | 无 | **通用原子服务**，被多 Service 复用 |
| OpenAPI | 无 | **封装对外接口**，RPC/网关控制 |
| 复用性 | 低 | 高 |

## Manager 层职责

- 第三方服务封装（支付、短信、物流）
- 中间件操作封装（Redis、MQ）
- 多 Mapper 组合查询
- 通用业务处理（分页、导出、转换）

## 规则文件索引

| 文件 | 说明 |
|------|------|
| [openapi-rules.md](openapi-rules.md) | 开放接口层规则（六层独有） |
| [controller-rules.md](controller-rules.md) | Web 层规则 |
| [service-rules.md](service-rules.md) | 核心业务层规则 |
| [manager-rules.md](manager-rules.md) | 通用业务层规则（六层独有） |
| [dao-mapper-rules.md](dao-mapper-rules.md) | 数据持久层规则 |
| [entity-rules.md](entity-rules.md) | 实体规则 |
| [dto-vo-rules.md](dto-vo-rules.md) | DTO/VO 规则 |
| [config-rules.md](config-rules.md) | 配置类规则 |
| [exception-rules.md](exception-rules.md) | 异常类规则 |
| [common-rules.md](common-rules.md) | 公共类规则 |
