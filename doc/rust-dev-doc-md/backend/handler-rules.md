# handler 包开发规则

> 所属模式：Rust 后端（框架无关）
> 所属层：HTTP 处理层
> 模块路径：`handlers`

---

## 1. 创建规则

- 一个业务领域对应一个 Handler 模块
- 需要 HTTP API 时创建
- Handler 只做参数提取、调用 Service、组装响应

## 2. 文件命名规则

业务名 + `_handler.rs`，如 `order_handler.rs`。

## 3. 代码质量规则

### 【强制】
- 只做参数提取/校验和调用 Service
- 返回统一 `Result<Json<ApiResponse<T>>, AppError>`
- 入参超过 2 个封装为 struct
- RESTful URL
- 函数签名中 `State` / `Path` / `Query` / `Json` 使用框架 extractor

### 【禁止】
- 包含业务逻辑
- 直接调用 Repository
- 返回数据库模型到前端
- 依赖框架特有类型传入 Service 层

### 【推荐】
- Handler 函数不超过 15 行
- URL 用名词复数 `/api/v1/orders`
- 使用依赖注入（State 提取共享状态）

## 4. 依赖规则

- 可引用：`services`（trait）, `models::dto`, `error`, `state`
- 禁止引用：`repositories`

## 5. AI 生成检查项

- [ ] 无业务逻辑
- [ ] 统一响应格式 `ApiResponse<T>`
- [ ] RESTful URL
- [ ] 不返回数据库模型
- [ ] 参数校验
- [ ] 错误通过 AppError 统一处理

## 6. 代码模板

```rust
// handlers/order_handler.rs
use axum::{
    extract::{Path, State, Query},
    Json,
};
use crate::{
    error::AppError,
    models::dto::*,
    services::OrderService,
    state::AppState,
};

pub async fn create_order(
    State(state): State<AppState>,
    Json(req): Json<CreateOrderRequest>,
) -> Result<Json<ApiResponse<OrderResponse>>, AppError> {
    let order = state.order_service.create(req).await?;
    Ok(Json(ApiResponse::success(order)))
}

pub async fn get_order(
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<ApiResponse<OrderResponse>>, AppError> {
    let order = state.order_service.get(id).await?;
    Ok(Json(ApiResponse::success(order)))
}

pub async fn list_orders(
    State(state): State<AppState>,
    Query(filter): Query<OrderFilter>,
) -> Result<Json<ApiResponse<Vec<OrderResponse>>>, AppError> {
    let orders = state.order_service.list(filter).await?;
    Ok(Json(ApiResponse::success(orders)))
}
```
