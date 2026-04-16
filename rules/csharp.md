---
paths:
  - "**/*.cs"
---

# C# 编码规范

> 综合 Microsoft C# Coding Conventions / Framework Design Guidelines / C# Coding Standards (Dennis Doomen) / ReSharper 建议

## 命名规范

- 类、接口、结构体、枚举、委托、事件：PascalCase（`UserService`, `IRepository`）
- 方法、属性：PascalCase（`GetUserInfo`, `UserName`）
- 局部变量、参数：camelCase（`userName`, `itemCount`）
- 私有字段：camelCase 加 `_` 前缀（`_userName`, `_logger`）或 m_ 前缀
- 常量：PascalCase（`MaxRetryCount`）或 UPPER_SNAKE_CASE
- 命名空间：PascalCase，与目录结构匹配（`Company.Project.Module`）
- 接口以 `I` 开头（`IUserService`, `IRepository<T>`）
- 布尔属性/变量以 Is/Has/Can/Should 开头（`IsValid`, `HasPermission`）
- 事件：PascalCase（`ButtonClick`, `DataLoaded`）；事件处理：`On<Event>`
- 异常类以 `Exception` 结尾（`ValidationException`）
- 测试类：`<ClassName>Tests`（`UserServiceTests`）
- 文件名：与 public 类名一致，PascalCase
- 泛型类型参数：`T` + 描述（`TEntity`, `TResponse`）

## 代码格式

- 缩进：4 空格（不使用 Tab）
- 行宽：120 字符
- 左花括号换行（Allman 风格，C# 惯例）
- 使用 `dotnet format` 自动格式化
- EditorConfig 统一项目格式
- 每个文件一个类型（internal 类型可例外）
- 文件范围命名空间（C# 10+）：`namespace MyApp.Services;`

## 类型系统

- 优先使用 `class` 实现行为，`record`（C# 9+）实现不可变数据
- 使用 `struct` 仅用于小而简单的值类型（< 16 字节）
- 使用 `record struct`（C# 10+）定义轻量不可变值类型
- 优先使用 `var` 当右侧类型明显时（`var user = new UserService()`）
- 不使用 `var` 当类型不明确时（`var result = Process()` → 用具体类型）
- 使用 nullable reference types（C# 8+）：`string?` 而非 `string`
- 避免使用 `dynamic`，使用泛型或模式匹配
- 使用 `IEnumerable<T>` 作为返回类型（延迟执行），`List<T>` 仅在需要具体集合时
- 使用 `IReadOnlyList<T>` / `IReadOnlyDictionary<T>` 暴露不可变集合

## 属性与字段

- 使用属性而非公共字段（`public string Name { get; set; }`）
- 不可变属性使用 init（`public string Name { get; init; }`）
- 自动属性优先（不需要额外逻辑时）
- 计算属性保持简单（不超过 3-5 行），复杂逻辑提取方法
- 私有字段使用 `_` 前缀 + camelCase

## 方法设计

- 方法名 PascalCase，动词开头（`GetUser`, `CalculateTotal`）
- 参数不超过 4 个；复杂场景使用 Options 对象或 Builder 模式
- 使用可选参数和默认值（`void Log(string message, LogLevel level = LogLevel.Info)`）
- 单一职责，方法体控制在 30 行以内
- 提前返回减少嵌套
- 使用表达式体方法简化单行方法（`public override string ToString() => $"{Name} ({Age})";`）
- 输出参数避免使用，优先返回元组或自定义类型

## 异步编程

- 返回 `Task` / `Task<T>` / `ValueTask<T>`（高性能场景）
- 异步方法以 `Async` 后缀（`GetUserAsync`）
- 使用 `async/await`，不直接操作 `Task` 方法
- 使用 `CancellationToken` 支持取消（`async Task<User> GetUserAsync(int id, CancellationToken ct = default)`）
- 使用 `await using` 管理异步资源（`IAsyncDisposable`）
- 使用 `ConfigureAwait(false)` 在库代码中（避免死锁）
- 并行操作使用 `Task.WhenAll`
- 避免 `async void`（仅事件处理器允许）
- 使用 `SemaphoreSlim` 做异步限流

## LINQ 与集合

- 使用 LINQ 方法语法（fluent API）而非查询语法（除非复杂的 join/group）
- 链式调用保持可读性（超过 3-4 个操作时考虑拆分）
- 使用 `Any()` 而非 `Count() > 0` 检查非空
- 注意延迟执行：使用 `ToList()` / `ToArray()` 在需要立即求值时
- 使用 `IReadOnlyCollection<T>` 代替 `IEnumerable<T>` 暴露集合（提供 Count）
- 字典访问使用 `TryGetValue` 代替 `ContainsKey + indexer`

## 错误处理

- 使用异常处理异常情况，不用于正常流程控制
- 自定义异常继承 `Exception`，提供多个构造函数
- 使用 `try/catch/finally` 确保资源释放
- 空引用检查：使用 null 条件运算符（`?.`）和 null 合并（`??`）
- 使用 `ArgumentException` / `ArgumentNullException` 验证参数
- 使用 `Result<T>` 模式处理可预期错误（C# 习惯）
- 日志记录异常时包含完整异常（`logger.LogError(ex, "Error processing user {UserId}", userId)`）

## 测试规范

- 框架：xUnit（推荐）/ NUnit / MSTest
- 测试类：`<ClassName>Tests`
- 测试方法：`<Method>_<Scenario>_<Expected>` 或描述性名称
- AAA 模式：Arrange → Act → Assert
- Mock 框架：Moq / NSubstitute
- 覆盖率：新代码 ≥ 80%（coverlet / dotCover）
- 集成测试使用 `WebApplicationFactory<Program>`
- 使用 `FluentAssertions` 提高断言可读性
- 测试独立、无共享可变状态

## 性能优化

- 使用 `StringBuilder` 拼接字符串（循环场景）
- 使用 `Span<T>` / `Memory<T>` 减少内存分配
- 使用 `ArrayPool<T>` 复用数组
- 集合初始化指定容量（`new List<T>(capacity)`）
- 使用 `struct` 减少堆分配（小而频繁创建的对象）
- 使用 `ref` / `in` / `out` 避免大结构体拷贝
- 使用 `Source Generator` 减少运行时反射
- 使用 `System.Text.Json` 代替 `Newtonsoft.Json`（性能更好）
- 使用 `BenchmarkDotNet` 做基准测试
- 对象池（`ObjectPool<T>`）复用昂贵对象

## 安全规范

- SQL 使用参数化查询（`SqlCommand` + `@param`）
- 密码使用 `BCrypt` / `Argon2` 哈希
- 禁止硬编码密钥，使用 `IConfiguration` / Azure Key Vault
- 使用 `ASP.NET Core Data Protection` 保护敏感数据
- 输入验证：`DataAnnotations` / `FluentValidation`
- CORS 配置最小化
- 使用 HTTPS 重定向
- 依赖审计：`dotnet list package --vulnerable`

## 魔法变量治理

### 三级判定

| 级别 | 条件 | 做法 |
|------|------|------|
| ① inline | 只在 1~2 处使用，不跨模块 | 直接写在代码中 |
| ② 常量文件 | 跨 3+ 模块使用，或容易拼错 | `public static class Constants { public const string UpperSnakeCase = "value"; }` |
| ③ 类型约束 | 天然属于类型定义 | `enum` + `Description` 特性 或 `record` |

**配置数值** → `appsettings.json` + `IConfiguration` + 环境变量覆盖。

### 替换原则

- **纯机械替换**：只改字面量为常量引用，不改变运行时行为
- **值完全一致**：常量值必须与原硬编码完全一致

### 实现顺序

定义常量文件（底层零依赖）→ 替换消费代码 → 同步文档
