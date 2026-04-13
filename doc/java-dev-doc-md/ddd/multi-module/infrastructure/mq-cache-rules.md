# infrastructure/mq + cache 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：基础设施层
> 所属模块：project-infrastructure
> 包路径：`com.company.project.infrastructure.mq` / `infrastructure.cache`

---

## 1. 创建规则

### 什么时候创建
- 需要发送/消费消息队列消息时
- 需要使用缓存（Redis）时
- 领域事件需要异步投递时

### 创建什么
- MQ：Producer 类、Consumer/Listener 类
- Cache：CacheService 类

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| Producer | 业务名+Producer | `OrderEventProducer` |
| Consumer | 业务名+Consumer / +Listener | `OrderEventConsumer` |
| Cache | 业务名+CacheService | `OrderCacheService` |

---

## 3. 代码质量规则

### 【强制】
- MQ 消息发送有失败处理（重试/死信）
- 消费者幂等性保证
- 缓存 key 使用统一前缀+业务标识
- 缓存设置合理的过期时间

### 【推荐】
- 消息体使用 JSON 格式
- 缓存使用 Spring Cache 注解或 RedisTemplate

---

## 4. 依赖规则

### 可引用
- Spring 框架
- MQ/Redis 客户端
- `domain.event.*`（领域事件类型）
- `model.dto.*`

### 禁止引用
- `domain.model.aggregate.*`（不依赖聚合根）
- `domain.model.entity.*`
- `application.*`

---

## 5. AI 生成检查项

- [ ] MQ 消费者有幂等处理
- [ ] 缓存 key 有统一前缀
- [ ] 消息发送有异常处理
- [ ] 缓存有过期时间

---

## 6. 代码模板

```java
// MQ Producer
@Component
public class OrderEventProducer {

    private final RocketMQTemplate rocketMQTemplate;

    public void sendOrderPlacedEvent(OrderPlacedEvent event) {
        try {
            rocketMQTemplate.convertAndSend("order-placed-topic", event);
        } catch (Exception e) {
            log.error("发送订单事件失败: orderId={}", event.getOrderId(), e);
            // 重试或记录到死信表
        }
    }
}

// Cache Service
@Component
public class OrderCacheService {

    private final RedisTemplate<String, Object> redisTemplate;

    private static final String KEY_PREFIX = "order:";
    private static final Duration TTL = Duration.ofHours(24);

    public void put(OrderDTO order) {
        redisTemplate.opsForValue().set(KEY_PREFIX + order.getOrderId(), order, TTL);
    }

    public OrderDTO get(String orderId) {
        return (OrderDTO) redisTemplate.opsForValue().get(KEY_PREFIX + orderId);
    }
}
```
