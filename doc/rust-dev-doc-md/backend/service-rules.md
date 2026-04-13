# service 包开发规则

> 所属模式：Rust 后端（框架无关）
> 所属层：业务逻辑层
> 模块路径：`services`

---

## 1. 创建规则

- 一个 Handler/业务领域对应一个 Service
- Service 通过 trait 定义接口，struct 提供实现

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| trait 定义 | 业务名 + Service（trait） | `OrderService` |
| 实现 | 业务名 + ServiceImpl | `OrderServiceImpl` |
| 文件 | 业务名 + `_service.rs` | `order_service.rs` |

## 3. 代码质量规则

### 【强制】
- 所有业务逻辑在此层
- 接收 DTO，返回 DTO
- 通过 trait 定义接口（方便测试 mock）
- 事务管理在此层
- 实现 `Send + Sync` 约束

### 【禁止】
- 直接依赖 HTTP 请求类型
- 返回 Repository 的底层错误未包装
- 在 Service 中使用 `unwrap()`

### 【推荐】
- 方法命名：`create`, `get`, `list`, `update`, `delete`
- 使用 `async_trait` 或原生 async trait
- 复杂业务场景考虑拆分为多个 Service

## 4. 依赖规则

- 可引用：`repositories`（trait）, `models`, `error`
- 禁止引用：`handlers`

## 5. AI 生成检查项

- [ ] trait 定义接口
- [ ] 业务逻辑完整
- [ ] 错误正确包装
- [ ] DTO 转换正确
- [ ] 无 `unwrap()`

## 6. 代码模板

```rust
// services/order_service.rs
use async_trait::async_trait;
use crate::{
    error::AppError,
    models::dto::*,
    repositories::OrderRepository,
};

#[async_trait]
pub trait OrderService: Send + Sync {
    async fn create(&self, req: CreateOrderRequest) -> Result<OrderResponse, AppError>;
    async fn get(&self, id: i64) -> Result<OrderResponse, AppError>;
    async fn list(&self, filter: OrderFilter) -> Result<Vec<OrderResponse>, AppError>;
}

pub struct OrderServiceImpl<R: OrderRepository> {
    repo: R,
}

impl<R: OrderRepository> OrderServiceImpl<R> {
    pub fn new(repo: R) -> Self {
        Self { repo }
    }
}

#[async_trait]
impl<R: OrderRepository + Send + Sync> OrderService for OrderServiceImpl<R> {
    async fn create(&self, req: CreateOrderRequest) -> Result<OrderResponse, AppError> {
        let order = self.repo.create(req.into()).await
            .map_err(|e| AppError::internal("create order", e))?;
        Ok(order.into())
    }

    async fn get(&self, id: i64) -> Result<OrderResponse, AppError> {
        let order = self.repo.find_by_id(id).await?
            .ok_or(AppError::not_found("order", &id.to_string()))?;
        Ok(order.into())
    }

    async fn list(&self, filter: OrderFilter) -> Result<Vec<OrderResponse>, AppError> {
        let orders = self.repo.find_all(filter.into()).await?;
        Ok(orders.into_iter().map(Into::into).collect())
    }
}
```
