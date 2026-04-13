# 外部服务适配器规则

> 所属模式：Clean Architecture
> 所属层：Infrastructure（最外层）
> 包路径：`internal/infrastructure/gateway`

---

## 1. 创建规则

- 为每个外部服务（支付、通知、第三方 API）创建适配器
- 适配器实现 domain 层定义的接口

## 2. 文件命名规则

服务名 + `_gateway.go`，如 `payment_gateway.go`, `notify_gateway.go`。

## 3. 代码质量规则

### 【强制】
- 实现 domain 层定义的端口接口
- 封装外部 API 调用细节
- 超时使用 `context.Context`
- 错误包装为领域错误

### 【禁止】
- 将外部 API 的类型暴露到 domain 层
- 在适配器中做业务决策

### 【推荐】
- 使用 `http.Client` 并配置合理超时
- 实现重试和熔断机制
- 记录外部调用日志

## 4. 代码模板

```go
package gateway

import (
    "bytes"
    "context"
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "time"

    "myproject/internal/domain/repository"
)

// PaymentGateway 实现领域层的支付端口
var _ repository.PaymentPort = (*PaymentGateway)(nil)

type PaymentGateway struct {
    client  *http.Client
    baseURL string
    apiKey  string
}

func NewPaymentGateway(baseURL, apiKey string) *PaymentGateway {
    return &PaymentGateway{
        client: &http.Client{
            Timeout: 10 * time.Second,
        },
        baseURL: baseURL,
        apiKey:  apiKey,
    }
}

func (g *PaymentGateway) Charge(ctx context.Context, req *repository.ChargeRequest) (*repository.ChargeResult, error) {
    body, err := json.Marshal(map[string]any{
        "amount":   req.Amount,
        "currency": req.Currency,
        "order_id": req.OrderID,
    })
    if err != nil {
        return nil, fmt.Errorf("marshal charge request: %w", err)
    }

    httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, g.baseURL+"/charges", bytes.NewReader(body))
    if err != nil {
        return nil, fmt.Errorf("create charge request: %w", err)
    }
    httpReq.Header.Set("Authorization", "Bearer "+g.apiKey)
    httpReq.Header.Set("Content-Type", "application/json")

    resp, err := g.client.Do(httpReq)
    if err != nil {
        return nil, fmt.Errorf("send charge request: %w", err)
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        respBody, _ := io.ReadAll(resp.Body)
        return nil, fmt.Errorf("charge failed (status %d): %s", resp.StatusCode, string(respBody))
    }

    var result repository.ChargeResult
    if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
        return nil, fmt.Errorf("decode charge response: %w", err)
    }

    return &result, nil
}
```
