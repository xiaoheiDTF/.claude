# error 处理开发规则

> 所属模式：标准分层
> 最后更新：2026-04-11

---

## 1. 错误类型体系

```go
package errors

import (
    "fmt"
    "net/http"
)

// 业务错误码
const (
    CodeSuccess       = 0
    CodeBadRequest    = 400
    CodeUnauthorized  = 401
    CodeForbidden     = 403
    CodeNotFound      = 404
    CodeConflict      = 409
    CodeInternalError = 500
)

// BusinessError 业务错误
type BusinessError struct {
    Code    int    `json:"code"`
    Message string `json:"message"`
    cause   error
}

func (e *BusinessError) Error() string {
    return fmt.Sprintf("business error [%d]: %s", e.Code, e.Message)
}

func (e *BusinessError) Unwrap() error {
    return e.cause
}

func NewBusinessError(code int, msg string) *BusinessError {
    return &BusinessError{Code: code, Message: msg}
}

func WrapBusinessError(code int, msg string, err error) *BusinessError {
    return &BusinessError{Code: code, Message: msg, cause: err}
}
```

## 2. 统一错误处理中间件

```go
func ErrorHandler(logger *slog.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Next()

        // 检查是否有错误
        if len(c.Errors) == 0 {
            return
        }

        err := c.Errors.Last().Err

        var bizErr *errors.BusinessError
        if errors.As(err, &bizErr) {
            c.JSON(bizErr.Code, gin.H{
                "code":    bizErr.Code,
                "message": bizErr.Message,
            })
            return
        }

        // 未知错误返回 500
        logger.Error("unhandled error",
            "error", err,
            "path", c.Request.URL.Path,
        )
        c.JSON(http.StatusInternalServerError, gin.H{
            "code":    http.StatusInternalServerError,
            "message": "internal server error",
        })
    }
}
```

## 3. 错误处理铁律

- 【强制】Handler 层不使用 error 直接返回，由中间件统一处理
- 【强制】Service 层返回 `BusinessError` 或包装的 error
- 【强制】错误分类：业务错误（用户可理解）vs 系统错误（需要告警）
- 【强制】错误信息不含敏感数据（密码、Token、SQL）
- 【推荐】使用统一错误码体系
