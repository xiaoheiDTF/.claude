# mapper/dao 包开发规则

> 所属模式：三层 MVC
> 所属层：数据访问层
> 包路径：`com.company.project.mapper`（或 `dao`）

---

## 1. 创建规则

- 一张表对应一个 Mapper 接口
- 需要 CRUD 操作时创建

## 2. 文件命名规则

表名+Mapper（或表名+Dao），如 `OrderMapper`。

## 3. 代码质量规则

### 【强制】
- 只做数据存取，无业务逻辑
- 复杂 SQL 写在 XML 中
- 继承 `BaseMapper<T>`（MyBatis-Plus）

### 【禁止】
- 包含业务逻辑

## 4. 依赖规则

- 可引用：`entity.*`（DO 类型）
- 禁止引用：`service.*`, `controller.*`, `dto.*`

## 5. AI 生成检查项

- [ ] 无业务逻辑
- [ ] SQL 在 XML 中
- [ ] 继承 BaseMapper

## 6. 代码模板

```java
public interface OrderMapper extends BaseMapper<OrderDO> {
    List<OrderDO> selectByCustomerId(@Param("customerId") Long customerId);
}
```
