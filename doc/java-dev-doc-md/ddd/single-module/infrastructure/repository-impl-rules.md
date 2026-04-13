# infrastructure/repository 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：基础设施层
> 包路径：`com.company.project.infrastructure.repository`

---

## 1-5. 核心规则

与多模块 repository-impl-rules.md 一致：
- 实现 domain.repository 中的接口
- 聚合根 ↔ PO 转换
- 可引用：`domain.*`、`infrastructure.persistence.*`、Spring 注解
- 禁止引用：`interfaces.*`、`application.*`

## 6. 代码模板

```java
package com.company.project.infrastructure.repository;

@Repository
public class OrderRepositoryImpl implements OrderRepository {

    private final OrderPOMapper orderPOMapper;

    @Override
    public Optional<Order> findById(OrderId orderId) {
        OrderPO po = orderPOMapper.selectById(orderId.getValue());
        return Optional.ofNullable(po).map(this::toDomain);
    }

    @Override
    public void save(Order order) {
        OrderPO po = toPO(order);
        if (order.isNew()) { orderPOMapper.insert(po); }
        else { orderPOMapper.updateById(po); }
    }
}
```
