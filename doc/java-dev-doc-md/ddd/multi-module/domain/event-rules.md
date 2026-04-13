# domain/event 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：领域层
> 所属模块：project-domain
> 包路径：`com.company.project.domain.event`

---

## 1. 创建规则

### 什么时候创建
- 聚合根发生重要状态变化时（如订单创建、支付完成）
- 需要通知其他聚合或系统执行后续操作时
- 需要解耦聚合间的通信时

### 创建什么
- 领域事件类（纯 POJO，不可变）

### 一个业务对应几个文件
- 一个领域事件 = 1 个文件

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 事件类 | 过去时态动词+Event | `OrderPlacedEvent`, `PaymentCompletedEvent` |

---

## 3. 代码质量规则

### 【强制】
- 事件类不可变（final 字段）
- 包含事件发生时间戳
- 包含事件源（哪个聚合产生的）标识
- 使用过去时态命名

### 【禁止】
- 禁止 setter 方法
- 禁止框架注解
- 禁止包含业务逻辑

### 【推荐】
- 提供静态工厂方法创建
- 包含必要的业务数据（不要只传 ID）

---

## 4. 依赖规则

### 可引用
- `domain.model.valueobject.*`（ID 类型）
- Java 标准库

### 禁止引用
- `domain.model.aggregate.*`
- `domain.model.entity.*`
- `infrastructure.*`
- Spring 框架

---

## 5. AI 生成检查项

- [ ] 类名使用过去时态
- [ ] 字段都是 final
- [ ] 无 setter
- [ ] 包含时间戳
- [ ] 包含聚合 ID
- [ ] 无框架注解

---

## 6. 代码模板

```java
package com.company.project.domain.event;

import com.company.project.domain.model.valueobject.OrderId;
import java.time.Instant;

/**
 * 订单已下单事件
 */
public final class OrderPlacedEvent {

    private final OrderId orderId;
    private final Instant occurredOn;

    private OrderPlacedEvent(OrderId orderId) {
        this.orderId = orderId;
        this.occurredOn = Instant.now();
    }

    public static OrderPlacedEvent of(OrderId orderId) {
        return new OrderPlacedEvent(orderId);
    }

    public OrderId getOrderId() { return orderId; }
    public Instant getOccurredOn() { return occurredOn; }
}
```
