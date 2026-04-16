---
paths:
  - "**/*.php"
---

# PHP 编码规范

> 综合 PSR-1 / PSR-12 / PSR-4 / Laravel Best Practices / PHP The Right Way / Symfony Coding Standards

## 命名规范

- 类、接口、Trait、枚举：PascalCase（`UserService`, `HttpRequest`）
- 方法：camelCase（`getUserInfo`, `calculateTotal`）
- 函数（全局）：snake_case（`get_user_info`）或 camelCase（框架约定优先）
- 变量：camelCase（`userName`, `itemCount`）或 snake_case（项目统一）
- 常量：UPPER_SNAKE_CASE（`MAX_RETRY_COUNT`, `API_BASE_URL`）
- 命名空间：PascalCase，与目录结构匹配（`App\Services\User`）
- 文件名：PascalCase（类文件 `UserService.php`）或 snake_case（视图/配置）
- 布尔变量以 is/has/can/should 开头（`$isValid`, `$hasPermission`）
- 接口不加 I 前缀（`UserRepository` 而非 `IUserRepository`）
- 抽象类可加 `Abstract` 前缀（`AbstractController`）
- Trait 用形容词或功能描述（`HasTimestamps`, `Loggable`）
- 测试类：`<ClassName>Test`（`UserServiceTest`）

## 代码格式（PSR-12）

- 缩进：4 空格（不使用 Tab）
- 行宽：建议 120 字符
- 左花括号：类/方法换行，控制结构不换行
- 使用 PHP-CS-Fixer 或 PHP CodeSniffer 自动格式化
- 文件必须使用 Unix LF 换行
- 文件末尾一个空行
- 纯 PHP 文件省略 `?>` 关闭标签
- 声明 `declare(strict_types=1)` 开启严格类型

## 类型系统

- 启用 `declare(strict_types=1)`
- 所有函数必须声明参数类型和返回类型
- 使用 PHP 8+ 联合类型（`int|string`）、null 联合（`?string`）
- 使用 `mixed` 替代无类型声明
- 使用 `never` 返回类型（总是抛异常或 exit）
- 使用 PHP 8.1+ Enum（`enum Status: string { case Active = 'active'; }`）
- 使用 `readonly` 属性（PHP 8.1+）或 `readonly class`（PHP 8.2+）
- 使用命名参数提高可读性（`createUser(name: 'John', age: 30)`）
- 使用属性（Attributes）替代注解（PHP 8+）
- 避免使用 `array` 类型提示，使用具体结构（DTO / Value Object）

## 函数与方法

- 方法名 camelCase，动词开头（`getUser`, `calculateTotal`）
- 单一职责，方法体控制在 30 行以内
- 参数不超过 4 个；复杂场景使用 DTO / Options 对象
- 使用类型声明：`public function getUser(int $id): User`
- 提前返回减少嵌套
- 默认参数放在末尾
- 避免在方法中修改输入参数（不可变优先）
- 使用 `...` 展开运算符处理可变参数（`function sum(int ...$numbers): int`）

## 类与面向对象

- 单一职责原则（SRP）：一个类一个职责
- 使用 `readonly class` 或 `final class` 明确类意图
- 依赖注入（DI）：通过构造函数注入，不使用 `new` 在服务层
- 使用接口定义契约（`interface UserRepositoryInterface`）
- 使用 Trait 实现代码复用（注意 Trait 的职责要单一）
- 使用 `__construct` 进行依赖注入
- 避免使用魔术方法（`__get`, `__set`），除非框架需要
- 使用 Value Object（值对象）封装业务概念（`Email`, `Money`, `PhoneNumber`）
- DTO（数据传输对象）用于层间数据传递

## 错误处理

- 使用异常（Exception）而非返回错误码
- 自定义异常继承适当基类（`class UserNotFoundException extends RuntimeException`）
- 在调用边界统一捕获（Controller / Command Handler）
- 不允许空 catch 块；至少记录日志
- 使用 `finally` 确保资源释放
- 使用 `throw` 表达式（PHP 8+）：`$value ?? throw new InvalidArgumentException()`
- 日志使用 PSR-3 Logger（Monolog）
- 异常信息包含上下文（操作名、ID、状态）

## 数据库

- 使用 ORM（Eloquent / Doctrine）或 Query Builder
- SQL 必须参数化（`DB::select('SELECT * FROM users WHERE id = ?', [$id])`）
- 使用 Migration 管理数据库版本
- 使用事务包裹多步操作（`DB::transaction(function () { ... })`）
- 模型中使用批量赋值保护（`$fillable` / `$guarded`）
- 软删除（Soft Deletes）用于重要数据
- 避免 N+1 查询（使用 Eager Loading：`User::with('posts')->get()`）

## 安全规范

- SQL 参数化查询，禁止字符串拼接
- 密码使用 `password_hash()` / `password_verify()`（BCrypt / Argon2）
- XSS 防护：模板引擎自动转义（Blade `{{ }}` 而非 `{!! !!}`）
- CSRF 保护：使用框架内置 token
- 输入验证：使用框架 Validator / Form Request
- 禁止硬编码密钥，使用 `.env` 环境变量
- 使用 `htmlspecialchars()` 手动输出转义
- 文件上传验证类型和大小
- 依赖审计：`composer audit`
- 使用 CSP（Content Security Policy）头

## 测试规范

- 框架：PHPUnit（标准）/ Pest（简洁语法）
- 测试文件：`<ClassName>Test.php`
- 测试方法：`test_<behavior>`（`test_user_can_be_created_with_valid_data`）
- 使用 Data Provider 参数化测试
- Factory 模式创建测试数据（Laravel Factory /自定义）
- Mock 使用 `PHPUnit Mock` 或 `Mockery`
- 覆盖率：新代码 ≥ 80%（`phpunit --coverage`）
- 集成测试使用内存数据库或测试数据库
- 测试独立、可重复、无共享可变状态

## 性能优化

- 使用 OPcache 加速
- 使用 `composer dump-autoload -o` 优化自动加载
- 数据库查询优化：索引、批量操作、避免 N+1
- 缓存：Redis / Memcached（`Cache::remember()`）
- 队列处理耗时任务（Laravel Queue / Symfony Messenger）
- 使用 Collection 代替数组循环操作（Laravel）
- 避免 `sleep()` 阻塞请求
- 大数据集使用 `chunk()` 分块处理
- 使用 `yield` 生成器处理大数据集（减少内存）

## 魔法变量治理

### 三级判定

| 级别 | 条件 | 做法 |
|------|------|------|
| ① inline | 只在 1~2 处使用，不跨模块 | 直接写在代码中 |
| ② 常量文件 | 跨 3+ 模块使用，或容易拼错 | `const UPPER_SNAKE_CASE = 'value';` 在常量类中 |
| ③ 类型约束 | 天然属于类型定义 | PHP 8.1 `enum` + `string` backed |

**配置数值** → `config/` 文件 + `env()` 辅助函数 + `.env` 环境变量。

### 替换原则

- **纯机械替换**：只改字面量为常量引用，不改变运行时行为
- **值完全一致**：常量值必须与原硬编码完全一致

### 实现顺序

定义常量文件（底层零依赖）→ 替换消费代码 → 同步文档
