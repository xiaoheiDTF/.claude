# application/service 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：应用层
> 包路径：`com.company.project.application.service`

---

## 1. 创建规则

### 什么时候创建
- 有新的业务用例需要编排时

### 创建什么
- 应用服务接口 + 实现类（单模块模式下 CQRS 简化，读写可混合）

### 一个业务对应几个文件
- 一个领域 = 1 个接口 + 1 个实现

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 接口 | 业务名+AppService | `OrderAppService` |
| 实现类 | 业务名+AppServiceImpl | `OrderAppServiceImpl` |

---

## 3. 代码质量规则

### 【强制】
- 不包含核心业务逻辑，只做编排
- 事务管理在此层（`@Transactional`）
- 调用领域服务完成核心逻辑
- 负责 DTO ↔ 领域对象转换

### 【禁止】
- 禁止核心业务规则（放在聚合根/领域服务中）
- 禁止直接操作 PO/Mapper

### 【推荐】
- 写操作加 `@Transactional`
- 读操作可跳过事务

---

## 4. 依赖规则

### 可引用
- `domain.service.*`
- `domain.repository.*`（接口）
- `domain.model.*`
- `domain.event.*`
- `interfaces.dto.*`
- `interfaces.assembler.*`

### 禁止引用
- `infrastructure.*`

---

## 5. AI 生成检查项

- [ ] 无核心业务逻辑
- [ ] 写操作有 @Transactional
- [ ] 调用领域服务
- [ ] DTO 转换正确

---

## 6. 代码模板

```java
public interface OrderAppService {
    OrderDTO createOrder(CreateOrderCommand cmd);
    OrderDTO getOrder(String orderId);
    void cancelOrder(String orderId, String reason);
}

@Service
public class OrderAppServiceImpl implements OrderAppService {

    private final OrderService orderService;
    private final OrderAssembler assembler;

    @Override
    @Transactional
    public OrderDTO createOrder(CreateOrderCommand cmd) {
        CreateOrderParam param = assembler.toParam(cmd);
        Order order = orderService.createOrder(param);
        return assembler.toDTO(order);
    }

    @Override
    public OrderDTO getOrder(String orderId) {
        Order order = orderService.getOrder(OrderId.of(orderId));
        return assembler.toDTO(order);
    }
}
```
