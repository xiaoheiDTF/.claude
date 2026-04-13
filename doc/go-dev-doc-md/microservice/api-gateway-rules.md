# API Gateway 规则

> 所属模式：微服务架构
> 适用场景：统一外部入口、认证鉴权、限流、路由

---

## 1. 核心职责

API Gateway 是微服务架构中的统一入口，负责：

| 职责 | 说明 |
|------|------|
| 路由 | 将请求转发到对应的后端服务 |
| 认证/授权 | 统一 JWT 校验、RBAC |
| 限流 | 防止滥用 |
| 熔断 | 保护后端服务 |
| 日志/指标 | 统一采集 |
| 协议转换 | REST → gRPC |

## 2. 技术选型

| 方案 | 适用场景 | 说明 |
|------|---------|------|
| 自建（Go） | 需要高度定制 | 使用 `gin`/`chi` + gRPC client |
| Kong | 通用场景 | 功能丰富，插件生态 |
| Envoy | Service Mesh | 高性能，支持 xDS |
| Traefik | 容器化部署 | 自动服务发现 |

## 3. 自建 Gateway 模板

```go
package gateway

import (
    "context"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
)

type Gateway struct {
    router      *gin.Engine
    connMap     map[string]*grpc.ClientConn
}

func NewGateway() *Gateway {
    g := &Gateway{
        router:  gin.Default(),
        connMap: make(map[string]*grpc.ClientConn),
    }
    g.setupRoutes()
    return g
}

func (g *Gateway) setupRoutes() {
    // 认证中间件
    auth := g.router.Group("/api/v1", AuthMiddleware())
    {
        auth.Any("/orders/*path", g.proxyToService("order-service", "localhost:50051"))
        auth.Any("/users/*path", g.proxyToService("user-service", "localhost:50052"))
    }
}

func (g *Gateway) proxyToService(name, addr string) gin.HandlerFunc {
    return func(c *gin.Context) {
        conn, err := g.getConn(addr)
        if err != nil {
            c.JSON(http.StatusBadGateway, gin.H{"error": "service unavailable"})
            return
        }
        // 根据 path 转发到对应 gRPC 方法
        _ = conn // 使用 conn 调用 gRPC 方法
        c.JSON(http.StatusOK, gin.H{"message": "proxied to " + name})
    }
}

func (g *Gateway) getConn(addr string) (*grpc.ClientConn, error) {
    if conn, ok := g.connMap[addr]; ok {
        return conn, nil
    }
    conn, err := grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
    if err != nil {
        return nil, err
    }
    g.connMap[addr] = conn
    return conn, nil
}

func (g *Gateway) Run(addr string) error {
    return g.router.Run(addr)
}

func (g *Gateway) Close() {
    for _, conn := range g.connMap {
        conn.Close()
    }
}
```

## 4. Gateway 铁律

- 【强制】Gateway 不包含业务逻辑
- 【强制】所有请求必须经过认证中间件（公开接口白名单）
- 【强制】超时设置合理（建议 10-30 秒）
- 【推荐】使用 gRPC 做内部转发
- 【推荐】实现健康检查端点
- 【推荐】实现优雅关闭（graceful shutdown）
