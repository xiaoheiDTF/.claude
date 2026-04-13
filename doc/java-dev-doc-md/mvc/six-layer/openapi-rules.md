# openapi 包开发规则

> 所属模式：六层 MVC
> 所属层：开放接口层
> 包路径：`com.company.project.openapi`

---

## 1. 创建规则

### 什么时候创建
- 需要将 Service 封装为 RPC 接口（Feign/Dubbo）时
- 需要通过网关对外暴露接口时

### 创建什么
- API 接口定义类

## 2. 文件命名规则

业务名+Api 或 业务名+Facade，如 `OrderApi`, `OrderFacade`。

## 3. 代码质量规则

### 【强制】
- 只做接口封装，调用 Service 层
- 入参和出参使用 DTO

### 【禁止】
- 包含业务逻辑
- 直接调用 Manager/Mapper

## 4. 依赖规则

- 可引用：`service.*`, `dto.*`
- 禁止引用：`manager.*`, `mapper.*`, `entity.*`

## 5. AI 生成检查项

- [ ] 只调用 Service
- [ ] 使用 DTO 传参/返回
- [ ] 无业务逻辑

## 6. 代码模板

```java
@FeignClient(name = "order-service")
public interface OrderApi {
    @PostMapping("/api/v1/orders")
    Result<Void> createOrder(@RequestBody CreateOrderRequest request);

    @GetMapping("/api/v1/orders/{id}")
    Result<OrderVO> getOrder(@PathVariable Long id);
}
```
