# 大厂 Go 编码规范

> 综合 Uber、Google、字节跳动等权威编码规范
> 最后更新：2026-04-11

---

## 一、命名规范

| 场景 | 规则 | 正确示例 | 错误示例 |
|------|------|---------|---------|
| 包名 | 全小写，单个单词，无下划线 | `cache`, `auth`, `http` | `user_service`, `AuthService` |
| 文件名 | 全小写，下划线分隔 | `user_service.go` | `userService.go`, `UserService.go` |
| 结构体 | UpperCamelCase | `UserService`, `OrderHandler` | `user_service`, `userService` |
| 接口（单方法） | 以 er 后缀 | `Reader`, `Validator`, `Executor` | `Read`, `Validate` |
| 接口（多方法） | UpperCamelCase，体现功能 | `UserService`, `Repository` | `Userer`, `Manager` |
| 函数/方法 | UpperCamelCase（导出）/ camelCase（未导出） | `CreateOrder`, `getUserByID` | `create_order`, `Get_User` |
| 变量 | camelCase | `orderList`, `userCount` | `order_list`, `OrderList` |
| 常量 | camelCase（Go 惯例）或 SCREAMING_SNAKE_CASE | `maxRetries`, `StatusOK` | — |
| 枚举常量 | 类型前缀 + 状态名 | `HTTPMethodGet`, `HTTPMethodPost` | `GetMethod` |
| 布尔变量 | is/has/can/should 前缀 | `isValid`, `hasPermission` | `valid`, `permission` |
| 方法接收者 | 单字母，有语义 | `o *Order`, `u *User` | `order *Order`, `self *Order` |

### 命名补充规则

- 【强制】函数名应准确反映功能，使用祈使语气动词开头：`Get`, `Create`, `Delete`, `Update`, `List`
- 【强制】若包名已体现功能范畴，函数名可简化：`auth.Login` 而非 `auth.AuthLogin`
- 【强制】包名与标准库冲突时加前缀区分：`appio` 区别于 `io`
- 【推荐】避免无意义缩写，但行业通用缩写可用：`HTTP`, `JSON`, `ID`, `URL`

> 来源：[Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md), [字节跳动 Go 规范](https://www.haveyb.com/article/3102)

---

## 二、代码格式

### 2.1 格式化工具

- 【强制】统一使用 `gofmt` 或 `goimports` 格式化代码
- 【推荐】使用 `goimports`（在 gofmt 基础上自动管理 import 排序和依赖清理）
- 【强制】提交代码前必须运行格式化工具

### 2.2 行宽与缩进

- 【强制】单行代码不超过 120 个字符
- 【强制】使用 tab 缩进（gofmt 默认）
- 【强制】左大括号 `{` 不换行（Go 语法要求）

### 2.3 换行规则

- 【推荐】超出长度时，优先在逗号后换行：

```go
result := calculate(
    param1,
    param2,
    param3,
)
```

- 【推荐】逗号后不可行时，在运算符前换行：

```go
longExpression := veryLongVariable1 +
    veryLongVariable2 -
    veryLongVariable3
```

### 2.4 Import 分组排序

- 【强制】import 分为三组，用空行分隔：标准库 → 项目内部包 → 第三方包

```go
import (
    "encoding/json"
    "fmt"
    "strings"

    "myproject/models"
    "myproject/controller"

    "github.com/gin-gonic/gin"
    "go.uber.org/zap"
)
```

### 2.5 Trailing Comma

- 【推荐】多行列表使用 trailing comma，方便移动代码和减小 diff

```go
// 推荐
items := []string{
    "apple",
    "banana",
    "cherry",
}
```

> 来源：[Google Go Style Guide](https://google.github.io/styleguide/go/), [Uber Go Style](https://github.com/uber-go/guide/blob/master/style.md)

---

## 三、编码实践

### 3.1 错误处理

#### 错误封装

- 【强制】使用 `fmt.Errorf("%w", err)` 包装原始错误，禁止丢弃错误信息

```go
// 正确
func CreateUser(user *User) error {
    if user.Name == "" {
        return fmt.Errorf("user name cannot be empty")
    }
    if err := db.Save(user); err != nil {
        return fmt.Errorf("save user to database: %w", err)
    }
    return nil
}

// 错误 — 丢失了原始错误信息
if err := db.Save(user); err != nil {
    return errors.New("save failed")
}
```

#### 自定义错误类型

- 【强制】业务错误定义自定义类型，包含 Code 和 Message

```go
type BusinessError struct {
    Code    int    `json:"code"`
    Message string `json:"message"`
}

func (be *BusinessError) Error() string {
    return fmt.Sprintf("code: %d, message: %s", be.Code, be.Message)
}
```

#### 错误判断

- 【强制】使用 `errors.Is()` 判断特定错误类型
- 【强制】使用 `errors.As()` 进行自定义错误类型断言
- 【强制】禁止通过比较错误字符串判断错误类型

```go
// 正确
if errors.Is(err, sql.ErrNoRows) { ... }
var be *BusinessError
if errors.As(err, &be) { ... }

// 错误
if err.Error() == "not found" { ... }
```

#### 错误信息安全

- 【强制】错误信息禁止包含敏感信息（密码、手机号、身份证号等）

#### panic 使用

- 【强制】禁止在业务代码中使用 `panic`，只在上层 main 中 recover
- 【推荐】使用 `log.Fatal` 替代 panic 处理不可恢复错误

### 3.2 变量与常量

- 【强制】局部作用域使用短变量声明 `:=`

```go
// 正确
name := "John"

// 错误
var name string = "John"
```

- 【强制】常量定义必须指定类型

```go
// 正确
const MaxRetries int = 3

// 不推荐
const MaxRetries = 3
```

### 3.3 函数设计

- 【强制】函数参数不超过 3 个，超过时封装为结构体

```go
type OrderQuery struct {
    UserID string
    Status string
    Page   int
    Limit  int
}

func (oq OrderQuery) Validate() error {
    if oq.UserID == "" {
        return fmt.Errorf("user ID cannot be empty")
    }
    if oq.Page < 1 {
        return fmt.Errorf("page number must be greater than 0")
    }
    return nil
}

func ListOrders(query OrderQuery) ([]*Order, error) {
    if err := query.Validate(); err != nil {
        return nil, err
    }
    // 业务逻辑
}
```

- 【强制】函数返回切片和错误时，明确返回 `([]T, error)` 形式
- 【推荐】Options 模式处理可选参数

### 3.4 方法接收者

- 【强制】统一使用指针接收者（避免值拷贝开销），不可变小值类型除外
- 【强制】接收者命名为单字母，具有语义代表性

```go
// 正确
func (o *Order) Cancel() error { ... }
func (u *User) Validate() error { ... }

// 错误
func (order *Order) Cancel() error { ... }
func (self *User) Validate() error { ... }
```

### 3.5 接口设计

- 【推荐】保持接口小而精（1-3 个方法）
- 【推荐】由消费者定义接口，而非生产者
- 【强制】单方法接口以 `er` 后缀命名

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

### 3.6 Defer 使用

- 【强制】使用 defer 释放资源（文件、连接、锁）

```go
func ProcessFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return err
    }
    defer f.Close()
    // 处理文件
}
```

### 3.7 切片与 Map

- 【推荐】预分配切片和 Map 容量，避免频繁扩容

```go
// 正确
items := make([]Item, 0, len(source))
users := make(map[string]*User, expectedSize)
```

- 【强制】在函数边界处复制大切片/Map，防止外部修改

### 3.8 Channel 使用

- 【强制】明确 channel 方向：`chan<- T`（只写）、`<-chan T`（只读）
- 【推荐】channel 缓冲大小为 0 或 1，谨慎使用大缓冲

```go
func producer(ch chan<- int) { ... }
func consumer(ch <-chan int) { ... }
```

> 来源：[Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md), [字节跳动 Go 规范](https://www.haveyb.com/article/3102)

---

## 四、并发编程

### 4.1 Goroutine 管理

- 【强制】使用 `sync.WaitGroup` 或 `context.Context` 管理 goroutine 生命周期
- 【强制】禁止"裸 goroutine"（无退出机制的 goroutine），防止泄漏

```go
func ProcessTasks(tasks []Task) error {
    var wg sync.WaitGroup
    errCh := make(chan error, len(tasks))

    for _, task := range tasks {
        wg.Add(1)
        go func(t Task) {
            defer wg.Done()
            if err := t.Execute(); err != nil {
                errCh <- err
            }
        }(task)
    }

    go func() {
        wg.Wait()
        close(errCh)
    }()

    for err := range errCh {
        if err != nil {
            return err
        }
    }
    return nil
}
```

- 【强制】循环变量必须通过参数传递，避免闭包引用问题

```go
// 正确
for _, task := range tasks {
    go func(t Task) {
        process(t)
    }(task)
}

// 错误 — 所有 goroutine 引用最后一个 task
for _, task := range tasks {
    go func() {
        process(task)
    }()
}
```

### 4.2 锁使用

- 【强制】能用 `sync.RWMutex` 就不用 `sync.Mutex`（读多写少场景）
- 【强制】锁粒度尽量小，锁代码块内禁止调用 RPC
- 【强制】多个资源加锁必须保持一致的加锁顺序，防止死锁
- 【推荐】优先使用 channel 通信而非共享内存

### 4.3 Context 使用

- 【强制】context.Context 作为函数第一个参数传递
- 【推荐】在适当时机取消 context，释放 goroutine 资源

```go
func DoWork(ctx context.Context) error {
    select {
    case <-ctx.Done():
        return ctx.Err()
    case result := <-doSomething():
        return result
    }
}
```

> 来源：[Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)

---

## 五、项目结构

字节跳动推荐的 Go 项目结构：

```
project-name/
├── cmd/                    # 可执行程序入口
│   └── api/
│       └── main.go         # 仅负责初始化与启动
├── internal/               # 私有业务模块
│   ├── user/
│   │   ├── domain/         # 领域模型与核心业务逻辑
│   │   │   ├── model/      # 领域实体
│   │   │   └── service/    # 核心业务逻辑
│   │   ├── infra/          # 基础设施适配层
│   │   │   ├── repo/       # 数据访问实现
│   │   │   └── client/     # 外部服务客户端
│   │   └── api/            # 接口适配层（HTTP/gRPC）
│   └── common/             # 内部公共组件
├── pkg/                    # 跨项目公共组件（可复用）
├── config/                 # 配置文件（dev/test/prod）
├── deploy/                 # 部署配置（Dockerfile/K8s）
├── docs/                   # 项目文档
├── test/                   # 集成测试/性能测试
├── go.mod
└── Makefile                # 标准化构建脚本
```

### Makefile 规范

- 【强制】项目必须包含 Makefile，定义标准命令：

```makefile
build:    # 构建项目
test:     # 执行测试
lint:     # 代码检查
clean:    # 清理构建产物
```

> 来源：[字节跳动 Go 开发规范](https://www.haveyb.com/article/3102)

---

## 六、注释规范

### 6.1 包注释

- 【强制】每个包必须有包注释，包含功能简介、适用场景

```go
// Package cache 提供高效的内存缓存机制，支持多种缓存策略（LRU、LFU）。
// 适用场景：对热点数据频繁读取且数据更新频率较低的场景。
// 不适用场景：实时性要求极高、数据变化频繁的场景。
package cache
```

### 6.2 函数注释

- 【强制】导出函数必须有详细注释，包含功能描述、参数、返回值

```go
// GetFromCache 根据给定的键从缓存中获取对应的值。
// 参数 key：用于在缓存中查找值的唯一键。
// 返回值 value：从缓存中获取到的值，未找到返回 nil。
// 返回值 ok：是否成功获取，true 表示成功。
func GetFromCache(key string) (value interface{}, ok bool) { ... }
```

### 6.3 注释风格

- 【推荐】使用完整的句子，语言表达清晰准确
- 【推荐】中英文之间使用空格分隔
- 【强制】单行注释不超过 120 字符

> 来源：[Go 官方 Effective Go](https://go.dev/doc/effective_go), [字节跳动 Go 规范](https://www.haveyb.com/article/3102)

---

## 七、性能优化

### 7.1 字符串处理

- 【推荐】使用 `strconv` 代替 `fmt` 进行字符串与数字的转换

```go
// 正确（快 4-5 倍）
s := strconv.Itoa(42)

// 不推荐
s := fmt.Sprintf("%d", 42)
```

- 【推荐】避免重复的 `string` ↔ `[]byte` 转换
- 【推荐】大量字符串拼接使用 `strings.Builder`

```go
// 正确
var builder strings.Builder
for _, s := range parts {
    builder.WriteString(s)
}
result := builder.String()

// 不推荐
result := ""
for _, s := range parts {
    result += s
}
```

### 7.2 容器预分配

- 【强制】已知大小时预分配 slice/map 容量

```go
items := make([]Item, 0, expectedSize)
users := make(map[string]*User, expectedSize)
```

### 7.3 其他

- 【推荐】使用 `go.uber.org/atomic` 处理原子操作
- 【推荐】避免在热路径中进行不必要的内存分配
- 【推荐】使用 `sync.Pool` 复用临时对象

> 来源：[Uber Go Style Guide - Performance](https://github.com/uber-go/guide/blob/master/style.md)

---

## 参考来源

| 来源 | 质量等级 | 链接 |
|------|---------|------|
| Uber Go Style Guide | A | https://github.com/uber-go/guide/blob/master/style.md |
| Google Go Style Guide | A | https://google.github.io/styleguide/go/ |
| 字节跳动 Go 开发规范 | B | https://www.haveyb.com/article/3102 |
| Go 官方 Effective Go | A | https://go.dev/doc/effective_go |
| Go 编码规范（知乎） | B | https://zhuanlan.zhihu.com/p/63250689 |
