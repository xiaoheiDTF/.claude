---
paths:
  - "**/*.scala"
  - "**/*.sc"
---

# Scala 编码规范

> 综合 Scala Style Guide (official) / Effective Scala (Twitter) / Databricks Scala Guide / Scala Best Practices

## 命名规范

- 类、Trait、对象、枚举：PascalCase（`UserService`, `HttpRequest`）
- 方法和变量：camelCase（`getUserInfo`, `userName`）
- 常量：UPPER_SNAKE_CASE（`MAX_RETRY_COUNT`，在 object 中）
- 包名：全小写（`com.company.project.module`）
- 文件名：PascalCase（`UserService.scala`）
- 布尔方法以 `is`/`has`/`can`/`should` 开头（`isValid`, `hasPermission`）
- 类型参数：单字母（`A`, `B`）或语义名（`Elem`, `Key`）
- 命名表达意图

## 代码格式

- 缩进：2 空格
- 行宽：100 或 120 字符
- 左花括号不换行
- 使用 `scalafmt` 自动格式化
- `.scalafmt.conf` 统一格式配置

## 类型系统

- 优先使用不可变数据结构（`val`, `List`, `Map`, `Set`）
- 使用 `case class` 定义数据（自动生成 `equals`/`hashCode`/`toString`/`copy`/`unapply`）
- 使用 `sealed trait` / `sealed abstract class` 定义封闭层次
- 使用 `Option[T]` 代替 `null`（`Some(value)` / `None`）
- 使用 `Either[L, R]` 处理错误（`Left(error)` / `Right(value)`）
- 避免显式 `return`（Scala 使用表达式）
- 使用模式匹配（`match`）处理分支逻辑
- 使用泛型提高代码复用
- 使用 `implicit` / `given/using`（Scala 3）精简参数传递

## 函数式编程

- 优先使用不可变集合（`List`, `Vector`, `Map`）
- 使用 `map`, `filter`, `foldLeft`, `flatMap` 等高阶函数
- 使用 for-comprehension 链式操作（`for { x <- xs; y <- ys } yield (x, y)`）
- 避免副作用：纯函数优先
- 使用 `cats` / `ZIO` 处理复杂函数式场景
- 使用 `lazy val` 延迟计算

## 错误处理

- 使用 `Try[T]` / `Either[E, T]` / `Option[T]` 处理可恢复错误
- 自定义错误类型（`sealed trait AppError` + case class）
- 在调用边界统一处理
- 使用 `cats.data.NonEmptyList` / `Validated` 处理验证错误
- 不使用异常处理正常业务流程

## 测试规范

- 框架：ScalaTest / MUnit / ScalaCheck
- 测试文件：`<ClassName>Spec.scala`
- 使用 `it should` / `must` 描述测试
- 属性测试使用 ScalaCheck
- 覆盖率：scoverage，新代码 ≥ 80%

## 性能

- 避免不必要的集合转换（`List` ↔ `Vector`）
- 使用 `Vector` 代替 `List`（随机访问场景）
- 使用 `Array` 在性能关键路径
- 使用 `lazy val` 避免不必要计算
- JVM 调优参数

## 魔法变量治理

### 三级判定

| 级别 | 条件 | 做法 |
|------|------|------|
| ① inline | 只在 1~2 处使用，不跨模块 | 直接写在代码中 |
| ② 常量文件 | 跨 3+ 模块使用，或容易拼错 | `object Constants { val UpperSnakeCase = "value" }` |
| ③ 类型约束 | 天然属于类型定义 | `sealed trait` + `case object` 或 `enum`（Scala 3） |

**配置数值** → `application.conf` (HOCON) + 环境变量覆盖。

### 替换原则

- **纯机械替换**：只改字面量为常量引用，不改变运行时行为
- **值完全一致**：常量值必须与原硬编码完全一致

### 实现顺序

定义常量文件（底层零依赖）→ 替换消费代码 → 同步文档
