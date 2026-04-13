---
paths:
  - "**/*.kt"
  - "**/*.kts"
---

# Kotlin 编码规范

> 综合 Kotlin Coding Conventions (JetBrains) / Android Kotlin Style Guide / Effective Kotlin / Ktlint

## 命名规范

- 类、接口、对象、枚举：PascalCase（`UserService`, `HttpRequest`）
- 函数和变量：camelCase（`getUserInfo`, `userName`）
- 常量：UPPER_SNAKE_CASE（`MAX_RETRY_COUNT`，`const val` 或顶层 `val`）
- 包名：全小写（`com.company.project.module`）
- 文件名：PascalCase（`UserService.kt`），可省略当仅含一个类时
- 布尔变量以 is/has/can/should 开头（`isValid`, `hasPermission`）
- 泛型参数：PascalCase（`T`, `E`, `R`, `TEntity`）
- 测试类：`<ClassName>Test`（`UserServiceTest`）
- 背引号（`` ）用于含空格/关键字的函数名（测试场景：`` `should return user when valid` ``）
- 命名表达意图而非实现

## 代码格式

- 缩进：4 空格
- 行宽：120 字符（Kotlin 官方无硬限制）
- 左花括号不换行
- 使用 `ktlint` / `detekt` 自动格式化和静态分析
- `.editorconfig` 统一格式
- 类成员顺序：属性 → 初始化块 → 构造函数 → 公共方法 → 私有方法 → 伴生对象
- 属性声明时，类型在冒号后（`val name: String`）
- 函数返回类型在冒号后（`fun getUser(id: Int): User`）

## 类型系统

- 优先使用 `val`（不可变），仅在必要时使用 `var`（可变）
- 使用 Kotlin 空安全：`String?` 表示可空，`String` 表示非空
- 使用安全调用（`?.`）、Elvis 运算符（`?:`）、非空断言（`!!`，仅当确定非空时）
- 使用 `let` / `run` / `apply` / `also` / `with` 作用域函数
- 使用 `data class` 定义纯数据类（自动 `equals`/`hashCode`/`toString`/`copy`）
- 使用 `sealed class` / `sealed interface` 限定类型层次
- 使用 `enum class` 定义有限枚举
- 使用 `value class`（inline class）包装原始类型（类型安全 + 零开销）
- 使用泛型（`reified` 类型参数配合 `inline`）
- 使用类型别名（`typealias UserMap = Map<Long, User>`）

## 函数设计

- 单表达式函数优先（`fun double(x: Int): Int = x * 2`）
- 参数默认值代替重载（`fun connect(host: String, port: Int = 8080)`）
- 使用具名参数提高可读性（`createUser(name = "John", age = 30)`）
- 使用扩展函数（extension functions）添加行为而不修改类
- 使用高阶函数和 Lambda 提高表达力
- 使用 `inline` 优化高阶函数（减少 lambda 对象分配）
- 单一职责，函数体控制在 30 行以内
- 提前返回减少嵌套

## 集合与函数式

- 使用函数式 API（`map`, `filter`, `fold`, `groupBy`, `associate`）
- 使用 `Sequence` 处理大数据集（惰性求值，`list.asSequence()`)
- 使用不可变集合（`listOf`, `mapOf`, `setOf`）
- 使用 `plus` / `minus` 操作符创建新集合（不修改原集合）
- 使用 `buildList` / `buildMap` 构建集合
- 避免在循环中修改集合（函数式风格或创建新集合）

## 协程与异步

- 使用 Kotlin Coroutines + Flow 处理异步
- `suspend` 函数标记异步操作
- 使用 `Dispatchers` 切换线程（`Dispatchers.IO`, `Dispatchers.Main`）
- 使用 `viewModelScope` / `lifecycleScope` 管理 Android 协程生命周期
- 使用 `Flow` 处理数据流（冷流）；`SharedFlow` / `StateFlow` 热流
- 使用 `suspendCancellableCoroutine` 包装回调 API
- 使用 `supervisorScope` / `coroutineScope` 结构化并发
- 异常处理：`CoroutineExceptionHandler` 或 `try/catch` 在协程内

## 错误处理

- 使用 `Result<T>` 封装操作结果（`Result.success(value)`, `Result.failure(exception)`）
- 自定义异常继承 `Exception`
- 使用密封类表示操作状态（`sealed class UiState { object Loading; data class Success(val data: T); data class Error(val message: String) }`）
- 在调用边界处理错误（ViewModel / UseCase）
- 使用 `runCatching { }.getOrDefault()` 安全执行
- 不允许空 catch 块

## 测试规范

- 框架：JUnit 5 + MockK / Mockito Kotlin
- 测试类：`<ClassName>Test`
- 使用 `@Test` 标注
- 使用 backtick 方法名（`` `should return user when id is valid` ``）
- 使用 `assertk` / `strikt` 或 JUnit 断言
- Mock 使用 `mockk<ClassName>()`
- 协程测试使用 `runTest` + `TestDispatcher`
- 覆盖率：Kover / JaCoCo，新代码 ≥ 80%
- Android：使用 `Robolectric` 或 Instrumented Test

## 性能优化

- 使用 `Sequence` 避免中间集合分配（大数据链式操作）
- 避免不必要的对象创建（高频路径使用对象池或基本类型数组）
- 使用 `inline` 减少 lambda 分配
- 使用 `value class` 零开销包装
- 使用 `Array` / `IntArray` 代替 `List<Int>`（性能关键路径）
- 使用 `Flow` 而非 `Channel`（大部分场景）
- 使用 `measureTimedValue` 测量性能

## 安全规范

- 禁止硬编码密钥/token
- 使用 Android Keystore / 环境变量
- 网络请求使用 HTTPS
- 使用 `EncryptedSharedPreferences` 存储敏感数据
- SQL 参数化查询（Room）
- 依赖审计
- ProGuard / R8 混淆
