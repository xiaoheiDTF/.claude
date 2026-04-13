# controller 包开发规则（六层模式）

> 所属模式：六层 MVC
> 所属层：Web 层
> 包路径：`com.company.project.controller`

---

## 核心规则

与三层模式 controller-rules.md 一致，额外注意：
- 六层模式下 Controller 只调用 Service，不直接调用 Manager
- Service 做编排，Manager 做原子操作

## 代码模板

```java
@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {
    private final OrderService orderService;

    @PostMapping
    public Result<Void> createOrder(@Valid @RequestBody CreateOrderRequest request) {
        orderService.createOrder(request);
        return Result.success();
    }
}
```
