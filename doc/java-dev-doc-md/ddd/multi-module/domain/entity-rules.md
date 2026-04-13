# entity 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：领域层
> 所属模块：project-domain
> 包路径：`com.company.project.domain.model.entity`

---

## 1. 创建规则

### 什么时候创建
- 识别出业务概念有唯一标识和生命周期时
- 需要跟踪状态变化的业务对象

### 创建什么
- 一个实体对应一个 Java 类

### 一个业务对应几个文件
- 一个实体 = 1 个类文件
- 实体的唯一标识通常是值对象（在 valueobject 包中定义）

---

## 2. 文件命名规则

- 类名使用业务名词，无特殊后缀

| 文件 | 命名 | 示例 |
|------|------|------|
| 实体类 | 业务名 | `OrderItem`, `Address`, `Payment` |
| 实体ID | 业务名+Id | `OrderItemId`（通常作为值对象） |

---

## 3. 代码质量规则

### 【强制】
- 实体必须有唯一标识符
- 实体包含属性**和**行为方法（充血模型）
- 行为方法只做内存中的业务逻辑，不做持久化
- 状态变更必须通过行为方法，不通过 setter

### 【禁止】
- 禁止使用 Spring 框架注解
- 禁止注入 Repository 或 Service
- 禁止 public setter 暴露内部状态
- 禁止纯 POJO（只有 getter/setter 的贫血模型）

### 【推荐】
- 实体行为方法命名使用业务术语
- 复杂实体的属性可以使用 Field 包装实现 Update-Tracing

---

## 4. 依赖规则

### 可引用
- `domain.model.valueobject.*`
- `domain.exception.*`
- Java 标准库

### 禁止引用
- `domain.service.*`（实体不依赖领域服务）
- `application.*`
- `infrastructure.*`
- Spring 框架
- 任何技术框架注解

---

## 5. AI 生成检查项

- [ ] 实体有唯一 ID 字段
- [ ] 使用充血模型（有行为方法）
- [ ] 无框架注解
- [ ] 无 public setter
- [ ] 行为方法只做内存操作

---

## 6. 代码模板

```java
package com.company.project.domain.model.entity;

import com.company.project.domain.model.valueobject.Money;
import com.company.project.domain.model.valueobject.ProductId;
import com.company.project.domain.exception.AggregateException;

/**
 * 订单项实体
 */
public class OrderItem {

    private final OrderItemId id;
    private final ProductId productId;
    private int quantity;
    private Money unitPrice;

    public OrderItem(ProductId productId, int quantity, Money unitPrice) {
        if (quantity <= 0) {
            throw new AggregateException("商品数量必须大于0");
        }
        this.id = OrderItemId.generate();
        this.productId = productId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    /**
     * 修改数量
     */
    public void changeQuantity(int newQuantity) {
        if (newQuantity <= 0) {
            throw new AggregateException("商品数量必须大于0");
        }
        this.quantity = newQuantity;
    }

    /**
     * 计算小计
     */
    public Money getSubtotal() {
        return unitPrice.multiply(quantity);
    }

    // Getters
    public OrderItemId getId() { return id; }
    public ProductId getProductId() { return productId; }
    public int getQuantity() { return quantity; }
    public Money getUnitPrice() { return unitPrice; }
}
```
