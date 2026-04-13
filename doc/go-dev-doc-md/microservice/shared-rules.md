# 共享库规则

> 所属模式：微服务架构
> 适用场景：多服务共享通用逻辑
> 包路径：`pkg/`（Monorepo）或独立 Go Module

---

## 1. 创建规则

- 只放真正被多个服务使用的代码
- 共享库不包含业务逻辑
- 每个包职责单一

## 2. 包命名规则

| 包名 | 职责 | 说明 |
|------|------|------|
| `pkg/logger` | 结构化日志 | 封装 slog |
| `pkg/tracing` | 链路追踪 | 封装 OpenTelemetry |
| `pkg/middleware` | 通用中间件 | 认证、限流、恢复 |
| `pkg/errors` | 统一错误 | 错误码、错误类型 |
| `pkg/response` | 统一响应 | Response[T] |
| `pkg/database` | 数据库工具 | 连接池、迁移 |
| `pkg/health` | 健康检查 | 标准检查端点 |

## 3. 代码质量规则

### 【强制】
- 零业务逻辑
- 零外部服务依赖（数据库、Redis 等除外）
- 接口优于具体类型
- 完整的 godoc 注释

### 【禁止】
- 放置只被一个服务使用的代码
- 包含特定业务的错误码
- 依赖特定服务的 Proto

### 【推荐】
- 共享库作为独立 Go Module（Monorepo 下可用 go.work）
- 语义化版本管理
- 提供 Example 测试

## 4. 共享库模板

```go
// pkg/response/response.go
package response

import "encoding/json"

type Response[T any] struct {
    Code    int    `json:"code"`
    Message string `json:"message"`
    Data    T      `json:"data,omitempty"`
}

func Success[T any](data T) Response[T] {
    return Response[T]{
        Code:    0,
        Message: "success",
        Data:    data,
    }
}

func Fail(code int, msg string) Response[any] {
    return Response[any]{
        Code:    code,
        Message: msg,
    }
}

func WriteJSON[T any](w http.ResponseWriter, status int, data Response[T]) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(data)
}
```

```go
// pkg/logger/logger.go
package logger

import (
    "log/slog"
    "os"
)

func NewJSONLogger(level string) *slog.Logger {
    var lvl slog.Level
    switch level {
    case "debug":
        lvl = slog.LevelDebug
    case "warn":
        lvl = slog.LevelWarn
    case "error":
        lvl = slog.LevelError
    default:
        lvl = slog.LevelInfo
    }

    return slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
        Level: lvl,
    }))
}
```

## 5. Go Workspace 配置（Monorepo）

```
// go.work
go 1.22

use (
    ./services/order-service
    ./services/user-service
    ./pkg
)
```

- 【推荐】Monorepo 使用 `go.work` 管理多模块
- 【推荐】每个服务是独立 Go Module
- 【推荐】共享库是独立 Go Module

> 核心参考来源：
> - [Go Module Layout](https://go.dev/doc/modules/layout) (A — Go 官方)
> - [Standard Go Project Layout](https://github.com/golang-standards/project-layout) (B — 社区)
