# interfaces/controller 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：接口层
> 包路径：`com.company.project.interfaces.controller`

---

## 1. 创建规则

### 什么时候创建
- 需要对外暴露 REST API 时
- 一个业务领域对应一个 Controller

### 创建什么
- Controller 类

### 一个业务对应几个文件
- 一个聚合/领域 = 1 个 Controller

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| Controller | 业务名+Controller | `OrderController`, `UserController` |

---

## 3. 代码质量规则

### 【强制】
- 只做参数校验、调用应用服务、组装响应
- 使用 `@Valid` 做参数校验
- 返回统一 `Result<T>`
- 入参使用 dto 包中的 Command/Query 对象

### 【禁止】
- 禁止包含业务逻辑
- 禁止直接调用 Repository
- 禁止注入 Infrastructure 层的对象

### 【推荐】
- RESTful URL 设计：资源用名词复数
- 一个 Controller 方法不超过 15 行

---

## 4. 依赖规则

### 可引用
- `application.service.*`
- `interfaces.dto.*`
- `interfaces.assembler.*`
- `domain.model.valueobject.*`（仅用于异常/枚举）
- `domain.exception.*`

### 禁止引用
- `domain.model.aggregate.*`
- `domain.repository.*`
- `infrastructure.*`

---

## 5. AI 生成检查项

- [ ] 无业务逻辑
- [ ] 使用 @Valid 校验
- [ ] 返回 Result<T>
- [ ] 只调用应用服务
- [ ] RESTful URL

---

## 6. 代码模板

```java
@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {

    private final OrderAppService orderAppService;

    @PostMapping
    public Result<OrderVO> createOrder(@Valid @RequestBody CreateOrderCommand cmd) {
        OrderDTO dto = orderAppService.createOrder(cmd);
        return Result.success(OrderVO.from(dto));
    }

    @GetMapping("/{orderId}")
    public Result<OrderVO> getOrder(@PathVariable String orderId) {
        OrderDTO dto = orderAppService.getOrder(orderId);
        return Result.success(OrderVO.from(dto));
    }
}
```
