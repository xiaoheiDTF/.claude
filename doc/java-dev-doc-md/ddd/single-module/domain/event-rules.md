# domain/event 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：领域层
> 包路径：`com.company.project.domain.event`

---

## 1-5. 核心规则

与多模块 event-rules.md 一致：
- 不可变、过去时态命名、包含时间戳和聚合 ID
- 禁止引用：`interfaces.*`、`application.*`、`infrastructure.*`

## 6. 代码模板

```java
package com.company.project.domain.event;

public final class OrderPlacedEvent {
    private final OrderId orderId;
    private final Instant occurredOn;

    public static OrderPlacedEvent of(OrderId orderId) {
        return new OrderPlacedEvent(orderId);
    }
}
```
