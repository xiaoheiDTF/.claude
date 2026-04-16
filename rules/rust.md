---
paths:
  - "**/*.rs"
---

# Rust 编码规范

> 综合 Rust API Guidelines / The Rust Programming Language / Rust Style Guide / Effective Rust

## 命名规范

- 类型（struct, enum, trait）：PascalCase（`UserService`, `HttpRequest`）
- 函数和方法：snake_case（`get_user_info`, `parse_config`）
- 常量：UPPER_SNAKE_CASE（`MAX_RETRY_COUNT`）
- 变量和模块：snake_case（`user_count`, `auth_module`）
- 生命周期：短小写字母（`'a`, `'b`, `'ctx`）
- 宏：snake_case（`println!`, `vec!`）；但 `#[derive(...)]` 例外
- 类型参数：简短 PascalCase（`T`, `E`, `K`, `V`）；语义化时 `TReq`, `TRes`
- 文件名：snake_case（`user_service.rs`）；模块目录用 snake_case
- 特征名：PascalCase（`Read`, `Display`, `FromIterator`）
- 缩写全大写或全小写（`HttpResponse` / `http_response`）
- 布尔变量以 is/has/can/should 开头（`is_valid`, `has_permission`）
- 单元测试函数：`test_<behavior>`（`test_user_creation_with_valid_data`）

## 代码格式

- 使用 `rustfmt` 自动格式化（无争议）
- 缩进：4 个空格
- 行宽：100 字符（`rustfmt` 默认）
- 左花括号不换行
- 使用 `cargo clippy` 进行 lint 检查
- `use` 语句按标准库 → 第三方 → 本地 crate 分组

## 所有权与借用

- 默认使用借用（`&T`），仅在必要时获取所有权
- 生命周期尽量让编译器推断（ELISION 规则），仅在必要时显式标注
- 使用 `Clone` 明确表达复制语义，避免隐式深拷贝
- 使用 `Cow<str>` / `Cow<[T]>` 处理可能需要修改的借用数据
- 避免不必要的 `clone()`（先考虑引用或重新设计生命周期）
- 使用 `Arc<Mutex<T>>` / `Arc<RwLock<T>>` 共享可变状态（多线程）
- 使用 `Rc<RefCell<T>>` 仅在单线程需要共享可变状态时
- 实现 `Drop` 处理资源清理（RAII 模式）
- 优先使用迭代器（`iter()`, `into_iter()`, `iter_mut()`）而非索引访问

## 错误处理

- 使用 `Result<T, E>` 处理可恢复错误，`panic!` 仅用于不可恢复的程序性错误
- 使用 `?` 操作符传播错误
- 使用 `thiserror` crate 定义自定义错误类型
- 使用 `anyhow` 处理应用层错误（不需要精确匹配错误类型时）
- 错误类型实现 `std::error::Error` trait
- 使用 `impl Into<MyError>` 接受多种错误源
- 在调用边界统一处理错误（main 函数、HTTP handler）
- 使用 `.context()` / `.with_context()`（anyhow）添加错误上下文
- 不允许 `unwrap()` / `expect()` 在生产代码中（测试代码可用）
- 使用 `unwrap_or_default()` / `unwrap_or()` / `ok_or()` 安全处理 Option/Result

## 类型系统

- 优先使用 `struct` 而非 `enum`（当只需一种变体时）
- 使用 `enum` 表达多态（`enum Shape { Circle, Rectangle }`），避免继承
- 使用 `Option<T>` 明确表达可能为空的值，禁止用 `null` 等价物
- 使用 newtype 模式（`struct UserId(u64)`）区分语义相同的类型
- 使用 `#[non_exhaustive]` 防止 API 变更时的破坏性变更
- 实现 `From`/`Into` trait 进行类型转换
- 实现 `Display` trait 提供用户友好的字符串表示
- 实现 `Debug` trait 提供调试信息（`#[derive(Debug)]`）
- 使用泛型 + trait bounds 而非动态分发（`fn foo<T: Trait>(x: T)` 而非 `fn foo(x: Box<dyn Trait>`）
- 动态分发（`dyn Trait`）仅在需要异构集合或减少编译时间时使用

## 模块与可见性

- 公共 API 最小化（`pub` 仅用于必须导出的项）
- 使用 `pub(crate)` 限制 crate 内可见性
- 模块组织：`mod.rs` 或同名文件（`module.rs` + `module/` 目录）
- 使用 `use` 导入时避免过度导入（`use std::collections::HashMap` 而非 `use std::collections::*`）
- 重导出公共类型（`pub use module::Type`）
- 预lude 模式（`prelude.rs`）提供常用类型

## 异步编程

- 使用 `async/await` 语法
- 返回 `impl Future<Output = Result<T, E>>` 或 `async fn`
- 使用 `tokio` 或 `async-std` 运行时（项目内统一）
- 使用 `tokio::spawn` 启动异步任务
- 使用 `tokio::select!` 处理多并发操作
- 使用 `Stream` 处理异步迭代（`futures::stream`）
- 异步 trait 使用 `async-trait` crate 或原生 async trait（Rust 1.75+）
- 使用 `Arc` 在异步任务间共享数据
- 避免在异步代码中调用阻塞操作（用 `tokio::task::spawn_blocking`）

## 测试规范

- 单元测试：同文件 `#[cfg(test)] mod tests`
- 集成测试：`tests/` 目录下独立文件
- 使用 `#[test]` 标注测试函数
- 使用 `assert!`, `assert_eq!`, `assert_ne!` 断言
- 使用 `#[should_panic]` 测试 panic 场景
- 文档测试（doctest）：在 doc comment 中写可执行示例
- 使用 `proptest` / `quickcheck` 做属性测试
- Mock 使用接口 trait + 手写 mock 或 `mockall` crate
- 基准测试：`cargo bench` + `criterion`
- 测试覆盖率：`cargo tarpaulin` 或 `cargo llvm-cov`

## 性能优化

- 使用 `cargo bench` 做基准测试，不凭感觉优化
- 优先使用零成本抽象（迭代器、泛型、trait）
- 使用 `Cow` 避免不必要的字符串/切片分配
- 使用 `SmallVec` / `SmallString` 优化小集合
- 热路径避免频繁分配（对象池、预分配）
- 使用 `#[inline]` 标注小而频繁的函数
- 使用 `std::hint::unreachable_unchecked` 仅在安全证明后
- 编译优化：release profile 调优（LTO, codegen-units）
- 异步 I/O 替代同步阻塞（高并发场景）
- 使用 `perf` / `flamegraph` 分析热点

## 安全规范

- 优先使用安全 API，`unsafe` 仅在必要时使用并添加安全注释（`// SAFETY: ...`）
- 使用 `unsafe` 的代码封装在安全抽象之后（公共 API 全部安全）
- SQL 使用参数化查询（`sqlx` / `diesel`）
- 密码使用 `argon2` / `bcrypt` 哈希
- 使用 `ring` / `rustls` 进行加密操作，避免 `openssl`
- 输入验证：所有外部输入必须校验
- 禁止硬编码密钥，使用环境变量
- 使用 `cargo audit` 审计依赖漏洞

## 魔法变量治理

### 三级判定

| 级别 | 条件 | 做法 |
|------|------|------|
| ① inline | 只在 1~2 处使用，不跨模块 | 直接写在代码中 |
| ② 常量文件 | 跨 3+ 模块使用，或容易拼错 | `pub const UPPER_SNAKE_CASE: &str = "value";` 在 `constants.rs` 中 |
| ③ 类型约束 | 天然属于类型定义 | `enum` + `#[strum(...)]` 或 `FromStr` |

**配置数值** → 环境变量（`env!("KEY")` 编译期 或 `std::env::var("KEY")` 运行时）+ 默认值。

### 替换原则

- **纯机械替换**：只改字面量为常量引用，不改变运行时行为
- **值完全一致**：常量值必须与原硬编码完全一致

### 实现顺序

定义常量文件（底层零依赖）→ 替换消费代码 → 同步文档
