# domain/model/entity 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：领域层
> 包路径：`com.company.project.domain.model.entity`

---

## 1-5. 核心规则

与多模块 entity-rules.md 完全一致：
- 有唯一 ID、充血模型、无框架注解
- 依赖：只引用 `domain.model.valueobject.*`、`domain.exception.*`、`java.*`
- 禁止引用：`interfaces.*`、`application.*`、`infrastructure.*`

## 6. 代码模板

```java
package com.company.project.domain.model.entity;

public class OrderItem {
    private final OrderItemId id;
    private final ProductId productId;
    private int quantity;
    private Money unitPrice;

    public void changeQuantity(int newQuantity) {
        if (newQuantity <= 0) throw new AggregateException("数量必须大于0");
        this.quantity = newQuantity;
    }

    public Money getSubtotal() { return unitPrice.multiply(quantity); }
    // Getters...
}
```
