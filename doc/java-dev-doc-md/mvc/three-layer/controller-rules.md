# controller 包开发规则

> 所属模式：三层 MVC
> 所属层：控制层
> 包路径：`com.company.project.controller`

---

## 1. 创建规则

- 一个业务领域对应一个 Controller
- 需要 REST API 时创建

## 2. 文件命名规则

业务名+Controller，如 `OrderController`。

## 3. 代码质量规则

### 【强制】
- 只做参数校验（`@Valid`）和调用 Service
- 返回统一 `Result<T>`
- 入参超过 2 个封装为对象
- RESTful URL

### 【禁止】
- 包含业务逻辑
- 直接调用 Mapper/DAO
- 返回 DO/Entity 到前端

### 【推荐】
- 方法不超过 15 行
- URL 用名词复数 `/orders`

## 4. 依赖规则

- 可引用：`service.*`, `dto.*`, `common.*`, `exception.*`
- 禁止引用：`mapper.*`

## 5. AI 生成检查项

- [ ] 无业务逻辑
- [ ] @Valid 校验
- [ ] Result<T> 返回
- [ ] RESTful URL
- [ ] 不返回 DO

## 6. 代码模板

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

    @GetMapping("/{id}")
    public Result<OrderVO> getOrder(@PathVariable Long id) {
        return Result.success(orderService.getOrder(id));
    }
}
```
