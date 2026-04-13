# infrastructure/persistence 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：基础设施层
> 所属模块：project-infrastructure
> 包路径：`com.company.project.infrastructure.persistence`

---

## 1. 创建规则

### 什么时候创建
- 需要定义数据库表对应的 PO 类时
- 需要创建 MyBatis Mapper 接口时

### 创建什么
- PO 类（持久化对象）
- Mapper 接口
- Mapper XML（SQL 定义）

### 一个业务对应几个文件
- 一张表 = 1 个 PO + 1 个 Mapper 接口 + 1 个 XML

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| PO 类 | 表名+PO | `OrderPO`, `OrderItemPO` |
| Mapper 接口 | 表名+Mapper | `OrderPOMapper` |
| XML | 表名+Mapper.xml | `OrderPOMapper.xml` |

---

## 3. 代码质量规则

### 【强制】
- PO 字段与数据库表一一对应
- 使用 MyBatis-Plus 时 Mapper 继承 `BaseMapper<PO>`
- SQL 写在 XML 中，不在 Mapper 接口用注解（复杂 SQL）

### 【推荐】
- PO 类使用 `@TableName` 指定表名
- PO 字段使用 `@TableId`、`@TableField`
- 使用 MyBatis-Plus 的 `BaseMapper` 简化 CRUD

---

## 4. 依赖规则

### 可引用
- MyBatis/MyBatis-Plus 注解
- Java 标准库

### 禁止引用
- `domain.*`（PO 不依赖领域对象）
- `application.*`

---

## 5. AI 生成检查项

- [ ] PO 字段与表对应
- [ ] Mapper 接口完整
- [ ] XML 中 SQL 正确
- [ ] 无业务逻辑

---

## 6. 代码模板

```java
@TableName("t_order")
public class OrderPO {
    @TableId(type = IdType.ASSIGN_ID)
    private Long id;
    private String orderId;
    private String customerId;
    private String status;
    private BigDecimal totalAmount;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
    // Getters + Setters
}

public interface OrderPOMapper extends BaseMapper<OrderPO> {
    // 自定义查询方法
    List<OrderPO> selectByCustomerId(@Param("customerId") String customerId);
}
```
