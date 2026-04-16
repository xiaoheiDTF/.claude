---
paths:
  - "**/*.swift"
---

# Swift 编码规范

> 综合 Swift API Design Guidelines (Apple) / GitHub Swift Style Guide / Ray Wenderlich Swift Style Guide / SwiftLint

## 命名规范

- 类型（类、结构体、枚举、协议）：PascalCase（`UserService`, `HttpRequest`）
- 函数和方法：camelCase（`getUserInfo`, `calculateTotal`）
- 变量和属性：camelCase（`userName`, `itemCount`）
- 常量：camelCase（`maxRetryCount`）或 PascalCase（类型属性 `static let MaxRetryCount`）
- 文件名：PascalCase（`UserService.swift`）
- 协议：描述能力用 `-able`/`-ible`（`Codable`, `Equatable`）；描述身份用名词（`Collection`）
- 布尔变量以 is/has/can/should 开头（`isValid`, `hasPermission`）
- 方法名首字母小写（`addObserver`）；工厂方法首字母大写（`UIImage.CGImage`）
- 缩写全大写（`URL`, `HTTP`, `ID`）但 camelCase 混合（`urlSession`, `userId`）
- 测试函数：`test<Behavior>`（`testUserCreationWithValidData`）

## 代码格式

- 缩进：4 空格或 2 空格（项目统一）
- 行宽：建议 120 字符
- 左花括号不换行（K&R 风格）
- 使用 SwiftLint 自动检查
- 冒号紧贴左边（`let name: String` 而非 `let name :String`）
- 尾随闭包仅在最后一个参数是闭包时使用
- 多行参数列表对齐或每行一个参数

## 类型系统

- 值类型优先：`struct` / `enum` > `class`（值语义避免共享可变状态）
- 使用 `struct` 定义数据模型；仅在需要引用语义或继承时使用 `class`
- 使用 `enum` + associated values 建模有限状态和变体
- 使用 `protocol` 定义接口（Swift 协议可比 Objective-C 协议更强大）
- 使用泛型（`Generic`）编写可复用组件
- 使用 `Any` / `AnyObject` 仅在必要时（优先具体类型或泛型）
- 使用 `typealias` 简化复杂类型（`typealias Completion = (Result<User, Error>) -> Void`）
- 使用 `some`（Swift 5.1+）和 `any`（Swift 5.7+）处理不透明类型和存在类型
- 使用 `async/await`（Swift 5.5+）替代回调

## Optionals

- 使用 `Optional<T>` / `T?` 明确表达可能为空的值
- 强制解包 `!` 仅在逻辑保证非 nil 时（`IBOutlet`, 测试代码）
- 优先安全解包：`if let`, `guard let`, `optional chaining`, `nil coalescing ??`
- 使用 `guard let` 提前退出（减少嵌套）
- 隐式解包 `T!` 仅用于 IBOutlet 和 unavoidable late init
- 使用 `optional map` / `flatMap` 链式操作

## 错误处理

- 使用 `throw` / `throws` 处理可恢复错误
- 使用 `Result<Success, Failure>` 传递异步/可延迟的错误
- 自定义错误枚举（`enum NetworkError: Error { case invalidURL, timeout }`）
- 使用 `do-catch` 捕获错误
- 使用 `try?` 转换为 Optional（不需要错误详情时）
- 使用 `try!` 仅在确定不会失败时（测试代码等）
- 在调用边界统一处理错误（ViewModel / Coordinator）
- 错误信息包含足够上下文

## 函数与闭包

- 函数签名清晰，参数命名包含标签（`func move(from start: Point, to end: Point)`）
- 省略标签用 `_`（`func add(_ element: T)`）仅当意义明显时
- 单一职责，函数体控制在 30 行以内
- 使用 `@discardableResult` 标注返回值可忽略的函数
- 闭包使用 `[weak self]` 避免循环引用
- 尾随闭包语法简洁
- 使用 `@escaping` 标注异步闭包

## 协议与扩展

- 使用 Protocol + Extension 实现默认实现（类似 trait）
- 使用 Protocol Composition（`protocol & protocol`）代替臃肿的协议
- 扩展用于组织代码（`// MARK: - UITableViewDataSource`）
- 条件扩展（`extension Array where Element: Equatable`）
- 协议作为类型约束（泛型）优于存在类型（`some Protocol` 优于 `Protocol`）

## 并发编程

- 使用 `async/await`（Swift 5.5+）处理异步
- 使用 `Task` 创建异步上下文
- 使用 `async let` 并行执行
- 使用 `Actor` 保护共享可变状态（线程安全）
- 使用 `Sendable` 标注可跨并发域传递的类型
- 使用 `TaskGroup` 管理结构化并发
- 使用 `withCheckedContinuation` 桥接回调 API

## UI 开发（SwiftUI）

- View 是 struct（值类型）
- 状态管理：`@State`（本地）、`@Binding`（传递）、`@StateObject`（拥有）、`@ObservedObject`（观察）、`@EnvironmentObject`（全局）
- 预览使用 `#Preview`
- 提取子视图保持 View 简洁
- 使用 `ViewModifier` 复用视图样式

## 测试规范

- 框架：XCTest / Swift Testing（Swift 5.9+）
- 测试文件：`<ClassName>Tests.swift`
- 测试方法：`test<behavior>`（`testUserCreationSucceeds`）
- 使用 `XCTestCase` / `@Test` 宏
- Mock 使用协议 + 手写 mock
- 覆盖率：Xcode Coverage，新代码 ≥ 80%
- UI 测试：XCUITest

## 性能优化

- 值类型避免不必要的拷贝（Copy-on-Write）
- 使用 `lazy` 延迟计算属性
- 使用 `inout` 避免大值类型拷贝
- 使用 Instruments 分析性能
- 避免主线程阻塞（耗时操作放后台）
- 图片缓存和异步加载
- 使用 `autoreleasepool` 管理临时对象

## 安全规范

- 禁止硬编码密钥，使用 Keychain / Secure Enclave
- 使用 `CryptoKit` 进行加密操作
- 使用 HTTPS（App Transport Security）
- 输入验证
- 使用 `Codable` 安全解析 JSON
- 依赖审计

## 魔法变量治理

### 三级判定

| 级别 | 条件 | 做法 |
|------|------|------|
| ① inline | 只在 1~2 处使用，不跨模块 | 直接写在代码中 |
| ② 常量文件 | 跨 3+ 模块使用，或容易拼错 | `enum Constants { static let upperSnakeCase = "value" }` |
| ③ 类型约束 | 天然属于类型定义 | `enum` + `String` raw value |

**配置数值** → `Info.plist` / `xcconfig` / 环境变量。

### 替换原则

- **纯机械替换**：只改字面量为常量引用，不改变运行时行为
- **值完全一致**：常量值必须与原硬编码完全一致

### 实现顺序

定义常量文件（底层零依赖）→ 替换消费代码 → 同步文档
