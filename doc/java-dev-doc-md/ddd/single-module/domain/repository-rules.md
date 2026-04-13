# domain/repository 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：领域层
> 包路径：`com.company.project.domain.repository`

---

## 1-5. 核心规则

与多模块 repository-rules.md 一致：
- 只有接口、无实现
- 操作粒度是聚合根
- 参数和返回值都是领域对象
- 禁止引用：`infrastructure.*`、`interfaces.*`、`application.*`

## 6. 代码模板

```java
package com.company.project.domain.repository;

public interface OrderRepository {
    Optional<Order> findById(OrderId orderId);
    List<Order> findByCustomerId(CustomerId customerId);
    void save(Order order);
    void delete(Order order);
}
```
