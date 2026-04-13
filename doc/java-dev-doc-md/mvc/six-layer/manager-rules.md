# manager 包开发规则

> 所属模式：六层 MVC（独有层）
> 所属层：通用业务层
> 包路径：`com.company.project.manager` / `manager.impl`

---

## 1. 创建规则

### 什么时候创建
- 有可被多个 Service 复用的原子操作时
- 需要封装第三方 API 调用时
- 需要组合多个 Mapper 的操作时

### 创建什么
- Manager 接口 + 实现类

### 一个业务对应几个文件
- 一个原子服务领域 = 1 个接口 + 1 个实现

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 接口 | 功能名+Manager | `OrderManager`, `CacheManager` |
| 实现类 | 功能名+ManagerImpl | `OrderManagerImpl` |

---

## 3. 代码质量规则

### 【强制】
- 方法粒度小，保持原子性
- 可被多个 Service 复用
- 不做业务编排（编排是 Service 的职责）

### 【推荐】
- 第三方 API 封装放在 Manager 中
- 多 Mapper 组合查询放在 Manager 中
- 缓存操作封装放在 Manager 中

---

## 4. 依赖规则

### 可引用
- `mapper.*`
- `entity.*`
- `dto.*`
- `common.*`
- `exception.*`

### 禁止引用
- `service.*`（Manager 不依赖 Service）
- `controller.*`
- `openapi.*`

---

## 5. AI 生成检查项

- [ ] 方法粒度小、原子性
- [ ] 不做业务编排
- [ ] 不依赖 Service
- [ ] 可被多个 Service 复用

---

## 6. 代码模板

```java
public interface OrderManager {
    OrderDO createOrder(CreateOrderRequest request);
    OrderDO getOrder(Long id);
    void updateOrderStatus(Long id, String status);
}

@Component
public class OrderManagerImpl implements OrderManager {

    private final OrderMapper orderMapper;

    @Override
    public OrderDO createOrder(CreateOrderRequest request) {
        OrderDO order = new OrderDO();
        order.setCustomerId(request.getCustomerId());
        order.setStatus("DRAFT");
        order.setGmtCreate(LocalDateTime.now());
        orderMapper.insert(order);
        return order;
    }

    @Override
    public OrderDO getOrder(Long id) {
        return orderMapper.selectById(id);
    }
}
```
