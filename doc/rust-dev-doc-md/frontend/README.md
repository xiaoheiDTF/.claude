# Rust 前端开发规则 — 总览

> 适用场景：桌面应用（Tauri）和 Web 前端（WASM）
> 最后更新：2026-04-11

---

## 技术选型

| 方案 | 渲染方式 | 适用场景 | 推荐框架 |
|------|---------|---------|---------|
| **Tauri** | 系统 WebView | 桌面端/移动端 | 前端用 React/Vue，后端用 Rust |
| **Leptos** | WASM + SSR | 全栈 Web | 纯 Rust，Signal 响应式 |
| **Dioxus** | WASM / Native | 跨平台 | 类 React API，支持桌面/移动 |
| **Yew** | WASM | 纯 Web 前端 | 类 React API，成熟稳定 |

## 推荐目录结构（Tauri 项目）

```
project-root/
├── src-tauri/                    ← Rust 后端（Core）
│   ├── src/
│   │   ├── main.rs               ← 入口
│   │   ├── lib.rs                ← 库入口
│   │   ├── commands/             ← IPC 命令处理器
│   │   │   ├── mod.rs
│   │   │   └── order_cmd.rs
│   │   ├── services/             ← 业务逻辑
│   │   ├── models/               ← 数据模型
│   │   └── error.rs              ← 错误处理
│   ├── capabilities/             ← 权限配置
│   │   └── default.json
│   ├── Cargo.toml
│   └── tauri.conf.json
├── src/                          ← 前端代码（React/Vue）
│   ├── components/
│   ├── hooks/
│   └── services/
│       └── tauri-api.ts          ← IPC 客户端封装
└── package.json
```

## 依赖规则

```
commands → services → models
commands/services → error

严禁：commands 直接操作数据库
严禁：向前端暴露内部错误细节
```

## 规则文件索引

| 文件 | 说明 |
|------|------|
| [tauri-rules.md](tauri-rules.md) | Tauri 2.0 桌面端开发规则 |
| [wasm-rules.md](wasm-rules.md) | WASM Web 前端开发规则（Leptos/Dioxus/Yew） |

> 来源：[Tauri 2.0 Security](https://v2.tauri.app/security/) (A), [Leptos vs Dioxus vs Yew](https://reintech.io/blog/leptos-vs-yew-vs-dioxus-rust-frontend-framework-comparison-2026) (B)
