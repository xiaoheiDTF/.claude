# middleware 包开发规则

> 所属模式：Rust 后端（框架无关）
> 所属层：中间件层
> 模块路径：`middleware`

---

## 1. 创建规则

- 一个关注点一个中间件文件
- 横切关注点：认证、日志、限流、CORS

## 2. 文件命名规则

功能名小写，如 `auth.rs`, `logging.rs`。

## 3. 代码质量规则

### 【强制】
- 中间件只做横切关注点
- 正确传播 `Request`
- 使用 `tracing` 记录请求日志

### 【禁止】
- 在中间件中做业务判断
- 吞掉错误（除非是 recovery 中间件）
- 修改响应体

### 【推荐】
- 使用结构体配置中间件行为
- Request ID 透传

## 4. 依赖规则

- 可引用：`error`, `state`
- 禁止引用：`handlers`, `services`

## 5. AI 生成检查项

- [ ] 无业务逻辑
- [ ] 正确传播 Request
- [ ] 错误处理
- [ ] 使用 tracing 日志

## 6. 代码模板

```rust
// middleware/logging.rs
use axum::{
    extract::Request,
    middleware::Next,
    response::Response,
};

pub async fn logging(request: Request, next: Next) -> Response {
    let method = request.method().clone();
    let path = request.uri().path().to_owned();
    let start = std::time::Instant::now();

    let response = next.run(request).await;

    let latency = start.elapsed();
    let status = response.status();

    tracing::info!(
        method = %method,
        path = %path,
        status = %status.as_u16(),
        latency_ms = latency.as_millis() as u64,
        "request completed"
    );

    response
}

// middleware/auth.rs
use axum::{
    extract::Request,
    http::HeaderMap,
    middleware::Next,
    response::Response,
};
use crate::error::AppError;

pub async fn auth(headers: HeaderMap, request: Request, next: Next) -> Result<Response, AppError> {
    let token = headers
        .get("Authorization")
        .and_then(|v| v.to_str().ok())
        .ok_or(AppError::unauthorized("missing authorization header"))?;

    let _claims = validate_token(token)?;
    Ok(next.run(request).await)
}
```
