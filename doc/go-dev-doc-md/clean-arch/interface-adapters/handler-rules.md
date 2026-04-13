# handler 适配器规则

> 所属模式：Clean Architecture
> 所属层：Interface Adapters
> 包路径：`internal/adapter/handler`

---

## 1. 创建规则

- 一个用例或资源对应一个 Handler
- Handler 负责将外部请求转换为 UseCase 的输入

## 2. 文件命名规则

业务名 + `_handler.go`，如 `order_handler.go`。

## 3. 代码质量规则

### 【强制】
- 只做请求解析、调用 UseCase、组装响应
- HTTP 细节不传递到 UseCase 层
- 将 Request DTO 转换为 UseCase Input

### 【禁止】
- 包含业务逻辑
- 直接调用 infrastructure 层
- 将 `gin.Context` 或 `http.Request` 传入 UseCase

### 【推荐】
- Handler 只调用 UseCase，由 Presenter 负责响应格式化

## 4. 代码模板

```go
package handler

import (
    "net/http"
    "strconv"

    "github.com/gin-gonic/gin"
    "myproject/internal/adapter/presenter"
    "myproject/internal/usecase"
)

type OrderHandler struct {
    useCase   *usecase.OrderUseCase
    presenter *presenter.OrderPresenter
}

func NewOrderHandler(uc *usecase.OrderUseCase, p *presenter.OrderPresenter) *OrderHandler {
    return &OrderHandler{useCase: uc, presenter: p}
}

func (h *OrderHandler) Create(c *gin.Context) {
    var req CreateOrderRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    input := h.toCreateInput(&req)
    output, err := h.useCase.CreateOrder(c.Request.Context(), input)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusCreated, h.presenter.ToCreateResponse(output))
}

func (h *OrderHandler) toCreateInput(req *CreateOrderRequest) *usecase.CreateOrderInput {
    items := make([]usecase.CreateOrderItemInput, 0, len(req.Items))
    for _, item := range req.Items {
        items = append(items, usecase.CreateOrderItemInput{
            ProductID: item.ProductID,
            Quantity:  item.Quantity,
            Price:     item.Price,
        })
    }
    return &usecase.CreateOrderInput{
        UserID: req.UserID,
        Items:  items,
    }
}
```
