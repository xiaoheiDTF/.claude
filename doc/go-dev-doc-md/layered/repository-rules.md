# repository 包开发规则

> 所属模式：标准分层
> 所属层：数据访问层
> 包路径：`internal/repository`

---

## 1. 创建规则

- 一个 Model/聚合根对应一个 Repository
- 接口定义在消费者侧（service 包），实现在 repository 包

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 接口 | 消费者侧定义 | `service` 包中的 `OrderRepository` 接口 |
| 实现 | 模型名 + `_repo.go` | `order_repo.go` |

## 3. 代码质量规则

### 【强制】
- 只做数据存取操作（CRUD + 查询）
- 返回 Domain Model，不返回数据库特定类型
- 接口定义在 service 包
- 使用 `context.Context` 传递超时和取消

### 【禁止】
- 包含业务逻辑
- 直接返回底层 ORM/驱动的错误类型（需包装）
- 在 Repository 中做数据转换/组装

### 【推荐】
- 方法命名：`Create`, `FindByID`, `FindAll`, `Update`, `Delete`
- 使用 query builder 或 SQL 构建器（sqlc, squirrel 等）
- 复杂查询使用 Filter/Query 对象

## 4. 依赖规则

- 可引用：`model`, `dto`（仅 Filter/Query）
- 禁止引用：`service`, `handler`

## 5. AI 生成检查项

- [ ] 接口在 service 侧定义
- [ ] 只做数据访问
- [ ] 不包含业务逻辑
- [ ] 错误正确包装

## 6. 代码模板

```go
package repository

import (
    "context"
    "database/sql"
    "fmt"

    "myproject/internal/model"
)

// OrderRepository 通常定义在 service 包中
type OrderRepository interface {
    Create(ctx context.Context, order *model.Order) error
    FindByID(ctx context.Context, id int64) (*model.Order, error)
    FindAll(ctx context.Context, filter *OrderFilter) ([]*model.Order, error)
    Update(ctx context.Context, order *model.Order) error
    Delete(ctx context.Context, id int64) error
}

type OrderFilter struct {
    UserID int64
    Status string
    Limit  int
    Offset int
}

type orderRepo struct {
    db *sql.DB
}

func NewOrderRepo(db *sql.DB) OrderRepository {
    return &orderRepo{db: db}
}

func (r *orderRepo) Create(ctx context.Context, order *model.Order) error {
    query := `INSERT INTO orders (user_id, status, created_at) VALUES ($1, $2, $3) RETURNING id`
    return r.db.QueryRowContext(ctx, query,
        order.UserID, order.Status, order.CreatedAt,
    ).Scan(&order.ID)
}

func (r *orderRepo) FindByID(ctx context.Context, id int64) (*model.Order, error) {
    query := `SELECT id, user_id, status, created_at, updated_at FROM orders WHERE id = $1`
    row := r.db.QueryRowContext(ctx, query, id)

    var order model.Order
    err := row.Scan(&order.ID, &order.UserID, &order.Status, &order.CreatedAt, &order.UpdatedAt)
    if err != nil {
        if err == sql.ErrNoRows {
            return nil, fmt.Errorf("order %d: %w", id, ErrNotFound)
        }
        return nil, fmt.Errorf("find order by id %d: %w", id, err)
    }
    return &order, nil
}
```
