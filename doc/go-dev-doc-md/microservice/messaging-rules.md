# 消息队列规则

> 所属模式：微服务架构
> 包路径：`internal/event`

---

## 1. 创建规则

- 一个事件类型对应一个文件
- 事件的发布和订阅分离

## 2. 文件命名规则

- 事件定义：`order_events.go`
- 发布器：`publisher.go` 或 `order_publisher.go`
- 消费者：`consumer.go` 或 `order_consumer.go`

## 3. 代码质量规则

### 【强制】
- 消息体使用 JSON 或 Protobuf 序列化
- 消费者必须幂等（重复消费不出错）
- 使用 `context.Context` 控制消费者生命周期
- 错误消息进入死信队列（DLQ）

### 【禁止】
- 在消息中传递大对象（超过 1MB）
- 消费者中做长时间阻塞操作
- 忽略消息确认（ACK/NACK）

### 【推荐】
- 使用 CloudEvents 标准格式
- 消息包含 trace ID 用于链路追踪
- 使用 retry + exponential backoff

## 4. 事件定义模板

```go
package event

import "time"

// OrderCreatedEvent 订单创建事件
type OrderCreatedEvent struct {
    EventID   string    `json:"event_id"`
    EventType string    `json:"event_type"` // "order.created"
    Timestamp time.Time `json:"timestamp"`
    Data      OrderData `json:"data"`
}

type OrderData struct {
    OrderID int64  `json:"order_id"`
    UserID  int64  `json:"user_id"`
    Status  string `json:"status"`
    Total   int64  `json:"total"`
}
```

## 5. Publisher 模板

```go
package event

import (
    "context"
    "encoding/json"
    "fmt"
    "time"

    "github.com/segmentio/kafka-go"
)

type OrderPublisher struct {
    writer *kafka.Writer
}

func NewOrderPublisher(brokers []string, topic string) *OrderPublisher {
    return &OrderPublisher{
        writer: &kafka.Writer{
            Addr:         kafka.TCP(brokers...),
            Topic:        topic,
            Balancer:     &kafka.LeastBytes{},
            RequiredAcks: kafka.RequireAll,
        },
    }
}

func (p *OrderPublisher) PublishOrderCreated(ctx context.Context, evt *OrderCreatedEvent) error {
    data, err := json.Marshal(evt)
    if err != nil {
        return fmt.Errorf("marshal event: %w", err)
    }

    return p.writer.WriteMessages(ctx, kafka.Message{
        Key:   []byte(fmt.Sprintf("%d", evt.Data.OrderID)),
        Value: data,
        Headers: []kafka.Header{
            {Key: "event-type", Value: []byte(evt.EventType)},
        },
    })
}

func (p *OrderPublisher) Close() error {
    return p.writer.Close()
}
```

## 6. Consumer 模板

```go
package event

import (
    "context"
    "encoding/json"
    "log/slog"

    "github.com/segmentio/kafka-go"
)

type OrderConsumer struct {
    reader  *kafka.Reader
    handler func(ctx context.Context, evt *OrderCreatedEvent) error
    logger  *slog.Logger
}

func NewOrderConsumer(brokers []string, topic, groupID string, handler func(ctx context.Context, evt *OrderCreatedEvent) error, logger *slog.Logger) *OrderConsumer {
    return &OrderConsumer{
        reader: kafka.NewReader(kafka.ReaderConfig{
            Brokers:  brokers,
            Topic:    topic,
            GroupID:  groupID,
            MinBytes: 10e3,
            MaxBytes: 10e6,
        }),
        handler: handler,
        logger:  logger,
    }
}

func (c *OrderConsumer) Run(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
        }

        msg, err := c.reader.ReadMessage(ctx)
        if err != nil {
            if ctx.Err() != nil {
                return ctx.Err()
            }
            c.logger.Error("read message", "error", err)
            continue
        }

        var evt OrderCreatedEvent
        if err := json.Unmarshal(msg.Value, &evt); err != nil {
            c.logger.Error("unmarshal event", "error", err, "offset", msg.Offset)
            continue
        }

        // 幂等处理
        if err := c.handler(ctx, &evt); err != nil {
            c.logger.Error("handle event", "error", err, "order_id", evt.Data.OrderID)
            // 可选：发到死信队列
            continue
        }

        c.logger.Info("event processed", "order_id", evt.Data.OrderID)
    }
}

func (c *OrderConsumer) Close() error {
    return c.reader.Close()
}
```
