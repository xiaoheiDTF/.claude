# error 模块开发规则

> 所属模式：Rust 后端（框架无关）
> 所属层：错误处理层
> 模块路径：`error.rs`（根模块）

---

## 1. 创建规则

- 项目启动时创建统一错误类型
- 使用 `thiserror` 定义错误枚举
- 实现 HTTP 框架的响应 trait（如 Axum 的 `IntoResponse`）

## 2. 文件命名规则

`error.rs`，放在 `src/` 根目录。

## 3. 代码质量规则

### 【强制】
- 统一错误类型实现 `IntoResponse`（Axum）或类似 trait
- 不向客户端暴露内部错误细节（堆栈、SQL、路径）
- 内部错误记录完整日志
- 使用 `thiserror` 定义错误变体
- 错误信息小写，不含标点

### 【禁止】
- 在 Handler 中使用 `match` 处理不同错误类型（由统一错误处理）
- 向前端暴露 `sqlx::Error` 等底层错误
- 在错误信息中包含敏感数据

### 【推荐】
- 使用构造函数创建错误（`AppError::not_found()`, `AppError::bad_request()`）
- 错误码使用 HTTP 状态码或自定义业务码

## 4. 依赖规则

- 可引用：`axum`（或对应框架）, `serde`, `thiserror`, `anyhow`, `tracing`
- 禁止引用：`handlers`, `services`, `repositories`

## 5. AI 生成检查项

- [ ] 统一错误类型
- [ ] 实现 `IntoResponse`
- [ ] 不暴露内部错误细节
- [ ] 错误信息小写
- [ ] 内部错误有日志

## 6. 代码模板

```rust
// error.rs
use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde::Serialize;

#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("not found: {resource} {id}")]
    NotFound { resource: String, id: String },

    #[error("bad request: {message}")]
    BadRequest { message: String },

    #[error("unauthorized: {message}")]
    Unauthorized { message: String },

    #[error("internal error: {context}")]
    Internal { context: String, source: anyhow::Error },
}

#[derive(Serialize)]
struct ErrorResponse {
    code: i32,
    message: String,
}

impl AppError {
    pub fn not_found(resource: &str, id: &str) -> Self {
        Self::NotFound { resource: resource.into(), id: id.into() }
    }

    pub fn bad_request(msg: impl Into<String>) -> Self {
        Self::BadRequest { message: msg.into() }
    }

    pub fn unauthorized(msg: impl Into<String>) -> Self {
        Self::Unauthorized { message: msg.into() }
    }

    pub fn internal(context: &str, source: impl Into<anyhow::Error>) -> Self {
        Self::Internal { context: context.into(), source: source.into() }
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, code, message) = match &self {
            AppError::NotFound { .. } => (StatusCode::NOT_FOUND, 404, self.to_string()),
            AppError::BadRequest { .. } => (StatusCode::BAD_REQUEST, 400, self.to_string()),
            AppError::Unauthorized { .. } => (StatusCode::UNAUTHORIZED, 401, self.to_string()),
            AppError::Internal { .. } => {
                tracing::error!("internal error: {:?}", self);
                (StatusCode::INTERNAL_SERVER_ERROR, 500, "internal server error".into())
            }
        };

        (status, Json(ErrorResponse { code, message })).into_response()
    }
}
```
