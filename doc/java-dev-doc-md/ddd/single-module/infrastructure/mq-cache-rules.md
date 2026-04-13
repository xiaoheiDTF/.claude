# infrastructure/mq-cache 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：基础设施层
> 包路径：`com.company.project.infrastructure.mq-cache`

---

## 1-5. 核心规则

与多模块 mq-cache-rules.md 一致：
- MQ：Producer/Consumer，幂等消费，失败重试
- Cache：统一 key 前缀，设置过期时间
- 可引用：Spring、MQ/Redis 客户端、`domain.event.*`、`model.*`
- 禁止引用：`domain.model.aggregate.*`、`interfaces.*`、`application.*`

## 6. 代码模板

```java
@Component
public class OrderEventProducer {
    private final RocketMQTemplate rocketMQTemplate;

    public void sendOrderPlacedEvent(OrderPlacedEvent event) {
        rocketMQTemplate.convertAndSend("order-placed-topic", event);
    }
}

@Component
public class OrderCacheService {
    private static final String KEY_PREFIX = "order:";
    private static final Duration TTL = Duration.ofHours(24);
    private final RedisTemplate<String, Object> redisTemplate;

    public void put(OrderDTO order) {
        redisTemplate.opsForValue().set(KEY_PREFIX + order.getOrderId(), order, TTL);
    }
}
```
