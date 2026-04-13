# dto 包开发规则

> 所属模式：标准分层
> 所属层：数据传输对象层
> 包路径：`internal/dto`

---

## 1. 创建规则

- 按业务领域组织文件
- Request / Response / Filter 分文件或同文件

## 2. 文件命名规则

业务名 + `_dto.go`，如 `order_dto.go`。
也可按类型分：`order_request.go`, `order_response.go`。

## 3. 代码质量规则

### 【强制】
- Request 结构体包含 JSON 标签和 validate 标签
- Response 结构体包含 JSON 标签
- 字段名使用 PascalCase，JSON 使用 snake_case

### 【禁止】
- DTO 中包含业务逻辑
- DTO 直接操作数据库
- 返回内部信息（如内部错误码、堆栈）到前端

### 【推荐】
- 使用 `validator` 库的标签进行参数校验
- Request 和 Response 分离，不要复用同一结构体

## 4. 代码模板

```go
package dto

import "time"

// CreateOrderRequest 创建订单请求
type CreateOrderRequest struct {
    UserID int64 `json:"user_id" validate:"required"`
    Items  []OrderItemInput `json:"items" validate:"required,min=1"`
}

type OrderItemInput struct {
    ProductID int64 `json:"product_id" validate:"required"`
    Quantity  int   `json:"quantity" validate:"required,min=1"`
}

// UpdateOrderRequest 更新订单请求
type UpdateOrderRequest struct {
    Status string `json:"status" validate:"required,oneof=DRAFT CONFIRMED CANCELLED"`
}

// OrderResponse 订单响应
type OrderResponse struct {
    ID        int64   `json:"id"`
    UserID    int64   `json:"user_id"`
    Status    string  `json:"status"`
    Total     float64 `json:"total"`
    CreatedAt string  `json:"created_at"`
}

// OrderFilter 订单查询过滤条件
type OrderFilter struct {
    UserID int64  `form:"user_id"`
    Status string `form:"status"`
    Page   int    `form:"page,default=1"`
    Size   int    `form:"size,default=20"`
}
```
