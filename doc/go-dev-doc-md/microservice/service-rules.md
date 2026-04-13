# 微服务内部结构规则

> 所属模式：微服务架构
> 适用场景：单个微服务内部的代码组织

---

## 1. 服务入口规则

### main.go 铁律

```go
package main

import (
    "context"
    "log/slog"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"

    "myproject/internal/config"
    "myproject/internal/handler"
    "myproject/internal/repository"
    "myproject/internal/service"
)

func main() {
    // 1. 加载配置
    cfg := config.MustLoad()

    // 2. 初始化日志
    logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
        Level: slog.LevelInfo,
    }))

    // 3. 初始化依赖（手动依赖注入）
    db := MustConnectDB(cfg.Database)
    repo := repository.NewOrderRepo(db)
    svc := service.NewOrderService(repo)
    h := handler.NewOrderHandler(svc)

    // 4. 启动 HTTP 服务
    mux := http.NewServeMux()
    h.RegisterRoutes(mux)

    srv := &http.Server{
        Addr:         cfg.Server.Addr(),
        Handler:      mux,
        ReadTimeout:  10 * time.Second,
        WriteTimeout: 30 * time.Second,
        IdleTimeout:  60 * time.Second,
    }

    // 5. 优雅关闭
    go func() {
        logger.Info("server starting", "addr", srv.Addr)
        if err := srv.ListenAndServe(); err != http.ErrServerClosed {
            logger.Error("server error", "error", err)
            os.Exit(1)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    logger.Info("shutting down server...")
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        logger.Error("server forced to shutdown", "error", err)
    }

    logger.Info("server exited")
}
```

### main.go 规则

- 【强制】main.go 只做依赖组装和启动
- 【强制】实现优雅关闭（graceful shutdown）
- 【强制】使用手动依赖注入，不用 DI 框架
- 【推荐】main.go 不超过 100 行

## 2. 依赖注入

Go 社区推荐**手动依赖注入**（constructor injection），不使用 DI 框架。

```go
// 正确：手动构造函数注入
func NewOrderService(repo OrderRepository, publisher EventPublisher) *OrderService {
    return &OrderService{
        repo:      repo,
        publisher: publisher,
    }
}

// 推荐：使用 wire 时也保持接口注入
```

- 【强制】所有依赖通过构造函数注入
- 【强制】依赖类型使用接口，不使用具体类型
- 【推荐】简单项目手动注入，复杂项目可用 `google/wire`

## 3. 配置管理

- 【强制】每个服务有自己的配置文件
- 【强制】敏感信息从环境变量读取
- 【推荐】使用环境变量覆盖配置文件值
- 【推荐】配置结构体强类型

## 4. 健康检查

```go
// 健康检查端点
func HealthCheck(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

// 就绪检查（含依赖检查）
func ReadinessCheck(db *sql.DB) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        if err := db.PingContext(r.Context()); err != nil {
            w.WriteHeader(http.StatusServiceUnavailable)
            return
        }
        w.WriteHeader(http.StatusOK)
    }
}
```

- 【强制】实现 `/health` 端点
- 【推荐】实现 `/ready` 端点（检查依赖可用性）
