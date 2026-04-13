# entity 包开发规则

> 所属模式：Clean Architecture
> 所属层：Enterprise Business Rules（最内层）
> 包路径：`internal/domain/entity`

---

## 1. 创建规则

- 一个业务聚合根对应一个实体文件
- 实体是业务核心概念，拥有唯一标识

## 2. 文件命名规则

实体名小写，如 `order.go`, `user.go`。

## 3. 代码质量规则

### 【强制】
- 零外部依赖（只依赖标准库和 domain 内的其他包）
- 实体包含业务规则和验证逻辑
- 导出字段 PascalCase

### 【禁止】
- import 任何外部包（除标准库）
- 包含数据库标签（db tag）
- 包含 JSON 标签
- 依赖任何框架

### 【推荐】
- 实体方法封装业务规则
- 使用值对象表示复杂属性

## 4. 代码模板

```go
package entity

import (
    "errors"
    "time"
)

var (
    ErrInvalidOrderStatus = errors.New("invalid order status")
    ErrEmptyOrderItems    = errors.New("order items cannot be empty")
)

type OrderStatus string

const (
    OrderStatusDraft     OrderStatus = "DRAFT"
    OrderStatusConfirmed OrderStatus = "CONFIRMED"
    OrderStatusCancelled OrderStatus = "CANCELLED"
)

type Order struct {
    ID        int64
    UserID    int64
    Items     []OrderItem
    Status    OrderStatus
    Total     Money
    CreatedAt time.Time
    UpdatedAt time.Time
}

// Confirm 确认订单 — 业务规则封装在实体中
func (o *Order) Confirm() error {
    if o.Status != OrderStatusDraft {
        return ErrInvalidOrderStatus
    }
    if len(o.Items) == 0 {
        return ErrEmptyOrderItems
    }
    o.Status = OrderStatusConfirmed
    o.UpdatedAt = time.Now()
    return nil
}

// Cancel 取消订单
func (o *Order) Cancel() error {
    if o.Status == OrderStatusCancelled {
        return ErrInvalidOrderStatus
    }
    o.Status = OrderStatusCancelled
    o.UpdatedAt = time.Now()
    return nil
}

// CalculateTotal 计算总额
func (o *Order) CalculateTotal() Money {
    var total Money
    for _, item := range o.Items {
        total = total.Add(item.Subtotal())
    }
    o.Total = total
    return total
}
```
