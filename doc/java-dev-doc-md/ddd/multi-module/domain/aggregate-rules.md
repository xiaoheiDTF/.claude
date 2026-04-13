# aggregate 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：领域层
> 所属模块：project-domain
> 包路径：`com.company.project.domain.model.aggregate`

---

## 1. 创建规则

### 什么时候创建
- 识别出业务中的"一致性边界"时（一组必须一起维护的数据）
- 一个业务事务涉及多个实体需要保持一致性时

### 创建什么
- 一个聚合根对应一个 Java 类
- 聚合根内部可包含实体和值对象的组合

### 一个业务对应几个文件
- 一个聚合 = 1 个聚合根类文件
- 聚合内部的实体和值对象分别在自己的包下创建

---

## 2. 文件命名规则

- 类名使用业务名词，无特殊后缀
- 实现或继承 `AggregateRoot` 基类（如果项目有定义）

| 文件 | 命名 | 示例 |
|------|------|------|
| 聚合根类 | 业务名 | `Order`, `Contract`, `Ticket` |
| 聚合根ID | 业务名+Id | `OrderId`, `ContractId` |

---

## 3. 代码质量规则

### 【强制】
- 聚合根必须有唯一标识符（ID 字段）
- 聚合根封装内部实体和值对象，外部只能通过聚合根方法操作
- 聚合根方法只做内存中的业务逻辑操作，**不做持久化**
- 聚合根保证内部数据一致性
- 业务规则校验在聚合根方法内完成
- 使用充血模型：属性 + 行为方法

### 【禁止】
- 禁止在聚合根中使用 Spring 注解（`@Autowired`、`@Component` 等）
- 禁止在聚合根中注入 Repository 或 Service
- 禁止在聚合根方法中执行数据库操作
- 禁止聚合根直接持有其他聚合根的引用（使用 ID 引用）
- 禁止 public 的 setter 方法暴露内部状态

### 【推荐】
- 聚合尽量小，一个聚合根通常对应一个事务
- 聚合间通过 ID 引用，不直接关联
- 聚合根方法命名使用业务术语（`placeOrder`、`cancelOrder`）
- 聚合根方法具备单一原则，与使用场景无关

---

## 4. 依赖规则

### 可引用
- `domain.model.entity.*`（本聚合内的实体）
- `domain.model.valueobject.*`
- `domain.exception.*`
- `domain.event.*`
- Java 标准库（`java.util.*`）

### 禁止引用
- `application.*`
- `infrastructure.*`
- `client.*`
- Spring 框架（`org.springframework.*`）
- MyBatis/JPA 注解（`@Entity`、`@Table`）
- 任何第三方技术框架

---

## 5. AI 生成检查项

- [ ] 聚合根有唯一 ID 字段
- [ ] 无 Spring/MyBatis/JPA 注解
- [ ] 无 Repository/Service 注入
- [ ] 方法只做内存操作，无持久化代码
- [ ] 使用充血模型（有行为方法，不只是 getter/setter）
- [ ] 业务规则在方法内校验（如状态判断）
- [ ] 与其他聚合通过 ID 引用
- [ ] 异常使用领域异常（`AggregateException` 或自定义）

---

## 6. 代码模板

```java
package com.company.project.domain.model.aggregate;

import com.company.project.domain.model.entity.OrderItem;
import com.company.project.domain.model.valueobject.Money;
import com.company.project.domain.model.valueobject.OrderStatus;
import com.company.project.domain.exception.AggregateException;

import java.util.ArrayList;
import java.util.List;

/**
 * 订单聚合根
 */
public class Order {

    private final OrderId orderId;
    private CustomerId customerId;
    private final List<OrderItem> items;
    private OrderStatus status;

    /**
     * 工厂方法：创建新订单
     */
    public static Order create(CustomerId customerId) {
        Order order = new Order();
        order.orderId = OrderId.generate();
        order.customerId = customerId;
        order.items = new ArrayList<>();
        order.status = OrderStatus.DRAFT;
        return order;
    }

    /**
     * 添加商品
     */
    public void addItem(ProductId productId, int quantity, Money price) {
        if (this.status != OrderStatus.DRAFT) {
            throw new AggregateException("只有草稿订单可以添加商品");
        }
        this.items.add(new OrderItem(productId, quantity, price));
    }

    /**
     * 下单
     */
    public void place() {
        if (this.items.isEmpty()) {
            throw new AggregateException("订单商品不能为空");
        }
        if (this.status != OrderStatus.DRAFT) {
            throw new AggregateException("只有草稿订单可以下单");
        }
        this.status = OrderStatus.PLACED;
    }

    /**
     * 取消订单
     */
    public void cancel(String reason) {
        if (this.status == OrderStatus.SHIPPED) {
            throw new AggregateException("已发货订单不可取消");
        }
        this.status = OrderStatus.CANCELLED;
    }

    // ========== Getters（只读） ==========

    public OrderId getOrderId() { return orderId; }
    public CustomerId getCustomerId() { return customerId; }
    public List<OrderItem> getItems() { return Collections.unmodifiableList(items); }
    public OrderStatus getStatus() { return status; }
    public Money getTotalAmount() {
        return items.stream()
            .map(OrderItem::getSubtotal)
            .reduce(Money.ZERO, Money::add);
    }
}
```
