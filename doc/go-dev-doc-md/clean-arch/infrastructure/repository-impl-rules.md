# Repository 实现规则

> 所属模式：Clean Architecture
> 所属层：Infrastructure（最外层）
> 包路径：`internal/infrastructure/persistence`

---

## 1. 创建规则

- 实现 domain/repository 中定义的接口
- 一个 Repository 接口对应一个实现文件

## 2. 文件命名规则

模型名 + `_repo.go`，如 `order_repo.go`。

## 3. 代码质量规则

### 【强制】
- 实现领域层定义的 Repository 接口
- 将数据库行映射为 domain entity
- 包装底层错误为领域错误

### 【禁止】
- 返回 ORM/驱动特有类型
- 包含业务逻辑
- 让 domain 层知道数据库细节

### 【推荐】
- 使用 sqlc 生成查询代码
- 复杂映射使用单独的 mapper 函数

## 4. 代码模板

```go
package persistence

import (
    "context"
    "database/sql"
    "fmt"
    "time"

    "myproject/internal/domain/entity"
    "myproject/internal/domain/repository"
)

type orderRepo struct {
    db *sql.DB
}

// 确保 orderRepo 实现了 repository.OrderRepository 接口
var _ repository.OrderRepository = (*orderRepo)(nil)

func NewOrderRepo(db *sql.DB) repository.OrderRepository {
    return &orderRepo{db: db}
}

func (r *orderRepo) Save(ctx context.Context, order *entity.Order) error {
    query := `INSERT INTO orders (user_id, status, total, created_at, updated_at)
              VALUES ($1, $2, $3, $4, $5) RETURNING id`
    now := time.Now()
    return r.db.QueryRowContext(ctx, query,
        order.UserID, order.Status, order.Total.Amount(), now, now,
    ).Scan(&order.ID)
}

func (r *orderRepo) FindByID(ctx context.Context, id int64) (*entity.Order, error) {
    query := `SELECT id, user_id, status, total, created_at, updated_at FROM orders WHERE id = $1`
    row := r.db.QueryRowContext(ctx, query, id)

    var (
        o         entity.Order
        status    string
        totalCents int64
    )
    err := row.Scan(&o.ID, &o.UserID, &status, &totalCents, &o.CreatedAt, &o.UpdatedAt)
    if err != nil {
        if err == sql.ErrNoRows {
            return nil, fmt.Errorf("order %d: %w", id, entity.ErrOrderNotFound)
        }
        return nil, fmt.Errorf("query order %d: %w", id, err)
    }
    o.Status = entity.OrderStatus(status)
    o.Total, _ = valueobject.NewMoney(totalCents, "CNY")
    return &o, nil
}
```
