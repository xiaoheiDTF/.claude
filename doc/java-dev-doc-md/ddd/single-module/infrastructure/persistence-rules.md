# infrastructure/persistence 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：基础设施层
> 包路径：`com.company.project.infrastructure.persistence`

---

## 1-5. 核心规则

与多模块 persistence-rules.md 一致：
- PO 类 + Mapper 接口 + XML
- 一张表 = 1 PO + 1 Mapper + 1 XML
- 禁止引用：`domain.*`、`interfaces.*`、`application.*`

## 6. 代码模板

```java
@TableName("t_order")
public class OrderPO {
    @TableId(type = IdType.ASSIGN_ID)
    private Long id;
    private String orderId;
    private String customerId;
    private String status;
    private LocalDateTime gmtCreate;
    // Getters + Setters
}

public interface OrderPOMapper extends BaseMapper<OrderPO> {
    List<OrderPO> selectByCustomerId(@Param("customerId") String customerId);
}
```
