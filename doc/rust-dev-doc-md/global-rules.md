# Rust 开发全局规则

> AI 生成 Rust 代码时必须遵守的铁律，适用于所有架构模式（后端服务 / Tauri 桌面端 / WASM 前端）
> 最后更新：2026-04-11

---

## 一、命名铁律

| 场景 | 规则 | 正确示例 | 错误示例 |
|------|------|---------|---------|
| crate 名 | snake_case | `order_service` | `orderService`, `order-service` |
| 类型（struct/enum） | UpperCamelCase | `OrderService`, `HttpStatus` | `order_service`, `ORDER_SERVICE` |
| trait | UpperCamelCase | `Read`, `IntoIterator` | `read`, `IRead` |
| 函数/方法 | snake_case | `create_order`, `parse_config` | `createOrder`, `CreateOrder` |
| 变量 | snake_case | `order_list`, `user_count` | `orderList`, `order_list` (模块级) |
| 常量 | SCREAMING_SNAKE_CASE | `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT` | `maxRetryCount`, `MaxRetryCount` |
| 静态变量 | SCREAMING_SNAKE_CASE | `GLOBAL_CONFIG` | `globalConfig` |
| 模块 | snake_case | `mod order_service;` | `mod OrderService;` |
| 生命周期 | 短小写字母 | `'a`, `'ctx` | `'lifetime`, `'Life` |
| 枚举变体 | UpperCamelCase | `OrderStatus::Draft` | `OrderStatus::DRAFT` |
| 特征方法名 | 动词/动词短语 | `as_ref()`, `into_inner()`, `to_string()` | — |
| 布尔变量/方法 | is_/has_/can_/should_ | `is_active`, `has_permission` | `active`, `permission` |

### 命名补充规则（RFC 430 + API Guidelines）

- 【强制】getter 方法不加 `get_` 前缀：`fn name(&self) -> &str` 而非 `fn get_name`
- 【强制】转换方法使用 `as_`、`into_`、`to_` 前缀
  - `as_`：借用转换（`as_ref()`），零成本
  - `into_`：消费 self 转换（`into_inner()`），移动语义
  - `to_`：复制转换（`to_string()`），产生新值
- 【强制】迭代器方法使用 `_iter` 后缀：`iter()`, `iter_mut()`
- 【强制】setter 使用同名字段名（无前缀）：`fn set_name(&mut self, name: String)`
- 【推荐】builder 方法返回 `Self` 以支持链式调用

> 来源：[Rust API Guidelines - Naming](https://rust-lang.github.io/api-guidelines/naming.html), [Rust Style Guide](https://doc.rust-lang.org/style-guide/)

---

## 二、编码铁律（AI 必须遵守）

### 2.1 绝对禁止

- 【禁止】在库代码中使用 `unwrap()` — 使用 `?`、`expect()` 或显式错误处理
- 【禁止】在库代码中使用 `panic!()` — 只在不可恢复错误中使用
- 【禁止】使用 `unsafe` 除非有充分理由和 SAFETY 注释
- 【禁止】在 async 代码中使用 `std::sync::Mutex` — 使用 `tokio::sync::Mutex`
- 【禁止】忽略编译器警告 — 使用 `#[allow(dead_code)]` 时必须注释原因
- 【禁止】使用 `clone()` 掩盖所有权问题 — 理解为什么需要 clone
- 【禁止】在 `Drop` 实现中 panic
- 【禁止】在循环中分配不必要的堆内存
- 【禁止】使用已废弃的 API

### 2.2 必须遵守

- 【强制】使用 `rustfmt` 格式化代码（`cargo fmt`）
- 【强制】使用 `clippy` 检查代码（`cargo clippy`）
- 【强制】所有 public 函数、trait、struct 必须有 `///` 文档注释
- 【强制】错误处理使用 `Result<T, E>` 和 `?` 运算符
- 【强制】使用 `Option<T>` 而非 null 指针
- 【强制】所有 public unsafe 块必须有 `// SAFETY:` 注释
- 【强制】使用 `#[derive(Debug)]` 为自定义类型实现 Debug
- 【强制】`match` 必须穷尽所有变体（或使用 `_` 通配）
- 【强制】实现 `Drop` 的类型不实现 `Copy`
- 【强制】在 async 函数中使用 `#[tokio::main]` 或手动 runtime

### 2.3 推荐做法

- 【推荐】使用 `thiserror` 定义库错误类型
- 【推荐】使用 `anyhow` 处理应用层错误
- 【推荐】使用 `tracing` 代替 `println!` 做日志
- 【推荐】使用 `serde` 做序列化/反序列化
- 【推荐】优先使用借用 `&T`，必要时才使用 `Arc<T>` 或 `Clone`
- 【推荐】使用 `impl Trait` 代替泛型约束（简化签名时）
- 【推荐】使用 newtype 模式增强类型安全

---

## 三、错误处理铁律

```rust
// 库代码：使用 thiserror 定义错误类型
use thiserror::Error;

#[derive(Error, Debug)]
pub enum OrderError {
    #[error("order not found: {id}")]
    NotFound { id: i64 },

    #[error("invalid order status transition: from {from} to {to}")]
    InvalidTransition { from: String, to: String },

    #[error("database error")]
    Database(#[from] sqlx::Error),
}

// 应用代码：使用 anyhow 处理错误
use anyhow::{Context, Result};

fn process_order(order_id: i64) -> Result<()> {
    let order = fetch_order(order_id)
        .context(format!("failed to fetch order {}", order_id))?;
    order.confirm()?;
    save_order(&order)
        .context("failed to save order")?;
    Ok(())
}
```

- 【强制】库（library）代码使用 `thiserror` 定义具体错误类型
- 【强制】应用（application）代码使用 `anyhow::Result` 简化错误处理
- 【强制】使用 `.context()` / `.with_context()` 添加错误上下文
- 【强制】`unwrap()` 只在测试代码或确定不会 panic 的场景使用
- 【推荐】错误信息使用小写，不含标点

> 来源：[Rust Error Handling: anyhow vs thiserror](https://medium.com/beyond-localhost/custom-error-types-in-rust-anyhow-vs-thiserror-c8dc78402774)

---

## 四、并发铁律

```rust
// 正确：使用 tokio::sync::Mutex 处理 async 代码中的共享状态
use tokio::sync::Mutex;
use std::sync::Arc;

struct AppState {
    orders: Mutex<Vec<Order>>,
}

async fn add_order(state: Arc<AppState>, order: Order) {
    let mut orders = state.orders.lock().await;
    orders.push(order);
}

// 正确：使用 message passing
use tokio::sync::mpsc;

async fn order_worker(mut rx: mpsc::Receiver<OrderCommand>) {
    while let Some(cmd) = rx.recv().await {
        process_command(cmd);
    }
}
```

- 【强制】async 代码中使用 `tokio::sync::Mutex`，非 async 用 `std::sync::Mutex`
- 【强制】使用 `Arc` 跨线程共享数据
- 【强制】Send/Sync 约束自动推导，不要手动 unsafe impl
- 【推荐】优先使用 message passing（channel）而非共享状态
- 【推荐】使用 `tokio::spawn` 时确保任务有生命周期管理

---

## 五、类型设计铁律

```rust
// 正确：newtype 模式增强类型安全
#[derive(Debug, Clone, PartialEq)]
pub struct OrderId(i64);

impl OrderId {
    pub fn new(id: i64) -> Result<Self, OrderError> {
        if id <= 0 {
            return Err(OrderError::InvalidId(id));
        }
        Ok(Self(id))
    }

    pub fn value(&self) -> i64 {
        self.0
    }
}

// 正确：builder 模式
let order = Order::builder()
    .customer_id(customer_id)
    .items(items)
    .build()?;
```

- 【强制】使用 newtype 模式区分不同含义的同类型值
- 【强制】实现 `From`/`Into` trait 做类型转换
- 【推荐】复杂构造使用 builder 模式
- 【推荐】使用 `#[non_exhaustive]` 标记可能扩展的 enum

---

## 六、依赖管理铁律

- 【强制】使用 `Cargo.toml` 管理依赖
- 【强制】锁定 `Cargo.lock` 版本（应用项目提交 lock 文件）
- 【强制】使用 workspace 管理多 crate 项目
- 【推荐】最小化依赖数量
- 【推荐】使用 `cargo audit` 检查安全漏洞
- 【推荐】feature flag 控制可选依赖

---

## 七、AI 生成自查清单

每次生成 Rust 代码后，AI 必须逐项检查：

- [ ] 命名是否符合 RFC 430（snake_case / UpperCamelCase / SCREAMING_SNAKE_CASE）
- [ ] 是否有 `unwrap()` 在非测试代码中
- [ ] 是否有 `panic!()` 在非必要场景
- [ ] 是否有 `unsafe` 且缺少 SAFETY 注释
- [ ] public 函数/类型是否有 `///` 文档注释
- [ ] 错误处理是否使用 `Result` + `?`
- [ ] async 代码是否使用了正确的 Mutex 类型
- [ ] `match` 是否穷尽所有变体
- [ ] 是否有不必要的 `clone()`
- [ ] 是否通过 `cargo fmt` 和 `cargo clippy`

> 核心参考来源：
> - [Rust Style Guide](https://doc.rust-lang.org/style-guide/) (A — Rust 官方)
> - [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/) (A — Rust 官方)
> - [Rust Security Best Practices 2025](https://corgea.com/learn/rust-security-best-practices-2025/) (B)
