# usecase 包开发规则

> 所属模式：Clean Architecture
> 所属层：Application Business Rules
> 包路径：`internal/usecase`

---

## 1. 创建规则

- 一个用例（业务场景）对应一个 UseCase 结构体
- UseCase 是应用层编排器，协调领域对象完成业务

## 2. 文件命名规则

业务名 + `_usecase.go`，如 `order_usecase.go`。

## 3. 代码质量规则

### 【强制】
- 只依赖 domain 层的接口和实体
- 不直接依赖任何基础设施（数据库、HTTP、外部服务）
- 通过构造函数注入依赖（Repository 端口等）
- 每个 UseCase 方法对应一个完整的业务用例

### 【禁止】
- import infrastructure 包
- 包含数据库访问逻辑
- 依赖 HTTP/gRPC 相关类型
- 在 UseCase 中做对象序列化/反序列化

### 【推荐】
- UseCase 方法返回 domain 实体，由 adapter 层转换为 DTO
- 复杂用例拆分为多个方法
- 每个方法有清晰的输入/输出结构

## 4. 依赖规则

- 可引用：`domain/entity`, `domain/valueobject`, `domain/repository`（接口）, `domain/service`
- 禁止引用：`adapter`, `infrastructure`

## 5. AI 生成检查项

- [ ] 只依赖 domain 层
- [ ] 不包含基础设施代码
- [ ] 业务编排逻辑完整
- [ ] 通过接口注入依赖

## 6. 代码模板

```go
package usecase

import (
    "context"
    "fmt"

    "myproject/internal/domain/entity"
    "myproject/internal/domain/valueobject"
)

// OrderRepository 端口 — 由 usecase 定义，infrastructure 实现
type OrderRepository interface {
    Save(ctx context.Context, order *entity.Order) error
    FindByID(ctx context.Context, id int64) (*entity.Order, error)
    Update(ctx context.Context, order *entity.Order) error
}

type OrderUseCase struct {
    repo OrderRepository
}

func NewOrderUseCase(repo OrderRepository) *OrderUseCase {
    return &OrderUseCase{repo: repo}
}

type CreateOrderInput struct {
    UserID int64
    Items  []CreateOrderItemInput
}

type CreateOrderItemInput struct {
    ProductID int64
    Quantity  int
    Price     int64 // 分为单位
}

type CreateOrderOutput struct {
    OrderID int64
    Status  string
    Total   int64
}

func (uc *OrderUseCase) CreateOrder(ctx context.Context, input CreateOrderInput) (*CreateOrderOutput, error) {
    // 构建领域对象
    items := make([]entity.OrderItem, 0, len(input.Items))
    for _, item := range input.Items {
        price, err := valueobject.NewMoney(item.Price, "CNY")
        if err != nil {
            return nil, fmt.Errorf("invalid item price: %w", err)
        }
        items = append(items, entity.OrderItem{
            ProductID: item.ProductID,
            Quantity:  item.Quantity,
            Price:     price,
        })
    }

    order := &entity.Order{
        UserID: input.UserID,
        Items:  items,
        Status: entity.OrderStatusDraft,
    }

    // 调用领域逻辑
    order.CalculateTotal()

    // 持久化
    if err := uc.repo.Save(ctx, order); err != nil {
        return nil, fmt.Errorf("save order: %w", err)
    }

    return &CreateOrderOutput{
        OrderID: order.ID,
        Status:  string(order.Status),
        Total:   order.Total.Amount(),
    }, nil
}

func (uc *OrderUseCase) ConfirmOrder(ctx context.Context, orderID int64) error {
    order, err := uc.repo.FindByID(ctx, orderID)
    if err != nil {
        return fmt.Errorf("find order: %w", err)
    }

    if err := order.Confirm(); err != nil {
        return fmt.Errorf("confirm order: %w", err)
    }

    return uc.repo.Update(ctx, order)
}
```
