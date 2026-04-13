# interfaces/dto 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：接口层
> 包路径：`com.company.project.interfaces.dto`

---

## 1. 创建规则

### 什么时候创建
- 需要定义 API 入参或出参时
- 单模块模式下合并了 Command、Query、VO

### 创建什么
- Command（写操作入参）
- Query（读操作入参）
- VO（返回给前端的视图对象）

### 一个业务对应几个文件
- 一个聚合 = Command 类 + Query 类 + VO 类

---

## 2. 文件命名规则

| 类型 | 命名 | 示例 |
|------|------|------|
| 写入参数 | 动词+名词+Command | `CreateOrderCommand` |
| 查询参数 | 动词+名词+Query | `ListOrdersQuery` |
| 视图对象 | 业务名+VO | `OrderVO`, `OrderDetailVO` |

---

## 3. 代码质量规则

### 【强制】
- 使用 Bean Validation 注解校验入参
- VO 字段用包装类（`Integer` 非 `int`）
- 无业务逻辑

### 【推荐】
- Command 和 Query 分开定义（即使同包）
- VO 中日期使用 `String`（ISO 格式）或 `LocalDateTime`

---

## 4. 依赖规则

### 可引用
- Java 标准库、Bean Validation

### 禁止引用
- `domain.*`
- `infrastructure.*`

---

## 5. AI 生成检查项

- [ ] 入参有 Bean Validation
- [ ] VO 用包装类
- [ ] 无业务逻辑

---

## 6. 代码模板

```java
// Command
public class CreateOrderCommand {
    @NotNull(message = "客户ID不能为空")
    private Long customerId;
    @NotEmpty(message = "商品列表不能为空")
    private List<OrderItemDTO> items;
}

// Query
public class ListOrdersQuery {
    private Long customerId;
    private String status;
    private int pageNum = 1;
    private int pageSize = 20;
}

// VO
public class OrderVO {
    private String orderId;
    private String status;
    private BigDecimal totalAmount;
    private List<OrderItemVO> items;
    private LocalDateTime createTime;
}
```
