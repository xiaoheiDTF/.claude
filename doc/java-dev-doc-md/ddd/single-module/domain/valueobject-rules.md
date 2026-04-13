# domain/model/valueobject 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：领域层
> 包路径：`com.company.project.domain.model.valueobject`

---

## 1-5. 核心规则

与多模块 valueobject-rules.md 完全一致：
- 不可变（final 字段）、无 setter、实现 equals/hashCode
- 依赖：只引用 `domain.exception.*`、`java.*`
- 禁止引用：`interfaces.*`、`application.*`、`infrastructure.*`、`org.springframework.*`

## 6. 代码模板

```java
package com.company.project.domain.model.valueobject;

public final class OrderId {
    private final String value;

    private OrderId(String value) {
        this.value = Objects.requireNonNull(value, "订单ID不能为空");
    }

    public static OrderId of(String value) { return new OrderId(value); }
    public static OrderId generate() { return new OrderId(UUID.randomUUID().toString()); }

    @Override public boolean equals(Object o) { ... }
    @Override public int hashCode() { return value.hashCode(); }
}
```
