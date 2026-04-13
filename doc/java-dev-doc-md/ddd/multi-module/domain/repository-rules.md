# domain/repository 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：领域层
> 所属模块：project-domain
> 包路径：`com.company.project.domain.repository`

---

## 1. 创建规则

### 什么时候创建
- 每个聚合根对应一个 Repository 接口
- 聚合根需要持久化和查询时

### 创建什么
- 只创建接口，**不创建实现类**（实现在 infrastructure 模块）

### 一个业务对应几个文件
- 一个聚合根 = 1 个 Repository 接口

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 接口 | 聚合名+Repository | `OrderRepository`, `UserRepository` |

---

## 3. 代码质量规则

### 【强制】
- 只定义接口，无实现
- 操作粒度是聚合根，不是单个实体
- 提供基本的 CRUD 方法（findById, save, delete）
- 使用领域对象（聚合根、值对象）作为参数和返回值
- 接口不暴露任何技术实现细节（如分页参数、SQL 细节）

### 【禁止】
- 禁止实现类放在此包（放 infrastructure/repository）
- 禁止使用技术框架类型作为参数（如 JPA 的 Pageable）
- 禁止方法返回 PO/DO（返回领域对象）
- 禁止使用 `@Autowired` 等注解

### 【推荐】
- 继承通用 `Repository<T>` 基础接口（如果有）
- 提供业务相关的查询方法（如 `findByCustomerId`）

---

## 4. 依赖规则

### 可引用
- `domain.model.aggregate.*`（聚合根类型）
- `domain.model.valueobject.*`（ID 等值对象类型）

### 禁止引用
- `infrastructure.*`
- `application.*`
- 任何技术框架

---

## 5. AI 生成检查项

- [ ] 只有接口，无实现
- [ ] 使用聚合根作为操作粒度
- [ ] 参数和返回值都是领域对象
- [ ] 无技术框架注解
- [ ] 方法命名语义清晰

---

## 6. 代码模板

```java
package com.company.project.domain.repository;

import com.company.project.domain.model.aggregate.Order;
import com.company.project.domain.model.valueobject.OrderId;
import com.company.project.domain.model.valueobject.CustomerId;

import java.util.List;
import java.util.Optional;

/**
 * 订单仓储接口
 * 注意：只有接口定义，实现在 infrastructure 模块
 */
public interface OrderRepository {

    /**
     * 根据ID查找订单
     */
    Optional<Order> findById(OrderId orderId);

    /**
     * 根据客户ID查找订单列表
     */
    List<Order> findByCustomerId(CustomerId customerId);

    /**
     * 保存订单（新增或更新）
     */
    void save(Order order);

    /**
     * 删除订单
     */
    void delete(Order order);
}
```
