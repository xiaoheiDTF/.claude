# gRPC 通信规则

> 所属模式：微服务架构
> 包路径：`internal/handler/grpc`

---

## 1. 创建规则

- 一个 Proto 服务定义对应一个 gRPC Handler
- Proto 文件放在 `api/proto/` 目录

## 2. 文件命名规则

- Proto 文件：`order.proto`
- 生成代码：`order_grpc.pb.go`, `order.pb.go`
- Handler 实现：`order_handler.go`

## 3. 代码质量规则

### 【强制】
- Proto 定义使用 `buf` 或 `protoc` 管理
- gRPC Handler 只做请求转换和调用 Service
- 使用 `context.Context` 传递超时和取消
- 错误使用 `status` 包转换为 gRPC 状态码

### 【禁止】
- 在 Handler 中包含业务逻辑
- 直接在 Proto 中暴露数据库模型
- 忽略 gRPC 截止时间（deadline）

### 【推荐】
- 使用 `buf` 替代 `protoc` 管理 Proto
- 内部服务间使用 gRPC，外部暴露 REST
- 使用 gRPC 拦截器（Interceptor）做认证、日志

## 4. Proto 定义模板

```protobuf
// api/proto/order/v1/order.proto
syntax = "proto3";
package order.v1;
option go_package = "myproject/api/proto/order/v1;orderv1";

service OrderService {
    rpc CreateOrder(CreateOrderRequest) returns (CreateOrderResponse);
    rpc GetOrder(GetOrderRequest) returns (GetOrderResponse);
    rpc ListOrders(ListOrdersRequest) returns (ListOrdersResponse);
}

message CreateOrderRequest {
    int64 user_id = 1;
    repeated OrderItemInput items = 2;
}

message OrderItemInput {
    int64 product_id = 1;
    int32 quantity = 2;
}

message CreateOrderResponse {
    int64 id = 1;
    string status = 2;
    int64 total = 3;
}

message GetOrderRequest {
    int64 id = 1;
}

message GetOrderResponse {
    int64 id = 1;
    int64 user_id = 2;
    string status = 3;
    int64 total = 4;
    string created_at = 5;
}

message ListOrdersRequest {
    int64 user_id = 1;
    int32 page = 2;
    int32 page_size = 3;
}

message ListOrdersResponse {
    repeated GetOrderResponse orders = 1;
    int32 total = 2;
}
```

## 5. Handler 模板

```go
package grpc

import (
    "context"

    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
    pb "myproject/api/proto/order/v1"
    "myproject/internal/service"
)

type OrderHandler struct {
    pb.UnimplementedOrderServiceServer
    svc service.OrderService
}

func NewOrderHandler(svc service.OrderService) *OrderHandler {
    return &OrderHandler{svc: svc}
}

func (h *OrderHandler) CreateOrder(ctx context.Context, req *pb.CreateOrderRequest) (*pb.CreateOrderResponse, error) {
    if req.UserId <= 0 {
        return nil, status.Error(codes.InvalidArgument, "user_id is required")
    }

    input := &dto.CreateOrderRequest{
        UserID: req.UserId,
    }
    for _, item := range req.Items {
        input.Items = append(input.Items, dto.OrderItemInput{
            ProductID: item.ProductId,
            Quantity:  int(item.Quantity),
        })
    }

    order, err := h.svc.Create(ctx, input)
    if err != nil {
        return nil, status.Errorf(codes.Internal, "create order: %v", err)
    }

    return &pb.CreateOrderResponse{
        Id:     order.ID,
        Status: order.Status,
        Total:  order.Total,
    }, nil
}
```

## 6. gRPC 拦截器模板

```go
// 认证拦截器
func AuthInterceptor(jwtKey string) grpc.UnaryServerInterceptor {
    return func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
        // 跳过不需要认证的方法
        if isPublicMethod(info.FullMethod) {
            return handler(ctx, req)
        }

        md, ok := metadata.FromIncomingContext(ctx)
        if !ok {
            return nil, status.Error(codes.Unauthenticated, "missing metadata")
        }

        token := extractToken(md)
        claims, err := validateToken(token, jwtKey)
        if err != nil {
            return nil, status.Error(codes.Unauthenticated, "invalid token")
        }

        // 注入用户信息到 context
        ctx = context.WithValue(ctx, ctxKeyUserID, claims.UserID)
        return handler(ctx, req)
    }
}
```
