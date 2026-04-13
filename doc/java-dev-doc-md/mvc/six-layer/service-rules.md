# service 包开发规则（六层模式）

> 所属模式：六层 MVC
> 所属层：核心业务层
> 包路径：`com.company.project.service` / `service.impl`

---

## 1. 创建规则

- 一个业务场景对应一个 Service
- 接口 + 实现分离

## 2. 文件命名规则

业务名+Service / 业务名+ServiceImpl。

## 3. 代码质量规则

### 【强制】
- **Service 只做业务编排**，原子操作调用 Manager
- @Transactional 放在 Service 方法上
- 不在 Service 中直接写简单 CRUD（交给 Manager）

### 【推荐】
- Service 方法 = 多个 Manager 方法调用的编排

## 4. 依赖规则

- 可引用：`manager.*`, `dto.*`, `entity.*`, `common.*`, `exception.*`
- 禁止引用：`mapper.*`（通过 Manager 间接访问）

## 5. AI 生成检查项

- [ ] 只做编排，原子操作在 Manager
- [ ] 不直接调用 Mapper
- [ ] @Transactional 位置正确

## 6. 代码模板

```java
@Service
public class OrderServiceImpl implements OrderService {

    private final OrderManager orderManager;
    private final InventoryManager inventoryManager;

    @Override
    @Transactional
    public void createOrder(CreateOrderRequest request) {
        // 编排：先校验库存，再创建订单，再发通知
        inventoryManager.reserveItems(request.getItems());
        orderManager.createOrder(request);
        notificationManager.sendOrderCreated(request.getCustomerId());
    }
}
```
