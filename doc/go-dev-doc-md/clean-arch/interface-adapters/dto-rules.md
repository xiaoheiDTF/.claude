# DTO 规则

> 所属模式：Clean Architecture
> 所属层：Interface Adapters
> 包路径：`internal/adapter/handler` 内或 `internal/adapter/dto`

---

## 1. 创建规则

- Request DTO 在 Handler 侧定义
- Response DTO 在 Presenter 侧定义
- UseCase Input/Output 在 UseCase 层定义（不属于 DTO）

## 2. 命名规则

- Request：`CreateOrderRequest`
- Response：`CreateOrderResponse`
- UseCase Input：`CreateOrderInput`（在 usecase 包）
- UseCase Output：`CreateOrderOutput`（在 usecase 包）

## 3. 关键区别

| 对象 | 所属层 | 职责 |
|------|-------|------|
| Request DTO | adapter/handler | HTTP 请求解析 |
| UseCase Input | usecase | 用例输入（纯业务） |
| UseCase Output | usecase | 用例输出（纯业务） |
| Response DTO | adapter/presenter | HTTP 响应格式 |

- 【强制】Request DTO 包含 JSON 标签
- 【强制】UseCase Input/Output 不包含 JSON 标签
- 【强制】Response DTO 包含 JSON 标签
- 【强制】各层之间通过转换函数连接，不直接复用

## 4. 代码模板

```go
// adapter/handler 中
type CreateOrderRequest struct {
    UserID int64             `json:"user_id" binding:"required"`
    Items  []OrderItemInput  `json:"items" binding:"required,min=1"`
}

type OrderItemInput struct {
    ProductID int64 `json:"product_id" binding:"required"`
    Quantity  int   `json:"quantity" binding:"required,min=1"`
    Price     int64 `json:"price" binding:"required,min=1"`
}

// usecase 中
type CreateOrderInput struct {
    UserID int64
    Items  []CreateOrderItemInput
}

type CreateOrderOutput struct {
    OrderID int64
    Status  string
    Total   int64
}

// adapter/presenter 中
type CreateOrderResponse struct {
    ID     int64  `json:"id"`
    Status string `json:"status"`
    Total  int64  `json:"total"`
}
```
