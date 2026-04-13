# Tauri 开发规则

> 所属模式：Rust 前端（桌面端）
> 所属层：IPC 命令层
> 模块路径：`src-tauri/src/commands`

---

## 1. 创建规则

- 一个业务领域对应一个 Command 文件
- Tauri 架构：前端（WebView）通过 IPC invoke 调用 Rust 后端命令
- Command 只做参数提取、调用 Service、返回序列化结果

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| IPC 命令 | 业务名 + `_cmd.rs` | `order_cmd.rs` |
| 权限配置 | 功能描述 + `.json` | `default.json` |
| 前端封装 | `tauri-api.ts` | `tauri-api.ts` |

## 3. 代码质量规则

### 【强制】
- 开启 CSP（Content Security Policy）
- 使用最小权限原则（capabilities 配置）
- IPC 命令参数必须校验
- 不向前端暴露敏感信息
- 错误类型实现 `Serialize`（IPC 传输需要）

### 【禁止】
- 使用 `shell.open` 打开未验证的 URL
- 在 `allowlist` / capabilities 中使用 `*` 通配
- 在 Command 中包含业务逻辑
- 向前端暴露内部错误细节（堆栈、路径）

### 【推荐】
- Command 函数不超过 10 行（只做转发）
- 前端封装统一的 IPC 调用函数
- 使用 `tauri::State` 管理共享状态
- 使用 `tracing` 记录 IPC 调用日志

## 4. 依赖规则

- 可引用：`services`（trait）, `models::dto`, `error`, `state`
- 禁止引用：`repositories`

## 5. AI 生成检查项

- [ ] 权限配置最小化
- [ ] IPC 命令参数校验
- [ ] 错误类型实现 `Serialize`
- [ ] 不暴露敏感信息到前端
- [ ] CSP 配置正确

## 6. 代码模板

```rust
// src-tauri/src/commands/order_cmd.rs
use tauri::State;
use crate::{
    error::AppError,
    models::dto::*,
    services::OrderService,
    state::AppState,
};

#[tauri::command]
pub async fn create_order(
    state: State<'_, AppState>,
    request: CreateOrderRequest,
) -> Result<OrderResponse, AppError> {
    state.order_service.create(request).await
}

#[tauri::command]
pub async fn get_order(
    state: State<'_, AppState>,
    id: i64,
) -> Result<OrderResponse, AppError> {
    state.order_service.get(id).await
}

// src-tauri/src/lib.rs
mod commands;
mod services;
mod models;
mod error;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .manage(AppState::new())
        .invoke_handler(tauri::generate_handler![
            commands::order_cmd::create_order,
            commands::order_cmd::get_order,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

```json
// src-tauri/capabilities/default.json
{
  "identifier": "default",
  "description": "Default permissions",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "shell:allow-open",
    "dialog:allow-open"
  ]
}
```

```typescript
// src/services/tauri-api.ts
import { invoke } from '@tauri-apps/api/core';

export async function createOrder(req: CreateOrderRequest): Promise<OrderResponse> {
  return invoke<OrderResponse>('create_order', { request: req });
}

export async function getOrder(id: number): Promise<OrderResponse> {
  return invoke<OrderResponse>('get_order', { id });
}
```
