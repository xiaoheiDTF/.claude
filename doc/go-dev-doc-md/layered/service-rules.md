# service 包开发规则

> 所属模式：标准分层
> 所属层：业务逻辑层
> 包路径：`internal/service`

---

## 1. 创建规则

- 一个 Handler/业务领域对应一个 Service
- 接口定义在消费者侧（handler 侧），实现在 service 包

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 接口 | 消费者侧定义 | `handler` 包中的 `OrderService` 接口 |
| 实现 | 业务名 + `_service.go` | `order_service.go` |

## 3. 代码质量规则

### 【强制】
- 所有业务逻辑在此层
- 接收 DTO/Request，返回 DTO/Domain Model
- 接口定义在消费者侧（handler 包），service 包提供具体实现
- 事务管理在此层（如需要）

### 【禁止】
- 直接依赖 HTTP 相关类型
- 返回 Repository 的底层错误未包装
- 在 Service 中启动不管理生命周期的 goroutine

### 【推荐】
- 方法命名：`Create`, `Get`, `List`, `Update`, `Delete`
- 使用构造函数注入依赖（`NewOrderService(repo repository.OrderRepository) *OrderService`）
- 复杂业务场景考虑拆分为多个 Service

## 4. 依赖规则

- 可引用：`repository`（接口）, `model`, `dto`, `config`
- 禁止引用：`handler`

## 5. AI 生成检查项

- [ ] 接口在消费者侧定义
- [ ] 业务逻辑完整
- [ ] 不依赖 HTTP 类型
- [ ] 不返回 Model 到 Handler（或明确约定可返回）
- [ ] 错误正确包装

## 6. 代码模板

```go
package service

import (
    "context"
    "fmt"

    "myproject/internal/dto"
    "myproject/internal/model"
    "myproject/internal/repository"
)

// 接口通常在 handler 包中定义，这里也可以定义供包外使用
type OrderService interface {
    Create(ctx context.Context, req *dto.CreateOrderRequest) (*dto.OrderResponse, error)
    Get(ctx context.Context, id int64) (*dto.OrderResponse, error)
    List(ctx context.Context, filter *dto.OrderFilter) ([]*dto.OrderResponse, error)
    Update(ctx context.Context, id int64, req *dto.UpdateOrderRequest) error
    Delete(ctx context.Context, id int64) error
}

type orderService struct {
    repo repository.OrderRepository
}

func NewOrderService(repo repository.OrderRepository) OrderService {
    return &orderService{repo: repo}
}

func (s *orderService) Create(ctx context.Context, req *dto.CreateOrderRequest) (*dto.OrderResponse, error) {
    order := &model.Order{
        UserID: req.UserID,
        Status: model.OrderStatusDraft,
    }

    if err := s.repo.Create(ctx, order); err != nil {
        return nil, fmt.Errorf("create order: %w", err)
    }

    return toOrderResponse(order), nil
}

func (s *orderService) Get(ctx context.Context, id int64) (*dto.OrderResponse, error) {
    order, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get order %d: %w", id, err)
    }
    return toOrderResponse(order), nil
}

func toOrderResponse(o *model.Order) *dto.OrderResponse {
    return &dto.OrderResponse{
        ID:        o.ID,
        UserID:    o.UserID,
        Status:    string(o.Status),
        CreatedAt: o.CreatedAt,
    }
}
```
