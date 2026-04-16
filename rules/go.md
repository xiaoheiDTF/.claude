---
paths:
  - "**/*.go"
---

# Go 编码规范

> 综合 Effective Go / Uber Go Style Guide / Go Code Review Comments / Go Best Practices

## 命名规范

- 导出标识符：PascalCase（`UserService`, `GetUserInfo`）
- 未导出标识符：camelCase（`userInfo`, `calculateTotal`）
- 接口名：单方法接口以 `-er` 结尾（`Reader`, `Writer`, `Stringer`）；多方法接口用描述性名词
- 缩写全大写或全小写（`HTTPClient` / `httpClient`，而非 `HttpClient`）
- 布尔值以 is/has/can/should 开头（导出：`IsValid`；未导出：`isValid`）
- 常量：camelCase（`maxRetryCount`）；特殊常量可 PascalCase（`http.StatusOK`）
- 包名：全小写，单个单词，简短有意义（`http`, `json`, `user`）
- 避免在名称中重复包名（`user.User` → `user.Info` 或 `user.Service`）
- Getter 方法不加 Get 前缀（`Name()` 而非 `GetName()`；Setter 可用 `SetName()`）
- 测试函数：`Test<FunctionName>`，基准测试：`Benchmark<FunctionName>`

## 代码格式

- 使用 `gofmt` / `goimports` 自动格式化（无争议）
- 缩进：Tab（Go 标准）
- 行宽：无硬限制，但建议不超过 120 字符
- 左花括号不换行（强制）
- 导入分组：标准库 → 第三方库 → 本地包，每组空行分隔
- `goimports` 自动管理导入

## 包设计

- 包名简短、小写、单个单词（`fmt`, `http`, `encoding/json`）
- 包提供功能，不按类型划分（`user` 包包含所有用户相关功能，而非 `models`/`services`/`controllers`）
- 避免包名 `util`, `common`, `helpers`（应拆分为更具体的包）
- 包的 API 应最小化（只导出必要的）
- `internal` 目录限制包的导入范围
- 循环依赖必须重构
- 包文档（`doc.go`）描述包的整体功能

## 函数设计

- 函数签名清晰，参数顺序：context → 主要参数 → 选项参数
- 所有公共函数接收 `context.Context` 作为第一个参数（`func DoSomething(ctx context.Context, ...)`)
- 返回值命名：简单函数可省略，复杂函数命名返回值提高可读性
- 错误作为最后一个返回值（`func GetUser(id int) (*User, error)`）
- 函数体控制在 80 行以内，建议 30 行
- 提前返回减少嵌套（guard clauses）
- 使用函数选项模式（Functional Options）处理复杂配置

## 错误处理

- 始终检查 error（`if err != nil`），不允许忽略
- 错误向上传播时添加上下文（`fmt.Errorf("get user %d: %w", id, err)`）
- 使用 `%w` 包装错误以支持 `errors.Is()` / `errors.As()` 解包
- 自定义错误类型实现 `error` 接口（`type NotFoundError struct { ... }`）
- 业务错误使用 `errors.New()` / `fmt.Errorf()` 或 sentinel error
- 不要用 panic 处理正常业务错误（仅用于不可恢复的程序性错误）
- 在调用边界统一处理错误（HTTP handler、gRPC handler、CLI main）
- 使用 `errors.Join()`（Go 1.20+）聚合多个错误
- 使用 `errors.Is()` 检查错误类型，`errors.As()` 提取特定错误

## 接口设计

- 隐式实现：不需要 `implements` 关键字
- 在使用方定义接口，而非实现方（消费者定义需要的行为）
- 接口保持小（1-3 个方法）；单方法接口最灵活
- 使用组合构建大接口（`type ReadWriter interface { Reader; Writer }`）
- 不需要接口的地方不要加接口（YAGNI）
- 接口值可能为 nil（注意 nil 接口 vs nil 值的区分）

## 并发编程

- 不要通过共享内存通信，而要通过通信共享内存（Goroutine + Channel）
- 使用 `sync.WaitGroup` 等待一组 goroutine 完成
- 使用 `context.Context` 控制超时和取消
- 使用 `sync.Mutex` / `sync.RWMutex` 保护共享状态
- 使用 `sync.Once` 确保只执行一次初始化
- 使用 `sync.Pool` 复用临时对象减少 GC 压力
- Channel 方向：只发送 `chan<-` / 只接收 `<-chan`
- 使用 `select` 处理多 channel 操作
- Worker Pool 模式控制并发数（`semaphore.Weighted` 或固定数量 worker）
- 避免 goroutine 泄漏：确保所有 goroutine 都有退出路径
- 使用 `errgroup` 管理一组 goroutine 的错误

## 切片与映射

- 切片初始化指定容量避免扩容（`make([]T, 0, n)`）
- 追加时预分配（`s = make([]T, 0, len(src))`）
- 使用 `copy()` 复制切片，注意 `append` 可能共享底层数组
- 空切片判断用 `len(s) == 0` 而非 `s == nil`
- Map 不是并发安全的，需要 `sync.RWMutex` 或 `sync.Map`
- Map 初始化指定容量（`make(map[K]V, n)`）
- 检查 key 存在（`v, ok := m[key]`）

## 结构体与方法

- 结构体字段顺序：按逻辑分组，大字段或对齐字段放在前面（内存优化）
- 使用嵌入（embedding）实现组合，而非继承
- 值接收者 vs 指针接收者：需要修改状态或避免拷贝时用指针；否则用值
- 不要混用值接收者和指针接收者（同一类型的方法保持一致，优先指针）
- 使用 `struct{}` 作为无意义的值类型（如 `map[string]struct{}` 实现 Set）
- 实现 `Stringer` 接口（`String() string`）提供可读表示
- 实现 `error` 接口让结构体本身可作为错误

## 测试规范

- 框架：标准库 `testing` + `testify`（断言）
- 测试文件：`<name>_test.go`，放在同包下
- 表驱动测试（Table-Driven Tests）是 Go 的首选模式
- 使用 `t.Run` 组织子测试
- 使用 `t.Parallel()` 标记可并行测试
- 基准测试 `BenchmarkXxx` + `b.N`
- 使用 `httptest` 测试 HTTP handler
- Mock 使用接口 + 手写 mock 或 `gomock` / `mockery`
- 测试覆盖率：`go test -cover`，新代码 ≥ 80%
- 集成测试使用 build tag 分离（`//go:build integration`）

## 性能优化

- 使用 `pprof` 分析 CPU 和内存瓶颈
- 字符串拼接使用 `strings.Builder`
- 使用 `sync.Pool` 复用对象减少 GC
- 避免不必要的 `[]byte` ↔ `string` 转换
- 使用 `encoding/json` 的 `Decoder` 流式处理大 JSON
- 数据库批量操作，使用事务
- HTTP 客户端复用连接（共享 `http.Client`）
- 避免在热路径中使用 `reflect`
- 使用泛型（Go 1.18+）减少重复代码和 `interface{}` 使用

## 安全规范

- SQL 使用参数化查询（`db.Query("SELECT * FROM users WHERE id = $1", id)`）
- 密码使用 `bcrypt` / `argon2` 哈希
- 禁止硬编码密钥，使用环境变量
- 使用 `crypto/rand` 生成随机数，不使用 `math/rand`
- HTTP handler 验证所有输入
- 使用 `html/template` 而非 `text/template` 输出 HTML（自动转义）
- TLS 配置使用安全的最低版本和加密套件
- 依赖审计：`go vuln check`

## 魔法变量治理

### 三级判定

| 级别 | 条件 | 做法 |
|------|------|------|
| ① inline | 只在 1~2 处使用，不跨模块 | 直接写在代码中 |
| ② 常量文件 | 跨 3+ 模块使用，或容易拼错 | `const UpperSnakeCase = "value"` 在 `constants.go` 中，按域分组 |
| ③ 类型约束 | 天然属于类型定义 | `type Role string` + `const ( RoleUser Role = "user" )` 自定义类型 |

**配置数值** → 环境变量（`os.Getenv("KEY")` + 默认值回退）或配置结构体。

### 标准写法

```go
// constants.go
const (
    SSEEventToken = "token"
    SSEEventDone  = "done"
)
```

### 替换原则

- **纯机械替换**：只改字面量为常量引用，不改变运行时行为
- **值完全一致**：常量值必须与原硬编码完全一致

### 实现顺序

定义常量文件（底层零依赖）→ 替换消费代码 → 同步文档
