# client/api 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：对外接口层
> 所属模块：project-client
> 包路径：`com.company.project.client.api`

---

## 1. 创建规则

### 什么时候创建
- 需要对其他微服务暴露接口时
- 需要 Feign/Dubbo 远程调用定义时

### 创建什么
- API 接口定义 + 请求/响应 DTO

### 一个业务对应几个文件
- 一个对外服务 = 1 个 API 接口 + 相关 DTO

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| API 接口 | 业务名+Api / +Facade | `OrderApi`, `OrderFacade` |
| 请求 DTO | 操作名+Request | `CreateOrderRequest` |
| 响应 DTO | 业务名+Response | `OrderResponse` |

---

## 3. 代码质量规则

### 【强制】
- 只定义接口，不含实现
- DTO 使用 Bean Validation 注解校验
- DTO 字段与内部模型隔离

### 【推荐】
- 使用 Feign 接口风格（`@FeignClient`）
- 版本化 API（如 `/api/v1/orders`）

---

## 4. 依赖规则

### 可引用
- `model.dto.*`（共享 DTO）
- Bean Validation 注解
- Feign/Spring Web 注解

### 禁止引用
- `domain.*`
- `application.*`
- `infrastructure.*`

---

## 5. AI 生成检查项

- [ ] 只有接口定义，无实现
- [ ] DTO 有 Bean Validation 注解
- [ ] 不依赖内部领域模型

---

## 6. 代码模板

```java
@FeignClient(name = "order-service")
public interface OrderApi {

    @PostMapping("/api/v1/orders")
    Result<OrderResponse> createOrder(@Valid @RequestBody CreateOrderRequest request);

    @GetMapping("/api/v1/orders/{orderId}")
    Result<OrderResponse> getOrder(@PathVariable String orderId);
}
```
