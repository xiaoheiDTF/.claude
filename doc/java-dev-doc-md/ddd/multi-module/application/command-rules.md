# application/command 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：应用层
> 所属模块：project-application
> 包路径：`com.company.project.application.command`

---

## 1. 创建规则

### 什么时候创建
- 有新的写操作（增/改/删）业务场景时
- CQRS 模式下的 Command 端

### 创建什么
- Command 对象（入参封装）+ CommandHandler（处理类）

### 一个业务对应几个文件
- 一个写操作 = 1 个 Command 类 + 1 个 Handler 类

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| Command 类 | 动词+名词+Command | `CreateOrderCommand`, `CancelOrderCommand` |
| Handler 类 | 动词+名词+CommandHandler | `CreateOrderCommandHandler` |

---

## 3. 代码质量规则

### 【强制】
- Command 类是不可变对象（final 字段）
- Handler 不包含业务逻辑，只做编排
- Handler 负责事务管理（`@Transactional`）
- Handler 负责调用领域服务和 DTO 转换

### 【禁止】
- 禁止在 Handler 中编写核心业务规则
- 禁止直接操作数据库（通过领域服务/仓储）

### 【推荐】
- Command 类使用 Builder 模式创建
- 每个 Handler 只处理一个 Command

---

## 4. 依赖规则

### 可引用
- `domain.service.*`（领域服务）
- `domain.repository.*`（仓储接口）
- `domain.model.*`（领域模型）
- `domain.event.*`
- `application.assembler.*`
- `model.dto.*`（共享 DTO）

### 禁止引用
- `infrastructure.*`
- `client.*`

---

## 5. AI 生成检查项

- [ ] Command 类字段是 final
- [ ] Handler 无业务逻辑（只有编排）
- [ ] 事务注解 `@Transactional` 在 Handler 方法上
- [ ] 调用领域服务而非直接操作数据库
- [ ] 异常正确处理和转换

---

## 6. 代码模板

```java
package com.company.project.application.command;

// ===== Command =====
public final class CreateOrderCommand {
    private final Long customerId;
    private final List<OrderItemDTO> items;

    // 构造器 + Getters
}

// ===== Handler =====
@Component
public class CreateOrderCommandHandler {

    private final OrderService orderService;
    private final OrderAssembler assembler;

    @Transactional
    public OrderDTO handle(CreateOrderCommand command) {
        CreateOrderParam param = assembler.toParam(command);
        Order order = orderService.createOrder(param);
        return assembler.toDTO(order);
    }
}
```
