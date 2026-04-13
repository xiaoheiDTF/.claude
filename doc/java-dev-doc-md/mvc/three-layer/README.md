# MVC 三层架构开发规则 — 总览

> 架构模式：标准三层 MVC
> 适用场景：简单项目、CRUD 居多、团队 1-3 人
> 最后更新：2026-04-11

---

## 包结构

```
src/main/java/com/company/project/
├── controller/       控制层 — 参数校验、调用 Service、组装响应
├── service/          业务逻辑层
│   └── impl/         Service 实现类
├── mapper/           数据访问层（或 dao/）
├── entity/           实体/DO（或 domain/）
├── dto/              DTO + VO + Request/Query
├── config/           配置类
├── exception/        自定义异常
└── common/           常量、枚举、工具类
```

## 依赖规则

```
controller → service → mapper
controller/service → entity, dto, common, exception
config → (独立，被 Spring 管理)

严禁：mapper → service → controller（反向依赖）
严禁：controller 直接操作 mapper
```

## 与六层 MVC 的区别

| 维度 | 三层 | 六层 |
|------|------|------|
| 层级 | Controller → Service → DAO | +OpenAPI +Manager |
| 适用 | 简单 CRUD | 中大型业务 |
| Service | 包含所有业务逻辑 | 只做编排，Manager 做原子操作 |
| 复用性 | 低 | 高（Manager 可被多 Service 复用） |

## 规则文件索引

| 文件 | 说明 |
|------|------|
| [controller-rules.md](controller-rules.md) | 控制层规则 |
| [service-rules.md](service-rules.md) | 业务层规则 |
| [dao-mapper-rules.md](dao-mapper-rules.md) | 数据层规则 |
| [entity-rules.md](entity-rules.md) | 实体规则 |
| [dto-vo-rules.md](dto-vo-rules.md) | DTO/VO 规则 |
| [config-rules.md](config-rules.md) | 配置类规则 |
| [exception-rules.md](exception-rules.md) | 异常类规则 |
| [common-rules.md](common-rules.md) | 公共类规则 |
