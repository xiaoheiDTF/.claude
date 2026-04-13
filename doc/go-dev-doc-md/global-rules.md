# Go 开发全局规则

> AI 生成 Go 代码时必须遵守的铁律，适用于所有架构模式（标准分层 / Clean Architecture / 微服务）
> 最后更新：2026-04-11

---

## 一、命名铁律

| 场景 | 规则 | 正确示例 | 错误示例 |
|------|------|---------|---------|
| 包名 | 全小写，单个词，无下划线 | `order`, `httputil` | `orderService`, `order_service`, `util` |
| 文件名 | snake_case | `order_service.go`, `user_handler_test.go` | `orderService.go`, `OrderService.go` |
| 导出类型 | PascalCase | `OrderService`, `UserResponse` | `orderService`, `ORDER_SERVICE` |
| 未导出类型 | camelCase | `orderService`, `userRepo` | `OrderService`, `order_service` |
| 导出函数 | PascalCase | `CreateOrder`, `ParseConfig` | `createOrder`, `Create_Order` |
| 未导出函数 | camelCase | `createOrder`, `parseConfig` | `CreateOrder`, `create_order` |
| 变量 | camelCase，短名称优于长名称 | `c` for `client`, `r` for `reader` | `lineCount`(局部变量) |
| 常量 | PascalCase（导出）或 camelCase（未导出） | `MaxRetries`, `defaultTimeout` | `MAX_RETRIES`(Go 不用全大写) |
| 接口 | 通常 -er 后缀，或行为描述 | `Reader`, `OrderRepository` | `IReader`, `ReaderInterface` |
| 缩写 | 全大写或全小写，保持一致 | `HTTPClient`, `userID`, `serveHTTP` | `HttpClient`, `userId`, `serveHttp` |
| 测试文件 | 被测文件名 + `_test.go` | `service_test.go` | `test_service.go` |

### 命名补充规则

- 【强制】包名不要用 `util`, `common`, `misc`, `api`, `types`, `interfaces` 等无意义名称
- 【强制】函数名不要重复包名（`yamlconfig.Parse` 而非 `yamlconfig.ParseYAMLConfig`）
- 【强制】方法名不要重复接收者类型名
- 【推荐】局部变量用短名，作用域越远名称越长
- 【推荐】接收者名用 1-2 个字母缩写（如 `c` for `Client`），同一类型所有方法保持一致

> 来源：[Google Go Style Guide - Naming](https://google.github.io/styleguide/go/), [Uber Go Style Guide - Style](https://github.com/uber-go/guide/blob/master/style.md), [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments)

---

## 二、编码铁律（AI 必须遵守）

### 2.1 绝对禁止

- 【禁止】用 `_` 丢弃 `error` 返回值 — 必须检查每个 error
- 【禁止】用 `panic` 处理正常业务错误 — 只用 `error` 返回值
- 【禁止】`init()` 函数中做复杂初始化（网络请求、文件 I/O、goroutine 启动）
- 【禁止】将 `context.Context` 放入 struct 字段 — 作为函数第一个参数传递
- 【禁止】创建自定义 Context 类型或用其他接口替代 `context.Context`
- 【禁止】使用 `math/rand` 生成密钥 — 必须用 `crypto/rand`
- 【禁止】在 for 循环中使用 `defer`（除非在匿名函数内）
- 【禁止】拷贝 `sync.Mutex`、`sync.WaitGroup` 等同步原语 — 必须使用指针
- 【禁止】在边界处不拷贝 slice/map（函数修改传入的切片/映射）
- 【禁止】启动不管理生命周期的 goroutine（fire-and-forget）
- 【禁止】未关闭的资源（Response Body、File、Conn 等）
- 【禁止】在业务代码中使用 `fmt.Println` — 使用 `log` 或 `slog`
- 【禁止】使用已废弃的 `io/ioutil` 包 — 使用 `io` 和 `os` 替代
- 【禁止】在项目根目录使用 `/src` 目录（这是 Java 惯例，不是 Go 的）

### 2.2 必须遵守

- 【强制】使用 `gofmt` / `goimports` 格式化代码（无争议的标准）
- 【强制】所有导出的类型、函数、常量、变量必须有 godoc 注释
- 【强制】注释以被注释对象的名称开头，完整句子，以句号结尾
- 【强制】函数签名中 `context.Context` 作为第一个参数
- 【强制】错误处理使用 `if err != nil` 模式，缩进错误路径，保持正常路径最小缩进
- 【强制】使用 `defer` 清理资源（Close、Unlock 等）
- 【强制】函数返回接口，接受具体类型（Accept interfaces, return concrete types）
- 【强制】`switch` 语句必须有 `default` 分支（当 case 不穷尽时）
- 【强制】结构体初始化使用字段名（`Order{ID: id, Status: status}` 而非 `Order{id, status}`）
- 【强制】import 分组：标准库 → 第三方库 → 项目内部包，组间空行分隔
- 【强制】并发安全：启动 goroutine 必须明确何时退出
- 【强制】channel 大小只能是 0 或 1（需要更大时必须有充分理由并记录注释）
- 【强制】使用 `go vet` 检查代码
- 【强制】枚举值使用 `iota`，从 0 开始（标准惯例），从 1 开始也允许（如果有 0 值歧义）

### 2.3 推荐做法

- 【推荐】使用 `log/slog`（Go 1.21+）结构化日志
- 【推荐】错误包装使用 `fmt.Errorf("doing something: %w", err)`
- 【推荐】使用哨兵错误（`var ErrNotFound = errors.New("not found")`）
- 【推荐】使用 `errors.Is()` 和 `errors.As()` 检查错误
- 【推荐】slice 声明使用 `var s []string`（nil slice），而非 `s := []string{}`
- 【推荐】指定 slice/map 容量（`make([]int, 0, expectedSize)`）
- 【推荐】接口定义在使用方（消费者），而非实现方
- 【推荐】接口保持小（1-3 个方法）
- 【推荐】使用 `sync.Once` 做一次性初始化
- 【推荐】使用 `strconv` 代替 `fmt.Sprintf` 做基本类型转换
- 【推荐】避免不必要的字符串↔字节切片转换
- 【推荐】优先使用同步函数，由调用方决定是否异步
- 【推荐】使用表驱动测试（table-driven tests）

---

## 三、错误处理铁律

```go
// 哨兵错误
var (
    ErrNotFound     = errors.New("not found")
    ErrAlreadyExist = errors.New("already exists")
)

// 自定义错误类型
type BusinessError struct {
    Code    string
    Message string
    Cause   error
}

func (e *BusinessError) Error() string {
    return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

func (e *BusinessError) Unwrap() error {
    return e.Cause
}
```

```go
// 正确用法：缩进错误路径
func (s *OrderService) GetOrder(ctx context.Context, id int64) (*Order, error) {
    order, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("find order by id %d: %w", id, err)
    }
    // 正常逻辑保持最小缩进
    return order, nil
}

// 禁止用法
func (s *OrderService) GetOrder(ctx context.Context, id int64) (*Order, error) {
    order, err := s.repo.FindByID(ctx, id)
    if err == nil {
        // 正常逻辑在 if 内部 — 错误！
        return order, nil
    }
    return nil, err // 没有包装错误信息 — 错误！
}
```

- 【强制】错误信息不要大写开头，不要以标点结尾
- 【强制】包装错误时使用 `%w` 动词以保留原始错误链
- 【强制】错误只处理一次（不要既 log 又 return）
- 【强制】业务错误使用自定义错误类型或哨兵错误
- 【强制】使用 `errors.Is()` 比较哨兵错误，`errors.As()` 比较错误类型
- 【推荐】错误信息包含足够的上下文以便定位问题
- 【推荐】在 API 边界统一处理错误到响应格式

> 来源：[Uber Go Style Guide - Errors](https://github.com/uber-go/guide/blob/master/style.md), [Go Blog - Error Handling](https://go.dev/blog/error-syntax), [Datadog - Go Error Handling](https://www.datadoghq.com/blog/go-error-handling/)

---

## 四、日志铁律

```go
// 正确用法（使用 slog 结构化日志）
slog.Info("order created",
    "order_id", order.ID,
    "user_id", order.UserID,
)

slog.Error("failed to create order",
    "error", err,
    "user_id", userID,
)

// 禁止用法
fmt.Println("debug info")              // 禁止 fmt.Println
log.Println("order created: " + id)    // 禁止字符串拼接
slog.Info(fmt.Sprintf("order %d", id)) // 禁止 Sprintf 在日志中
```

- 【强制】使用 `log/slog`（Go 1.21+）或 `log` 包，不用 `fmt.Println`
- 【强制】日志使用结构化键值对，不使用字符串拼接
- 【强制】ERROR 级别必须附带错误对象
- 【强制】日志中不打印敏感信息（密码、Token、身份证号）
- 【推荐】方法入口用 DEBUG，关键业务节点用 INFO，异常用 ERROR
- 【推荐】日志 key 使用 snake_case 字符串

---

## 五、并发铁律

```go
// 正确用法：使用 context 控制生命周期
func (w *Worker) Run(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        case task := <-w.tasks:
            w.process(task)
        }
    }
}

// 正确用法：defer 关闭资源
resp, err := http.Get(url)
if err != nil {
    return err
}
defer resp.Body.Close()
```

- 【强制】启动 goroutine 必须明确何时/如何退出
- 【强制】使用 `context.Context` 传递取消信号
- 【强制】`sync.Mutex` 零值即可用，不需要 `make` 或 `new`
- 【强制】channel 由发送方关闭，不由接收方关闭
- 【强制】使用 `sync.Once` 确保初始化只执行一次
- 【禁止】fire-and-forget goroutine（启动后不等待退出）
- 【禁止】在 `init()` 中启动 goroutine
- 【推荐】优先使用同步函数，让调用方决定是否异步
- 【推荐】使用 `sync.WaitGroup` 或 `errgroup.Group` 等待 goroutine 退出
- 【推荐】使用 buffered channel 做限流（size=1 或 unbuffered）

---

## 六、接口设计铁律

```go
// 正确：在消费者侧定义接口
package service

type OrderRepository interface {
    FindByID(ctx context.Context, id int64) (*Order, error)
    Save(ctx context.Context, order *Order) error
}

type OrderService struct {
    repo OrderRepository
}

// 正确：返回具体类型
func NewOrderService(repo OrderRepository) *OrderService {
    return &OrderService{repo: repo}
}

// 错误：在生产者侧定义接口
// 错误：返回接口类型
```

- 【强制】接口定义在**消费者**侧，不在实现侧
- 【强制】接口保持小（1-3 个方法最佳）
- 【强制】不需要预先定义接口，等真正需要时再抽象
- 【强制】返回具体类型，让消费者决定是否需要接口
- 【推荐】接口命名通常以行为描述（`Reader`, `Runner`）或 `-er` 后缀
- 【推荐】不要为了 mock 而在实现侧定义接口

> 来源：[Go Code Review Comments - Interfaces](https://go.dev/wiki/CodeReviewComments), [Google Go Style Guide - Best Practices](https://google.github.io/styleguide/go/best-practices)

---

## 七、API 设计铁律

- 【强制】统一响应格式

```go
type Response[T any] struct {
    Code    int    `json:"code"`
    Message string `json:"message"`
    Data    T      `json:"data,omitempty"`
}

func Success[T any](data T) Response[T] {
    return Response[T]{Code: 0, Message: "success", Data: data}
}

func Fail(code int, msg string) Response[any] {
    return Response[any]{Code: code, Message: msg}
}
```

- 【强制】RESTful URL 设计
  - 资源用名词复数：`/orders`, `/users`
  - 动作用 HTTP Method：GET 查询、POST 新增、PUT 全量修改、PATCH 部分修改、DELETE 删除
  - 禁止 URL 中出现动词：`/createOrder` → `POST /orders`

- 【强制】请求参数校验

```go
type CreateOrderRequest struct {
    UserID int64  `json:"user_id" validate:"required"`
    ItemID int64  `json:"item_id" validate:"required"`
    Qty    int    `json:"qty" validate:"required,min=1"`
}
```

---

## 八、通用依赖规则

### 8.1 分层依赖铁律（适用于所有模式）

```
上层 → 下层（可以调用）
下层 → 上层（绝对禁止）
```

- 【强制】Handler 不直接操作数据库
- 【强制】Service 不依赖 HTTP 相关类型（`http.Request`, `gin.Context`）
- 【强制】Repository 不包含业务逻辑
- 【强制】所有层通过接口解耦（Go 的隐式接口）

### 8.2 跨层对象转换铁律

| 层 | 接收 | 返回 |
|----|------|------|
| Handler | Request / Query | Response / VO |
| Service | DTO / Request | DTO / Domain Model |
| Repository | Domain Model / Filter | Domain Model |

- 【强制】Domain Model（实体）不越层传递到 Handler
- 【推荐】使用手动转换或代码生成器（不推荐反射类库如 copier）

---

## 九、AI 生成自查清单

每次生成 Go 代码后，AI 必须逐项检查：

- [ ] 包名、类型名、函数名、变量名是否符合命名铁律
- [ ] 是否有未处理的 error 返回值
- [ ] 是否使用了 panic 处理正常错误
- [ ] 是否有魔法值（硬编码数字/字符串）
- [ ] 导出符号是否有 godoc 注释
- [ ] context.Context 是否作为第一个参数
- [ ] 资源（Response Body、File 等）是否用 defer 关闭
- [ ] 是否有 goroutine 泄漏风险
- [ ] 是否有同步原值拷贝问题
- [ ] import 是否按标准库/第三方/项目内分组
- [ ] 错误路径是否缩进，正常路径是否最小缩进
- [ ] 分层依赖是否正确（无反向依赖）
- [ ] DTO/VO/Model 转换是否正确
- [ ] 是否使用了 `gofmt` 兼容的代码格式

> 核心参考来源：
> - [Effective Go](https://go.dev/doc/effective_go) (A — 官方文档)
> - [Google Go Style Guide](https://google.github.io/styleguide/go/) (A — Google 官方)
> - [Uber Go Style Guide](https://github.com/uber-go/guide) (A — Uber 官方)
> - [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments) (A — Go 官方 Wiki)
> - [Go Module Layout](https://go.dev/doc/modules/layout) (A — Go 官方文档)
