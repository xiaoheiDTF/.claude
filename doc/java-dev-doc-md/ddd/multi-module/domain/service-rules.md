# domain/service 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：领域层
> 所属模块：project-domain
> 包路径：`com.company.project.domain.service`

---

## 1. 创建规则

### 什么时候创建
- 业务逻辑涉及**跨聚合**协调时
- 业务逻辑不属于任何单一聚合根或实体时
- 需要多个 Repository 协作完成一个业务操作时

### 创建什么
- 领域服务接口 + 实现类（都在 domain 模块内）

### 一个业务对应几个文件
- 一个领域服务 = 1 个接口 + 1 个实现

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 接口 | 业务名+Service | `OrderService`, `PaymentService` |
| 实现类 | 业务名+ServiceImpl | `OrderServiceImpl` |

---

## 3. 代码质量规则

### 【强制】
- 接口和实现都在 domain 模块内
- 领域服务通过构造器注入 Repository 接口
- 方法内先加载聚合根、调用聚合根方法、再保存
- 使用聚合根 ID 加锁防止并发问题

### 【禁止】
- 禁止注入 Application 层的对象
- 禁止注入 Infrastructure 层的实现类（只注入 Repository 接口）
- 禁止在领域服务中做 DTO 转换
- 禁止直接操作 PO/数据库对象

### 【推荐】
- 领域服务保持薄层，核心逻辑在聚合根内
- 每个方法对应一个完整的业务用例
- 方法参数使用领域层定义的 Param 对象

---

## 4. 依赖规则

### 可引用
- `domain.model.aggregate.*`
- `domain.model.entity.*`
- `domain.model.valueobject.*`
- `domain.repository.*`（接口）
- `domain.event.*`
- `domain.exception.*`

### 禁止引用
- `application.*`
- `infrastructure.*`
- `client.*`
- `model.*`（共享模型）
- Spring 框架注解（可用 `@Service` 标注实现类，但不依赖其他 Spring 特性）

---

## 5. AI 生成检查项

- [ ] 接口和实现都在 domain 模块内
- [ ] 通过构造器注入 Repository 接口
- [ ] 方法流程：加载聚合 → 调用方法 → 保存
- [ ] 无 DTO/PO 操作
- [ ] 有并发控制（加锁）
- [ ] 异常使用领域异常

---

## 6. 代码模板

```java
package com.company.project.domain.service;

import com.company.project.domain.model.aggregate.Order;
import com.company.project.domain.model.valueobject.OrderId;
import com.company.project.domain.repository.OrderRepository;
import com.company.project.domain.exception.BusinessException;

/**
 * 订单领域服务
 */
public interface OrderService {
    Order createOrder(CreateOrderParam param);
    void cancelOrder(OrderId orderId, String reason);
}

public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;

    public OrderServiceImpl(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    @Override
    public Order createOrder(CreateOrderParam param) {
        Order order = Order.create(param.getCustomerId());
        param.getItems().forEach(item ->
            order.addItem(item.getProductId(), item.getQuantity(), item.getPrice())
        );
        order.place();
        orderRepository.save(order);
        return order;
    }

    @Override
    public void cancelOrder(OrderId orderId, String reason) {
        Order order = orderRepository.findById(orderId);
        if (order == null) {
            throw new BusinessException("ORDER_NOT_FOUND", "订单不存在");
        }
        order.cancel(reason);
        orderRepository.save(order);
    }
}
```
