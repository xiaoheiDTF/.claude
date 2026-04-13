# handler 包开发规则

> 所属模式：标准分层
> 所属层：HTTP/gRPC 处理层
> 包路径：`internal/handler`

---

## 1. 创建规则

- 一个业务领域对应一个 Handler（或按 REST 资源分）
- 需要 HTTP/gRPC API 时创建

## 2. 文件命名规则

业务名 + `_handler.go`，如 `order_handler.go`。
测试文件：`order_handler_test.go`。

## 3. 代码质量规则

### 【强制】
- 只做参数校验、调用 Service、组装响应
- 返回统一 `Response[T]`
- 入参超过 2 个封装为结构体
- RESTful URL
- `context.Context` 作为第一个参数

### 【禁止】
- 包含业务逻辑
- 直接调用 Repository
- 返回 Model/Entity 到前端
- 依赖框架特定的 Context 类型（如 `gin.Context`）传入 Service

### 【推荐】
- 方法不超过 20 行
- URL 用名词复数 `/api/v1/orders`
- 使用依赖注入（构造函数注入 Service 接口）

## 4. 依赖规则

- 可引用：`service`（接口）, `dto`, `middleware`, `config`
- 禁止引用：`repository`

## 5. AI 生成检查项

- [ ] 无业务逻辑
- [ ] 参数校验
- [ ] Response[T] 返回
- [ ] RESTful URL
- [ ] 不返回 Model
- [ ] context.Context 第一个参数

## 6. 代码模板

```go
package handler

import (
    "context"
    "net/http"

    "github.com/gin-gonic/gin"
    "myproject/internal/dto"
    "myproject/internal/service"
)

type OrderHandler struct {
    orderSvc service.OrderService
}

func NewOrderHandler(orderSvc service.OrderService) *OrderHandler {
    return &OrderHandler{orderSvc: orderSvc}
}

func (h *OrderHandler) RegisterRoutes(r *gin.Engine) {
    v1 := r.Group("/api/v1")
    {
        v1.POST("/orders", h.Create)
        v1.GET("/orders/:id", h.Get)
        v1.GET("/orders", h.List)
        v1.PATCH("/orders/:id", h.Update)
        v1.DELETE("/orders/:id", h.Delete)
    }
}

func (h *OrderHandler) Create(c *gin.Context) {
    var req dto.CreateOrderRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, Fail(400, err.Error()))
        return
    }

    order, err := h.orderSvc.Create(c.Request.Context(), &req)
    if err != nil {
        // 统一错误处理由中间件负责，这里只需返回
        _ = c.Error(err)
        return
    }

    c.JSON(http.StatusCreated, Success(order))
}

func (h *OrderHandler) Get(c *gin.Context) {
    id, err := strconv.ParseInt(c.Param("id"), 10, 64)
    if err != nil {
        c.JSON(http.StatusBadRequest, Fail(400, "invalid id"))
        return
    }

    order, err := h.orderSvc.Get(c.Request.Context(), id)
    if err != nil {
        _ = c.Error(err)
        return
    }

    c.JSON(http.StatusOK, Success(order))
}
```
