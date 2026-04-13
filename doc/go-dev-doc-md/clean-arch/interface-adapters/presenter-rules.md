# presenter 包开发规则

> 所属模式：Clean Architecture
> 所属层：Interface Adapters
> 包路径：`internal/adapter/presenter`

---

## 1. 创建规则

- 一个用例对应一个 Presenter
- 负责将 UseCase 输出转换为 HTTP/JSON 响应

## 2. 文件命名规则

业务名 + `_presenter.go`，如 `order_presenter.go`。

## 3. 代码质量规则

### 【强制】
- 只做格式转换（UseCase Output → HTTP Response）
- 不包含业务逻辑

### 【推荐】
- 与 Handler 配合使用
- 支持多种输出格式（JSON, XML 等）

## 4. 代码模板

```go
package presenter

import "myproject/internal/usecase"

type OrderPresenter struct{}

func NewOrderPresenter() *OrderPresenter {
    return &OrderPresenter{}
}

type CreateOrderResponse struct {
    ID     int64  `json:"id"`
    Status string `json:"status"`
    Total  int64  `json:"total"`
}

func (p *OrderPresenter) ToCreateResponse(output *usecase.CreateOrderOutput) *CreateOrderResponse {
    return &CreateOrderResponse{
        ID:     output.OrderID,
        Status: output.Status,
        Total:  output.Total,
    }
}
```
