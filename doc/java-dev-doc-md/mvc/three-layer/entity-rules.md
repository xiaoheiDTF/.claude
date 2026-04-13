# entity 包开发规则

> 所属模式：三层 MVC
> 所属层：数据对象层
> 包路径：`com.company.project.entity`（或 `domain`）

---

## 1. 创建规则

- 一张表对应一个 Entity/DO 类

## 2. 文件命名规则

表名+DO 或 表名（如 `OrderDO`, `Order`）。

## 3. 代码质量规则

### 【强制】
- 字段与数据库表一一对应
- 使用包装类（`Integer` 非 `int`）
- 使用 `@TableName`、`@TableId` 等注解

### 【推荐】
- 包含 gmtCreate、gmtModified 字段
- 使用 MyBatis-Plus 注解

## 4. 依赖规则

- 可引用：Java 标准库、MyBatis-Plus 注解
- 禁止引用：`controller.*`, `service.*`

## 5. AI 生成检查项

- [ ] 字段与表对应
- [ ] 使用包装类
- [ ] 有 MyBatis-Plus 注解

## 6. 代码模板

```java
@TableName("t_order")
public class OrderDO {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long customerId;
    private String status;
    private BigDecimal totalAmount;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
    // Getters + Setters
}
```
