# Repository 端口规则

> 所属模式：Clean Architecture
> 所属层：Application Business Rules 中的端口定义
> 包路径：`internal/domain/repository` 或 `internal/usecase` 内定义

---

## 1. 创建规则

- Repository 接口（端口）在 usecase 层或 domain 层定义
- infrastructure 层提供具体实现
- 一个聚合根对应一个 Repository 端口

## 2. 命名规则

接口名：聚合根名 + `Repository`，如 `OrderRepository`。

## 3. 代码质量规则

### 【强制】
- 接口方法接收和返回 domain 实体，不返回 DTO
- 接口方法第一个参数为 `context.Context`
- 方法返回 `(entity, error)` 或 `error`

### 【禁止】
- 返回数据库特定的类型（sql.Rows, sqlx 结果等）
- 接口方法包含业务逻辑

### 【推荐】
- 方法命名：`Save`, `FindByID`, `FindAll`, `Update`, `Delete`
- 查询条件使用 Filter 对象

## 4. 代码模板

```go
// 在 domain/repository 包中定义接口
package repository

import (
    "context"

    "myproject/internal/domain/entity"
)

type OrderFilter struct {
    UserID   int64
    Status   entity.OrderStatus
    PageSize int
    Offset   int
}

type OrderRepository interface {
    Save(ctx context.Context, order *entity.Order) error
    FindByID(ctx context.Context, id int64) (*entity.Order, error)
    FindAll(ctx context.Context, filter OrderFilter) ([]*entity.Order, error)
    Update(ctx context.Context, order *entity.Order) error
    Delete(ctx context.Context, id int64) error
}
```
