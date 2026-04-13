# domain/service 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：领域层
> 包路径：`com.company.project.domain.service`

---

## 1-5. 核心规则

与多模块 service-rules.md 一致：
- 跨聚合逻辑、接口+实现都在 domain 内
- 注入 Repository 接口（非实现）
- 方法流程：加载聚合 → 调用方法 → 保存
- 依赖：`domain.model.*`、`domain.repository.*`、`domain.event.*`、`domain.exception.*`
- 禁止引用：`interfaces.*`、`application.*`、`infrastructure.*`

## 6. 代码模板

```java
package com.company.project.domain.service;

public interface OrderService {
    Order createOrder(CreateOrderParam param);
    Order getOrder(OrderId orderId);
    void cancelOrder(OrderId orderId, String reason);
}

public class OrderServiceImpl implements OrderService {
    private final OrderRepository orderRepository;

    @Override
    public Order createOrder(CreateOrderParam param) {
        Order order = Order.create(param.getCustomerId());
        param.getItems().forEach(i -> order.addItem(i.getProductId(), i.getQuantity(), i.getPrice()));
        order.place();
        orderRepository.save(order);
        return order;
    }
}
```
