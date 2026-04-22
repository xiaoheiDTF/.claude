---
paths:
  - "**/*.java"
---

# Java 编码规范

> 综合 Google Java Style Guide / Alibaba Java Coding Guidelines / Effective Java (Joshua Bloch) / Oracle Java Conventions

## 命名规范

- 类、接口、枚举：PascalCase（`UserService`, `HttpStatus`）
- 方法和变量：camelCase（`getUserInfo`, `isActive`）
- 常量：UPPER_SNAKE_CASE（`MAX_RETRY_COUNT`, `LOG_PREFIX`）
- 包名：全小写，点分隔（`com.company.project.module`）
- 文件名：与 public 类名一致，PascalCase
- 布尔变量以 is/has/should/can 开头（`isValid`, `hasPermission`）
- 测试类：`<ClassName>Test`（`UserServiceTest`）
- 抽象类可加 `Abstract` 或 `Base` 前缀（`AbstractProcessor`）
- 接口不加 I 前缀（`UserService` 而非 `IUserService`）
- 泛型类型：单大写字母（`T` 通用类型、`E` 集合元素、`K` 键、`V` 值、`R` 返回值）
- 异常类以 `Exception` 结尾（`BusinessException`）
- 工具类以 `Utils` 或 `Helper` 结尾（`StringUtils`）
- 命名应表达意图（`elapsedTime` 而非 `t`，`employeeCount` 而非 `n`）

## 代码格式

- 缩进：4 个空格，不使用 Tab
- 行宽：100 或 120 字符（团队统一）
- 左花括号不换行（K&R 风格）
- 类/接口成员顺序：静态变量 → 实例变量 → 构造函数 → 公共方法 → 私有方法 → 内部类
- 方法参数不超过 5 个；超过时封装为参数对象
- 每个类一个文件（内部类除外）
- 使用 IDE 格式化配置统一风格（Google Java Format 或 Spotless）

## 类与接口设计

- 优先组合而非继承（Effective Java Item 18）
- 面向接口编程：依赖注入接口而非实现类
- 使用 `final` 标注不可变字段和不可覆盖方法
- 最小化类和成员的可访问性（Effective Java Item 15）
- 不可变类优先：所有字段 `private final`，无 setter，返回防御性拷贝
- 使用 `record`（Java 16+）定义纯数据载体（`public record User(Long id, String name) {}`）
- 接口只定义行为契约，不包含实现细节
- 抽象类用于模板方法模式和代码复用
- 避免深层继承层次（≤ 3 层）

## 方法设计

- 方法长度不超过 30 行（不含空行和注释）
- 单一职责，一个方法做一件事
- 参数不超过 3 个；使用 Builder 模式或参数对象处理复杂构造
- 提前返回（guard clauses）减少嵌套
- 方法名是动词或动词短语（`findUserById`, `calculateTotal`）
- 使用 `var` 局部变量类型推断（Java 10+），类型明显时使用
- 避免在方法中修改输入参数
- 纯函数优先，副作用集中在外层

## 异常处理

- 不允许空 catch 块；至少记录日志
- 使用检查异常（checked）处理可恢复错误，非检查异常（unchecked/Runtime）处理编程错误
- 自定义异常继承 `RuntimeException`（业务异常），合理定义异常层次
- 异常信息包含上下文（操作名、参数值、当前状态）
- 使用 `try-with-resources` 管理资源（AutoCloseable）
- 在调用边界统一处理异常（Controller Advice、Filter）
- 不要用异常控制正常业务流程
- 保留原始异常链（`new BusinessException("msg", cause)`）
- 日志记录异常时使用 `log.error("msg", exception)` 而非 `log.error(exception.getMessage())`

## 泛型与集合

- 优先使用泛型，禁止 raw type（`List<String>` 而非 `List`）
- 使用 `List` 接口类型而非 `ArrayList` 实现类型声明变量
- 返回空集合而非 `null`（`Collections.emptyList()`）
- 使用 `EnumMap` / `EnumSet` 处理枚举键值
- 使用不可变集合（`List.of()`, `Map.of()`, `Collections.unmodifiableList()`）
- 泛型通配符：PECS 原则（Producer Extends, Consumer Super）
- 集合初始化指定容量（`new ArrayList<>(expectedSize)`）

## 并发编程

- 优先使用高级并发工具（`ExecutorService`, `CompletableFuture`, `CountDownLatch`）
- 不直接使用 `Thread`，使用线程池（`Executors` 或自定义 `ThreadPoolExecutor`）
- 共享可变状态必须同步（`synchronized` / `ReentrantLock` / `Atomic*`）
- 优先使用 `java.util.concurrent` 包中的并发集合
- `CompletableFuture` 组合异步操作（`thenApply`, `thenCompose`, `allOf`）
- 使用 `volatile` 保证可见性，但注意它不保证原子性
- 避免在锁内执行耗时操作（I/O、网络）
- 使用 `ThreadLocal` 注意清理（防止内存泄漏）
- 虚拟线程（Java 21+）简化高并发 I/O 密集型场景

## Optional 使用

- 方法返回值可能为空时返回 `Optional<T>` 而非 `null`
- 不要将 `Optional` 用作字段或方法参数类型
- 使用 `Optional.map/flatMap/filter` 链式操作
- 提供 `orElse` / `orElseThrow` 默认值或异常处理
- 不要在 `Optional` 上直接调用 `get()`（先检查 `isPresent()` 或用 `orElseThrow()`）

## 日志规范

- 使用 SLF4J + Logback / Log4j2，不使用 `System.out.println`
- 日志级别：ERROR（影响功能的错误）→ WARN（潜在问题）→ INFO（关键业务流程）→ DEBUG（调试信息）→ TRACE（详细追踪）
- 使用参数化日志（`log.info("User {} logged in", userId)`），避免字符串拼接
- 生产环境默认 INFO 级别，调试时调整为 DEBUG
- 敏感信息脱敏（密码、token、身份证号）
- 异常日志必须包含堆栈信息（`log.error("msg", exception)`）
- 使用 MDC（Mapped Diagnostic Context）传递追踪信息（traceId, userId）

## 测试规范

- 框架：JUnit 5 + Mockito（单元）、Spring Boot Test（集成）
- 测试类：`<ClassName>Test`；测试方法：`<method>_<scenario>_<expected>`
- AAA 模式：Arrange → Act → Assert
- 覆盖率：新代码 ≥ 80%，核心逻辑 ≥ 95%（JaCoCo）
- Mock 外部依赖，不 mock 被测类的内部方法
- 测试独立、可重复、无执行顺序依赖
- 使用 `@ParameterizedTest` 测试多种输入
- 集成测试使用 `@SpringBootTest`，单元测试不启动 Spring 容器
- 测试数据使用 `@BeforeEach` 准备，`@AfterEach` 清理

## 性能优化

- 字符串拼接使用 `StringBuilder`（循环场景）或 `String.format`（格式化）
- 集合初始化指定容量避免扩容
- 使用 `Stream API` 处理集合，但注意并行流（`parallelStream`）的适用场景
- 数据库访问使用连接池（HikariCP），批量操作代替逐条处理
- 缓存热点数据（Caffeine / Redis）
- I/O 操作使用缓冲（BufferedReader / BufferedOutputStream）
- 避免在循环中创建大量临时对象
- 使用 `jmh` 做基准测试，不凭感觉优化

## 安全规范

- SQL 必须参数化（PreparedStatement），禁止字符串拼接
- 密码使用 BCrypt / Argon2 哈希，禁止明文或 MD5/SHA1
- 禁止硬编码密钥/token，使用环境变量或配置中心
- 输入验证：所有外部输入必须校验（类型、长度、范围、格式）
- 输出编码：防止 XSS（HTML/JSON/URL 编码）
- 日志脱敏：禁止记录密码、token、完整身份证号
- 依赖审计：OWASP Dependency-Check
- HTTPS 传输敏感数据
- 最小权限原则：文件、数据库、API 权限最小化

## 魔法变量治理

### 核心原则：不要为一次性字符串创建常量

- **只在 1 处使用的字符串** → **直接 inline**，禁止抽成常量
- **只在 1 个文件内使用 2 次的字符串** → **仍然 inline**，重复写两遍也比造一个没用的常量类好
- **跨 3+ 个文件使用，或极易拼写错误** → 才允许放到 `common/constants/`
- **天然属于类型定义**（角色、状态、错误码） → 用 `enum`

> ⚠️ **严禁**为 JSON 字段名、Map key、SSE 事件名等创建"假常量类"——即定义了一堆 `public static final String` 却几乎没有被引用，最后变成无人维护的僵尸代码。

### 三级判定

| 级别 | 条件 | 做法 |
|------|------|------|
| ① inline（默认） | 只在 1~2 处使用，不跨模块 | **直接写在代码中**。不要为了避免"魔法变量"而制造无用抽象 |
| ② 常量类 | 跨 3+ 模块使用，或容易拼错 | `public final class` + `private` 构造函数 + `public static final String`，放在 `common/constants/` |
| ③ 枚举 | 天然属于类型定义（角色、状态、错误码） | `enum` + `@JsonValue` + `fromValue()`，放在 `common/enums/` |

**配置数值**（超时、阈值、端口等环境相关值）→ `@ConfigurationProperties` 内部类 + `application.yml` 环境变量覆盖。

### 触发信号（满足以下才抽常量）

- [ ] 同一字符串在 **3 个以上文件**出现（如 `"token"`, `"user_id"`）
- [ ] 配置数值直接写在业务逻辑中（如 `60_000L`, `4000`）
- [ ] 错误码和错误文案硬编码（如 `404`, `"会话不存在"`）
- [ ] 协议字段名在 **多个模块**散落且容易拼错

**以下情况不触发**：
- JSON 字段名只在一两个 `Map.of()` 或 `node.get()` 中出现 → inline
- Prompt 模板中的示例 JSON key → inline（Prompt 本身已经是字符串常量）
- 卡片/响应文案（如 `"下单成功"`）只在一处使用 → inline

### 反例（禁止这样做）

```java
// ❌ 错误：为一个只在 1 个地方使用的字符串创建常量类
public final class JsonField {
    public static final String COLLECTED_INFO = "collected_info"; // 只被引用 0 次
    public static final String TYPE = "type";                      // 只被引用 1 次
}

// ✅ 正确：直接使用
Map.of("collected_info", travelInfo.toMap());
node.get("type");
```

### 标准写法

**常量类**：`public final class` + `private` 构造函数（禁止实例化）+ `public static final String UPPER_SNAKE_CASE`

**枚举**：`@JsonValue` 在 `getValue()` 上 + `fromValue(String)` 静态反查方法

**配置内部类**：Spring Boot `@ConfigurationProperties` 内嵌 `public static class` + getter/setter + 默认值

### 替换原则

- **纯机械替换**：只改字面量为常量引用，不改变运行时行为
- **值完全一致**：常量值必须与原硬编码完全一致
- **switch 避坑**：`enum.getValue()` 不是编译期常量，不能做 switch case 标签，应转 switch 为 if-else + `Enum.XXX.getValue().equals()`
- **不改接口签名**：DTO/Entity 字段类型不因常量替换而改变

### 实现顺序

确定字符串确实被多处使用 → 定义常量/枚举/配置（底层零依赖）→ 替换消费代码中的硬编码 → 同步文档
