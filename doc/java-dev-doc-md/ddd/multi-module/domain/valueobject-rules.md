# valueobject 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：领域层
> 所属模块：project-domain
> 包路径：`com.company.project.domain.model.valueobject`

---

## 1. 创建规则

### 什么时候创建
- 描述实体的特征，无唯一标识需求时
- 多个属性组合表达一个业务含义时
- 需要封装校验逻辑的属性类型时

### 创建什么
- 单一属性值对象（如 `OrderId`、`Money`）
- 多属性值对象（如 `Address`、`TimeRange`）
- 枚举型值对象（如 `OrderStatus`）

### 一个业务对应几个文件
- 每个值对象 = 1 个文件
- 枚举也可以放在此包下

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 值对象类 | 业务名词 | `Money`, `Address`, `OrderId` |
| 枚举 | 业务名词+Status/Type | `OrderStatus`, `PaymentType` |

---

## 3. 代码质量规则

### 【强制】
- 值对象不可变（`final` 字段、无 setter）
- 修改操作返回新对象，不修改原对象
- 必须正确实现 `equals()` 和 `hashCode()`
- 构造器中完成参数校验

### 【禁止】
- 禁止 setter 方法
- 禁止可变字段（不使用 `final` 以外的字段）
- 禁止框架注解
- 禁止有 ID 字段（有 ID 的是实体）

### 【推荐】
- 提供 `static factory` 方法创建
- 多属性值对象实现 `ValueObject` 接口（如果项目定义了）
- 类型安全：用值对象替代基本类型（如 `Money` 替代 `BigDecimal`）

---

## 4. 依赖规则

### 可引用
- `domain.exception.*`
- Java 标准库

### 禁止引用
- `domain.model.entity.*`（值对象不依赖实体）
- `domain.service.*`
- `application.*`
- `infrastructure.*`
- Spring 框架

---

## 5. AI 生成检查项

- [ ] 字段都是 `final`
- [ ] 无 setter 方法
- [ ] 实现了 `equals()` 和 `hashCode()`
- [ ] 修改方法返回新对象
- [ ] 构造器中有参数校验
- [ ] 无框架注解

---

## 6. 代码模板

### 单一属性值对象

```java
package com.company.project.domain.model.valueobject;

import java.util.Objects;
import java.util.UUID;

/**
 * 订单ID值对象
 */
public final class OrderId {

    private final String value;

    private OrderId(String value) {
        this.value = Objects.requireNonNull(value, "订单ID不能为空");
    }

    public static OrderId of(String value) {
        return new OrderId(value);
    }

    public static OrderId generate() {
        return new OrderId(UUID.randomUUID().toString());
    }

    public String getValue() { return value; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        OrderId orderId = (OrderId) o;
        return value.equals(orderId.value);
    }

    @Override
    public int hashCode() { return value.hashCode(); }

    @Override
    public String toString() { return value; }
}
```

### 多属性值对象

```java
package com.company.project.domain.model.valueobject;

import java.math.BigDecimal;
import java.util.Objects;

/**
 * 金额值对象
 */
public final class Money {

    public static final Money ZERO = new Money(BigDecimal.ZERO);

    private final BigDecimal amount;

    public Money(BigDecimal amount) {
        Objects.requireNonNull(amount, "金额不能为空");
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("金额不能为负数");
        }
        this.amount = amount;
    }

    public Money add(Money other) {
        return new Money(this.amount.add(other.amount));
    }

    public Money multiply(int factor) {
        return new Money(this.amount.multiply(BigDecimal.valueOf(factor)));
    }

    public BigDecimal getAmount() { return amount; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Money money = (Money) o;
        return amount.compareTo(money.amount) == 0;
    }

    @Override
    public int hashCode() { return amount.hashCode(); }
}
```
