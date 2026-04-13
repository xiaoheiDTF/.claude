# dto 包开发规则

> 所属模式：三层 MVC
> 所属层：数据传输层
> 包路径：`com.company.project.dto`

---

## 1. 创建规则

- 需要定义入参或出参时创建
- 子目录：`request/`, `vo/`, `query/`（可选，也可平铺）

## 2. 文件命名规则

| 类型 | 命名 | 示例 |
|------|------|------|
| 入参 | 操作名+Request | `CreateOrderRequest` |
| 查询参数 | 业务名+Query | `OrderListQuery` |
| 出参 | 业务名+VO | `OrderVO` |

## 3. 代码质量规则

### 【强制】
- Request 使用 Bean Validation
- VO 使用包装类
- 无业务逻辑

### 【禁止】
- 包含业务方法

## 4. 依赖规则

- 可引用：Java 标准库、Bean Validation
- 禁止引用：`mapper.*`, `service.*`

## 5. AI 生成检查项

- [ ] Request 有 @Valid 注解
- [ ] VO 用包装类
- [ ] 无业务逻辑

## 6. 代码模板

```java
public class CreateOrderRequest {
    @NotNull(message = "客户ID不能为空")
    private Long customerId;
    @NotEmpty(message = "商品列表不能为空")
    private List<OrderItemDTO> items;
}

public class OrderVO {
    private Long id;
    private String status;
    private BigDecimal totalAmount;
    private LocalDateTime createTime;
}
```
