# WASM Web 前端开发规则

> 所属模式：Rust 前端（Web）
> 所属层：UI 组件层
> 框架：Leptos / Dioxus / Yew 通用

---

## 1. 创建规则

- 一个 UI 组件对应一个文件
- 框架选型参考：

| 框架 | 特点 | 适用场景 |
|------|------|---------|
| **Leptos** | Signal 响应式、SSR 支持、全栈 | 需要全栈 Rust 的 Web 应用 |
| **Dioxus** | 类 React API、跨平台（Web/桌面/移动） | 需要多端统一的团队 |
| **Yew** | 类 React API、成熟稳定 | 纯 Web 前端、学习成本低 |

## 2. 文件命名规则

组件名小写 + 下划线，如 `order_list.rs`。

## 3. 代码质量规则

### 【强制】
- 使用 `wasm-bindgen` 和 `web-sys` 操作 DOM
- 使用 `serde` + `serde-wasm-bindgen` 做 JS/Rust 数据桥接
- WASM 中避免同步 I/O
- 使用 `wasm-pack` 或 `trunk` 构建
- 使用 `wasm-opt` 优化 binary 大小

### 【禁止】
- 在 WASM 中使用文件系统 API（浏览器不支持）
- 在 WASM 中使用阻塞操作
- 忽略 WASM binary 大小（必须优化）

### 【推荐】
- 使用 `console_error_panic_hook` 处理异常
- 使用 `tracing-wasm` 做日志
- 使用 `gloo` 库简化浏览器 API 调用
- 异步操作使用 `wasm-bindgen-futures`
- `Cargo.toml` 配置 release 优化：

```toml
[profile.release]
opt-level = "z"
lto = true
strip = true
codegen-units = 1
```

## 4. 依赖规则

- 可引用：`serde`, `wasm-bindgen`, `web-sys`, `gloo`, 框架 crate
- 禁止引用：`std::fs`, `std::net`, `tokio`（WASM 不支持原生 I/O）

## 5. AI 生成检查项

- [ ] 无同步 I/O
- [ ] 错误处理完整
- [ ] 组件生命周期正确
- [ ] release profile 配置优化
- [ ] serde 序列化正确

## 6. 代码模板

```rust
// Leptos 组件模板
// src/components/order_list.rs
use leptos::*;

#[component]
pub fn OrderList(
    #[prop(into)] user_id: Signal<String>,
) -> impl IntoView {
    let orders = create_resource(
        move || user_id.get(),
        |user_id| async move { fetch_orders(&user_id).await },
    );

    view! {
        <div class="order-list">
            <Suspense fallback=move || view! { <p>"Loading..."</p> }>
                {move || {
                    match orders.get() {
                        None => view! { <p>"No orders"</p> }.into_view(),
                        Some(Ok(data)) => data.iter()
                            .map(|order| view! {
                                <div class="order-card">
                                    <h3>{&order.title}</h3>
                                    <span>{&order.status}</span>
                                </div>
                            })
                            .collect_view(),
                        Some(Err(e)) => view! { <p class="error">{e.to_string()}</p> }.into_view(),
                    }
                }}
            </Suspense>
        </div>
    }
}
```

```rust
// Dioxus 组件模板
// src/components/order_list.rs
use dioxus::prelude::*;

#[component]
pub fn OrderList(user_id: String) -> Element {
    let mut orders = use_signal(|| Vec::<Order>::new());
    let mut loading = use_signal(|| true);
    let mut error = use_signal(|| None);

    use_effect(move || {
        let user_id = user_id.clone();
        spawn(async move {
            match fetch_orders(&user_id).await {
                Ok(data) => {
                    orders.set(data);
                    loading.set(false);
                }
                Err(e) => {
                    error.set(Some(e.to_string()));
                    loading.set(false);
                }
            }
        });
    });

    rsx! {
        div { class: "order-list",
            if loading() {
                p { "Loading..." }
            } else if let Some(err) = error() {
                p { class: "error", "{err}" }
            } else if orders().is_empty() {
                p { "No orders" }
            } else {
                for order in orders() {
                    div { class: "order-card", key: "{order.id}",
                        h3 { "{order.title}" }
                        span { "{order.status}" }
                    }
                }
            }
        }
    }
}
```
