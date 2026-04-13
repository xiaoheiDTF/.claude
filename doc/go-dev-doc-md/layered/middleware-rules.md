# middleware 包开发规则

> 所属模式：标准分层
> 所属层：中间件层
> 包路径：`internal/middleware`

---

## 1. 创建规则

- 一个关注点一个中间件文件
- 横切关注点：认证、日志、限流、CORS、恢复

## 2. 文件命名规则

功能名 + `_middleware.go`，如 `auth_middleware.go`, `logging_middleware.go`。

## 3. 代码质量规则

### 【强制】
- 中间件只做横切关注点
- 不包含业务逻辑
- 正确传播 `context.Context`

### 【禁止】
- 在中间件中做业务判断
- 吞掉 panic（除非是 recovery 中间件）
- 修改响应体

### 【推荐】
- 使用结构体配置中间件行为
- Request ID 透传

## 4. 代码模板

```go
package middleware

import (
    "log/slog"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
)

func Logging(logger *slog.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.Request.URL.Path

        c.Next()

        logger.Info("request",
            "status", c.Writer.Status(),
            "method", c.Request.Method,
            "path", path,
            "latency", time.Since(start),
            "client_ip", c.ClientIP(),
        )
    }
}

func Recovery(logger *slog.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        defer func() {
            if err := recover(); err != nil {
                logger.Error("panic recovered",
                    "error", err,
                    "path", c.Request.URL.Path,
                )
                c.AbortWithStatus(http.StatusInternalServerError)
            }
        }()
        c.Next()
    }
}
```
