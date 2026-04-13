# infrastructure/gateway 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：基础设施层
> 所属模块：project-infrastructure
> 包路径：`com.company.project.infrastructure.gateway`

---

## 1. 创建规则

### 什么时候创建
- 需要调用外部系统 API（第三方服务、其他微服务）时
- 需要封装外部调用的适配器时

### 创建什么
- Gateway 接口 + 实现类

### 一个业务对应几个文件
- 一个外部系统 = 1 个 Gateway 接口 + 1 个实现

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 接口 | 系统名+Gateway | `PaymentGateway`, `SmsGateway` |
| 实现类 | 系统名+GatewayImpl | `PaymentGatewayImpl` |

---

## 3. 代码质量规则

### 【强制】
- 使用适配器模式封装外部调用
- 处理网络异常和超时
- 记录外部调用日志
- 外部响应转换为内部 DTO

### 【推荐】
- 使用 RestTemplate 或 WebClient 调用 HTTP API
- 配置超时和重试策略

---

## 4. 依赖规则

### 可引用
- Spring 框架（`@Component`, `@Autowired`）
- HTTP 客户端
- `model.dto.*`

### 禁止引用
- `domain.*`
- `application.*`

---

## 5. AI 生成检查项

- [ ] 有异常处理和超时
- [ ] 外部响应转为内部 DTO
- [ ] 有调用日志

---

## 6. 代码模板

```java
public interface PaymentGateway {
    PaymentResult charge(String orderId, BigDecimal amount);
}

@Component
public class PaymentGatewayImpl implements PaymentGateway {

    private final RestTemplate restTemplate;

    @Override
    public PaymentResult charge(String orderId, BigDecimal amount) {
        try {
            // 调用外部支付系统
            PaymentResponse response = restTemplate.postForObject(
                "/api/payments/charge",
                new PaymentRequest(orderId, amount),
                PaymentResponse.class
            );
            return PaymentResult.success(response.getTransactionId());
        } catch (RestClientException e) {
            log.error("支付调用失败: orderId={}", orderId, e);
            return PaymentResult.fail("PAYMENT_ERROR", e.getMessage());
        }
    }
}
```
