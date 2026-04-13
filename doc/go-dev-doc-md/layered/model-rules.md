# model 包开发规则

> 所属模式：标准分层
> 所属层：领域模型层
> 包路径：`internal/model`

---

## 1. 创建规则

- 对应数据库表或业务核心概念
- 一个实体一个文件，复杂实体可拆分子文件

## 2. 文件命名规则

模型名小写，如 `order.go`, `user.go`。

## 3. 代码质量规则

### 【强制】
- 使用 Go 基本类型，不依赖 ORM 标签之外的第三方库
- 导出字段使用 PascalCase
- 时间字段使用 `time.Time`，不用指针（除非可为空）

### 【禁止】
- Model 中包含业务方法
- 依赖 Handler/Service 层类型
- 包含 JSON 标签（JSON 标签属于 DTO 层）

### 【推荐】
- 使用自定义类型定义枚举（`type OrderStatus string`）
- 可包含与自身相关的简单验证方法

## 4. 代码模板

```go
package model

import "time"

type OrderStatus string

const (
    OrderStatusDraft     OrderStatus = "DRAFT"
    OrderStatusConfirmed OrderStatus = "CONFIRMED"
    OrderStatusCancelled OrderStatus = "CANCELLED"
)

type Order struct {
    ID        int64       `db:"id"`
    UserID    int64       `db:"user_id"`
    Status    OrderStatus `db:"status"`
    Total     float64     `db:"total"`
    CreatedAt time.Time   `db:"created_at"`
    UpdatedAt time.Time   `db:"updated_at"`
}
```
