# models 包开发规则

> 所属模式：Rust 后端（框架无关）
> 所属层：数据模型层
> 模块路径：`models`

---

## 1. 创建规则

- 一个业务领域对应一个模型文件 + 一个 DTO 文件
- Domain Model 映射数据库，DTO 用于层间传输

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 领域模型 | 模型名小写 | `order.rs` |
| DTO | `dto.rs` | `dto.rs` |
| 模块入口 | `mod.rs` | `mod.rs` |

## 3. 代码质量规则

### 【强制】
- Domain Model 和 DTO 分离
- 使用 `From`/`Into` trait 做转换
- 金额使用整数类型（分/厘），不使用浮点数
- 时间使用 `chrono` 或 `time` crate
- 所有模型派生 `Debug, Clone`
- 数据库模型使用 `sqlx::FromRow`

### 【禁止】
- DTO 中包含数据库标注
- 直接序列化 Domain Model 到 API 响应
- 使用 `f64` 表示金额

### 【推荐】
- 使用 newtype 模式增强类型安全
- Request 和 Response 分离
- 使用 `serde` 的 `rename_all` 统一命名

## 4. 依赖规则

- 可引用：`serde`, `chrono`, `sqlx`
- 禁止引用：`handlers`, `services`, `repositories`

## 5. AI 生成检查项

- [ ] Domain Model 和 DTO 分离
- [ ] `From`/`Into` 转换实现
- [ ] 金额使用整数
- [ ] `Debug, Clone` 派生
- [ ] `FromRow` 数据库映射

## 6. 代码模板

```rust
// models/order.rs
use serde::{Deserialize, Serialize};
use sqlx::FromRow;

/// 订单领域模型（映射数据库）
#[derive(Debug, Clone, FromRow, Serialize, Deserialize)]
pub struct Order {
    pub id: i64,
    pub user_id: i64,
    pub status: String,
    pub total: i64,
    pub created_at: chrono::NaiveDateTime,
    pub updated_at: chrono::NaiveDateTime,
}

/// 新建订单（Repository 入参）
#[derive(Debug, Clone)]
pub struct NewOrder {
    pub user_id: i64,
    pub status: String,
}

// models/dto.rs

/// 创建订单请求
#[derive(Debug, Deserialize)]
pub struct CreateOrderRequest {
    pub user_id: i64,
    pub items: Vec<OrderItemInput>,
}

/// 订单响应
#[derive(Debug, Serialize)]
pub struct OrderResponse {
    pub id: i64,
    pub user_id: i64,
    pub status: String,
    pub total: i64,
    pub created_at: String,
}

/// 统一响应格式
#[derive(Debug, Serialize)]
pub struct ApiResponse<T: Serialize> {
    pub code: i32,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub data: Option<T>,
}

impl<T: Serialize> ApiResponse<T> {
    pub fn success(data: T) -> Self {
        Self { code: 0, message: "success".into(), data: Some(data) }
    }
}

/// 订单查询过滤
#[derive(Debug, Deserialize)]
pub struct OrderFilter {
    pub user_id: Option<i64>,
    pub status: Option<String>,
    pub page: Option<i32>,
    pub page_size: Option<i32>,
}

// 使用 From trait 做转换
impl From<Order> for OrderResponse {
    fn from(order: Order) -> Self {
        Self {
            id: order.id,
            user_id: order.user_id,
            status: order.status,
            total: order.total,
            created_at: order.created_at.to_string(),
        }
    }
}
```
