# infrastructure/repository 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：基础设施层
> 所属模块：project-infrastructure
> 包路径：`com.company.project.infrastructure.repository`

---

## 1. 创建规则

### 什么时候创建
- domain 模块定义了 Repository 接口时，必须在此创建实现类

### 创建什么
- Repository 接口的实现类

### 一个业务对应几个文件
- 一个领域 Repository 接口 = 1 个实现类

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 实现类 | 聚合名+RepositoryImpl | `OrderRepositoryImpl` |

---

## 3. 代码质量规则

### 【强制】
- 实现领域层的 Repository 接口
- 负责聚合根 ↔ PO 的转换
- 操作粒度是聚合根
- 使用 `@Repository` 注解

### 【禁止】
- 禁止在实现类中添加领域层未定义的方法
- 禁止返回 PO 对象到领域层

### 【推荐】
- 注入 Mapper/DAO 完成数据库操作
- 使用 MapStruct 做 聚合根 ↔ PO 转换
- 实现 Update-Tracing（只更新变更字段）

---

## 4. 依赖规则

### 可引用
- `domain.repository.*`（实现的接口）
- `domain.model.aggregate.*`
- `domain.model.valueobject.*`
- `infrastructure.persistence.*`（PO、Mapper）
- Spring 注解（`@Repository`, `@Autowired`）
- MyBatis/JPA 注解

### 禁止引用
- `application.*`
- `client.*`

---

## 5. AI 生成检查项

- [ ] 实现了 domain 层的接口
- [ ] 聚合根 ↔ PO 转换正确
- [ ] 所有领域接口方法都已实现
- [ ] 不返回 PO 到上层

---

## 6. 代码模板

```java
@Repository
public class OrderRepositoryImpl implements OrderRepository {

    private final OrderPOMapper orderPOMapper;
    private final OrderItemPOMapper orderItemPOMapper;

    @Override
    public Optional<Order> findById(OrderId orderId) {
        OrderPO po = orderPOMapper.selectById(orderId.getValue());
        if (po == null) return Optional.empty();
        List<OrderItemPO> items = orderItemPOMapper.selectByOrderId(orderId.getValue());
        return Optional.of(OrderConverter.toDomain(po, items));
    }

    @Override
    public void save(Order order) {
        OrderPO po = OrderConverter.toPO(order);
        if (order.isNew()) {
            orderPOMapper.insert(po);
        } else {
            orderPOMapper.updateById(po);
        }
        // 保存聚合内部的实体
        saveOrderItems(order);
    }
}
```
