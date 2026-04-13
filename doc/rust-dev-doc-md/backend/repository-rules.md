# repository 包开发规则

> 所属模式：Rust 后端（框架无关）
> 所属层：数据访问层
> 模块路径：`repositories`

---

## 1. 创建规则

- 一个 Model/聚合根对应一个 Repository
- 通过 trait 定义接口，struct 提供实现
- 接口定义在消费者侧（service 层），实现在 repository 包

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| trait 定义 | 消费者侧定义 | `services` 包中的 `OrderRepository` trait |
| 实现 | 模型名 + Repo | `PgOrderRepository` |
| 文件 | 模型名 + `_repository.rs` | `order_repository.rs` |

## 3. 代码质量规则

### 【强制】
- 只做数据存取操作（CRUD + 查询）
- 返回 Domain Model，不返回数据库特定类型
- 使用 `async_trait` 定义异步接口
- 使用参数化查询（防止 SQL 注入）
- 底层错误包装为 `AppError`

### 【禁止】
- 包含业务逻辑
- 返回 ORM/驱动特定错误类型（sqlx::Error 等）
- 在 Repository 中做数据转换/组装
- 使用字符串拼接 SQL

### 【推荐】
- 方法命名：`create`, `find_by_id`, `find_all`, `update`, `delete`
- 查询条件使用 Filter struct
- 使用 `sqlx::query_as` 做类型映射

## 4. 依赖规则

- 可引用：`models`, `error`
- 禁止引用：`services`, `handlers`

## 5. AI 生成检查项

- [ ] trait 定义接口
- [ ] 只做数据访问
- [ ] 错误包装为 AppError
- [ ] 使用参数化查询（防 SQL 注入）
- [ ] 不返回 ORM 特有类型

## 6. 代码模板

```rust
// repositories/order_repository.rs
use async_trait::async_trait;
use sqlx::PgPool;
use crate::{
    error::AppError,
    models::order::{Order, NewOrder, OrderQueryFilter},
};

#[async_trait]
pub trait OrderRepository: Send + Sync {
    async fn create(&self, order: NewOrder) -> Result<Order, AppError>;
    async fn find_by_id(&self, id: i64) -> Result<Option<Order>, AppError>;
    async fn find_all(&self, filter: OrderQueryFilter) -> Result<Vec<Order>, AppError>;
    async fn update(&self, order: &Order) -> Result<(), AppError>;
    async fn delete(&self, id: i64) -> Result<(), AppError>;
}

pub struct PgOrderRepository {
    pool: PgPool,
}

impl PgOrderRepository {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl OrderRepository for PgOrderRepository {
    async fn create(&self, order: NewOrder) -> Result<Order, AppError> {
        let row = sqlx::query_as::<_, Order>(
            "INSERT INTO orders (user_id, status) VALUES ($1, $2) RETURNING *"
        )
        .bind(order.user_id)
        .bind(&order.status)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| AppError::internal("insert order", e))?;
        Ok(row)
    }

    async fn find_by_id(&self, id: i64) -> Result<Option<Order>, AppError> {
        let row = sqlx::query_as::<_, Order>(
            "SELECT * FROM orders WHERE id = $1"
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| AppError::internal("find order", e))?;
        Ok(row)
    }
}
```
