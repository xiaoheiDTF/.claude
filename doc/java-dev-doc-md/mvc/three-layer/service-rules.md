# service 包开发规则

> 所属模式：三层 MVC
> 所属层：业务逻辑层
> 包路径：`com.company.project.service` / `service.impl`

---

## 1. 创建规则

- 一个 Controller 对应一个 Service
- 接口 + 实现分离

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 接口 | 业务名+Service | `OrderService` |
| 实现类 | 业务名+ServiceImpl | `OrderServiceImpl` |

## 3. 代码质量规则

### 【强制】
- 所有业务逻辑在此层
- @Transactional 放在实现类方法上
- 接收 Request/DTO，返回 DTO/VO

### 【禁止】
- 直接操作 HttpServletRequest
- 返回 DO 到 Controller

### 【推荐】
- 方法命名：createXxx, deleteXxx, updateXxx, getXxx, listXxx

## 4. 依赖规则

- 可引用：`mapper.*`, `entity.*`, `dto.*`, `common.*`, `exception.*`
- 禁止引用：`controller.*`

## 5. AI 生成检查项

- [ ] 接口+实现分离
- [ ] 业务逻辑完整
- [ ] @Transactional 位置正确
- [ ] 不返回 DO

## 6. 代码模板

```java
public interface OrderService {
    void createOrder(CreateOrderRequest request);
    OrderVO getOrder(Long id);
    void cancelOrder(Long id);
}

@Service
public class OrderServiceImpl implements OrderService {

    private final OrderMapper orderMapper;

    @Override
    @Transactional
    public void createOrder(CreateOrderRequest request) {
        OrderDO order = new OrderDO();
        order.setCustomerId(request.getCustomerId());
        order.setStatus("DRAFT");
        orderMapper.insert(order);
    }

    @Override
    public OrderVO getOrder(Long id) {
        OrderDO order = orderMapper.selectById(id);
        return OrderConverter.toVO(order);
    }
}
```
