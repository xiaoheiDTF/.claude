# 大厂 Rust 编码规范

> 综合 Rust 官方风格指南、API 准则和业界最佳实践
> 最后更新：2026-04-11

---

## 一、命名规范

| 场景 | 规则 | 正确示例 | 错误示例 |
|------|------|---------|---------|
| crate 名 | snake_case | `order_service` | `orderService`, `order-service` |
| 类型/struct/enum | UpperCamelCase | `OrderService`, `HttpStatus` | `order_service`, `ORDER_SERVICE` |
| trait | UpperCamelCase | `Read`, `IntoIterator` | `read`, `IRead` |
| 函数/方法 | snake_case | `create_order`, `parse_config` | `createOrder`, `CreateOrder` |
| 变量 | snake_case | `order_list`, `user_count` | `orderList` |
| 常量 | SCREAMING_SNAKE_CASE | `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT` | `maxRetryCount` |
| 静态变量 | SCREAMING_SNAKE_CASE | `GLOBAL_CONFIG` | `globalConfig` |
| 模块 | snake_case | `mod order_service;` | `mod OrderService;` |
| 生命周期 | 短小写字母 | `'a`, `'ctx` | `'lifetime`, `'Life` |
| 枚举变体 | UpperCamelCase | `OrderStatus::Draft` | `OrderStatus::DRAFT` |
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

> 来源：[Rust API Guidelines - Naming](https://rust-lang.github.io/api-guidelines/naming.html)

---

## 二、代码格式

- 【强制】使用 4 空格缩进（非 tab）
- 【强制】行宽上限 100 字符
- 【强制】优先使用 block indent 而非 visual indent
- 【推荐】多行列表使用 trailing comma

```rust
// 推荐 — block indent
let result = foo(
    bar,
    baz,
);

// 不推荐 — visual indent
let result = foo(bar,
                 baz);
```

### 注释格式

- 【推荐】优先使用行注释 `//` 而非块注释 `/* */`
- 【强制】`//` 后加一个空格
- 【推荐】优先使用 `///` 文档注释而非 `/** */`
- 【推荐】只在模块级或 crate 级文档使用 `//!`
- 【强制】注释行不超过 80 字符（不含缩进）

### 属性格式

- 【强制】每个属性独占一行
- 【强制】只使用一个 `#[derive(...)]`

```rust
#[derive(Debug, Clone, Serialize)]
#[repr(C)]
struct Order {
    id: u64,
    status: OrderStatus,
}
```

> 来源：[Rust Style Guide](https://doc.rust-lang.org/style-guide/)

---

## 三、编码实践

### 3.1 错误处理

#### 绝对禁止

- 【禁止】在库代码中使用 `unwrap()` — 使用 `?`、`expect()` 或显式错误处理
- 【禁止】在库代码中使用 `panic!()` — 只在不可恢复错误中使用
- 【禁止】使用 `unsafe` 除非有充分理由和 SAFETY 注释
- 【禁止】忽略编译器警告 — 使用 `#[allow(dead_code)]` 时必须注释原因
- 【禁止】使用 `clone()` 掩盖所有权问题 — 理解为什么需要 clone

#### 必须遵守

- 【强制】使用 `Result<T, E>` 处理可恢复错误
- 【强制】使用 `?` 操作符传播错误
- 【强制】使用 `thiserror` 定义库的错误类型
- 【推荐】应用层使用 `anyhow` 简化错误处理

```rust
// 正确 — 错误传播
fn read_config(path: &Path) -> Result<Config, io::Error> {
    let content = fs::read_to_string(path)?;
    let config: Config = toml::from_str(&content)?;
    Ok(config)
}

// 错误 — unwrap 可能 panic
fn read_config(path: &Path) -> Config {
    let content = fs::read_to_string(path).unwrap();
    toml::from_str(&content).unwrap()
}
```

- 【强制】`expect()` 仅用于"不可能失败"的场景，消息说明原因

```rust
// 可接受 — 程序启动时硬编码值不可能失败
let addr: SocketAddr = "127.0.0.1:8080".parse().expect("hardcoded address is valid");
```

### 3.2 所有权与借用

- 【强制】避免不必要的 `clone()` — 理解所有权后再决定
- 【推荐】函数参数优先使用引用 `&T` 而非 `T`（不需要所有权时）
- 【推荐】使用 `Cow<str>` 处理"有时借用、有时拥有"的场景
- 【强制】生命周期标注仅在编译器无法推断时使用

```rust
// 正确 — 借用足够
fn process(data: &str) -> String {
    data.to_uppercase()
}

// 不必要 — 不需要所有权
fn process(data: String) -> String {
    data.to_uppercase()
}
```

### 3.3 unsafe 使用

- 【强制】`unsafe` 块必须有 `// SAFETY:` 注释说明为什么安全
- 【推荐】最小化 `unsafe` 块的范围

```rust
// SAFETY: ptr 指向的内存已被正确初始化，且在调用期间保持有效
unsafe {
    *ptr = value;
}
```

### 3.4 类型系统

- 【推荐】使用 newtype 模式增强类型安全

```rust
// 正确 — 编译器防止混淆
struct UserId(u64);
struct OrderId(u64);

fn get_user(id: UserId) -> User { ... }

// 错误 — 容易传错参数
fn get_user(id: u64) -> User { ... }
```

- 【强制】实现 `From/TryFrom` 用于类型转换
- 【推荐】实现 `Display` trait 而非 `Debug` 用于用户可见输出

### 3.5 迭代器

- 【推荐】优先使用迭代器方法而非手动循环
- 【推荐】使用 `map`, `filter`, `collect` 等适配器链

```rust
// 推荐
let active_users: Vec<&User> = users.iter()
    .filter(|u| u.is_active())
    .collect();

// 不推荐
let mut active_users = Vec::new();
for u in &users {
    if u.is_active() {
        active_users.push(u);
    }
}
```

### 3.6 async 编程

- 【强制】async 代码中使用 `tokio::sync::Mutex` 而非 `std::sync::Mutex`
- 【推荐】避免在 async 函数中持有锁跨越 `.await` 点
- 【推荐】使用 `tokio::spawn` 时确保任务有取消机制

### 3.7 Drop 实现

- 【强制】`Drop` 实现中禁止 panic
- 【强制】`Drop` 实现中禁止阻塞操作

> 来源：[Rust API Guidelines](https://rust-lang.github.io/api-guidelines/), [The Rust Book](https://doc.rust-lang.org/book/)

---

## 四、并发与安全

### 4.1 Send/Sync

- 【推荐】理解 `Send`（可跨线程移动）和 `Sync`（可跨线程共享引用）
- 【推荐】不要手动实现 `Send/Sync`，让编译器自动推导

### 4.2 锁与原子操作

- 【推荐】使用 `Arc<Mutex<T>>` 共享可变状态
- 【推荐】使用 `Arc::new(Mutex::new(data))` 模式
- 【推荐】锁粒度尽量小，尽快释放
- 【推荐】简单计数器使用 `AtomicUsize` 而非 `Mutex<usize>`

```rust
use std::sync::{Arc, Mutex};
use std::thread;

let counter = Arc::new(Mutex::new(0));
let mut handles = vec![];

for _ in 0..10 {
    let counter = Arc::clone(&counter);
    handles.push(thread::spawn(move || {
        let mut num = counter.lock().unwrap();
        *num += 1;
    }));
}
```

### 4.3 Channel

- 【推荐】使用 `crossbeam-channel` 或 `tokio::sync::mpsc` 进行线程间通信
- 【推荐】channel 优于共享内存 + 锁

---

## 五、API 设计

### 5.1 Builder 模式

- 【推荐】复杂对象构建使用 builder 模式

```rust
let server = Server::builder()
    .addr("127.0.0.1:8080")
    .max_connections(1000)
    .timeout(Duration::from_secs(30))
    .build()?;
```

### 5.2 Option 参数

- 【推荐】可选参数使用 `Option<T>` 而非重载

### 5.3 文档要求

- 【强制】公共 API 必须有 `///` 文档注释
- 【强制】文档包含使用示例（`# Examples`）
- 【强制】可能 panic 的函数必须标注 `# Panics`
- 【强制】unsafe 函数必须标注 `# Safety`

```rust
/// 计算两个数的除法。
///
/// # Examples
/// ```
/// let result = divide(10.0, 2.0)?;
/// assert_eq!(result, 5.0);
/// ```
///
/// # Panics
/// 除数为 0.0 时 panic。
///
/// # Errors
/// 结果溢出时返回 `MathError`。
pub fn divide(a: f64, b: f64) -> Result<f64, MathError> { ... }
```

> 来源：[Rust API Guidelines - Documentation](https://rust-lang.github.io/api-guidelines/documentation.html)

---

## 六、项目结构

### 6.1 Cargo.toml 规范

- 【强制】`[package]` 中 `name` 使用 snake_case
- 【推荐】`edition` 使用最新稳定版（2021 或 2024）
- 【推荐】依赖版本使用 `^` 约束（默认），关键依赖可锁定小版本
- 【推荐】`[features]` 用于条件编译，`default` 尽量精简

### 6.2 模块组织

```rust
// 推荐的模块组织
mod model;       // 数据模型
mod service;     // 业务逻辑
mod handler;     // HTTP/gRPC 处理
mod repository;  // 数据访问
mod error;       // 统一错误类型
mod config;      // 配置管理
```

---

## 七、性能优化

- 【推荐】零成本抽象：优先使用泛型 + trait 而非动态分发（`dyn Trait`）
- 【推荐】大量字符串拼接使用 `String::with_capacity()` 预分配
- 【推荐】使用 `Cow<str>` 避免不必要的字符串克隆
- 【推荐】热路径避免堆分配：栈上分配优先
- 【推荐】使用 `SmallVec`/`SmallString` 处理小数据集
- 【推荐】使用 `#[inline]` 标注小而频繁调用的函数

```rust
// 预分配容量
let mut result = String::with_capacity(source.len());
for s in parts {
    result.push_str(s);
}
```

---

## 参考来源

| 来源 | 质量等级 | 链接 |
|------|---------|------|
| Rust 官方 Style Guide | A | https://doc.rust-lang.org/style-guide/ |
| Rust API Guidelines | A | https://rust-lang.github.io/api-guidelines/ |
| The Rust Programming Language | A | https://doc.rust-lang.org/book/ |
| Effective Rust (书) | B | https://www.lurklurk.org/effective-rust/ |
| Reddit: Rust workplace practices | B | https://www.reddit.com/r/rust/comments/1d28yqe/ |
| andeya/rust-style-guide | B | https://github.com/andeya/rust-style-guide |
