# application/query 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：应用层
> 所属模块：project-application
> 包路径：`com.company.project.application.query`

---

## 1. 创建规则

### 什么时候创建
- 有新的读操作（查询/列表/分页）业务场景时
- CQRS 模式下的 Query 端

### 创建什么
- Query 对象（查询参数）+ QueryHandler（处理类）

### 一个业务对应几个文件
- 一个读操作 = 1 个 Query 类 + 1 个 Handler 类

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| Query 类 | 动词+名词+Query | `FindOrderQuery`, `ListOrdersQuery` |
| Handler 类 | 动词+名词+QueryHandler | `FindOrderQueryHandler` |

---

## 3. 代码质量规则

### 【强制】
- Query 端可直接查询数据库（不经过领域层）
- 返回 DTO/VO，不返回领域对象
- 查询方法不加 `@Transactional`（只读操作）

### 【禁止】
- 禁止在 Query Handler 中修改数据
- 禁止返回 DO/PO 到上层

### 【推荐】
- 复杂查询可用 JPA Specification 或 MyBatis 动态 SQL
- 分页查询使用统一的分页参数对象

---

## 4. 依赖规则

### 可引用
- `domain.repository.*`（仓储接口，用于简单查询）
- `application.assembler.*`
- `model.dto.*`

### 禁止引用
- `domain.model.aggregate.*`（不加载聚合根）
- `domain.service.*`（不调用领域服务）
- `infrastructure.*`

---

## 5. AI 生成检查项

- [ ] 无数据修改操作
- [ ] 返回 DTO 而非领域对象
- [ ] 无 @Transactional（只读）

---

## 6. 代码模板

```java
// ===== Query =====
public final class FindOrderQuery {
    private final String orderId;
    // 构造器 + Getter
}

// ===== Handler =====
@Component
public class FindOrderQueryHandler {

    private final OrderRepository orderRepository;
    private final OrderAssembler assembler;

    public OrderDTO handle(FindOrderQuery query) {
        return orderRepository.findById(OrderId.of(query.getOrderId()))
            .map(assembler::toDTO)
            .orElseThrow(() -> new BusinessException("ORDER_NOT_FOUND", "订单不存在"));
    }
}
```
