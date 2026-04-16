---
paths:
  - "**/*.rb"
  - "**/*.rake"
---

# Ruby 编码规范

> 综合 Ruby Style Guide (bbatsov) / GitHub Ruby Style Guide / RuboCop / Rails Best Practices

## 命名规范

- 类和模块：PascalCase（`UserService`, `HttpRequest`）
- 方法和变量：snake_case（`get_user_info`, `user_count`）
- 常量：UPPER_SNAKE_CASE（`MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT`）
- 文件名：snake_case（`user_service.rb`）
- 目录名：snake_case（`app/services/user_service/`）
- 布尔方法以 `?` 结尾（`valid?`, `has_permission?`）
- 危险方法以 `!` 结尾（`save!`, `update!`）表示抛异常版本
- 测试文件：`<name>_test.rb` 或 `<name>_spec.rb`
- 命名表达意图（`elapsed_time` 而非 `t`，`user_age` 而非 `ua`）

## 代码格式

- 缩进：2 空格（不使用 Tab）
- 行宽：建议 120 字符
- 使用 `rubocop` 自动格式化和 lint
- `end` 与对应关键字对齐
- 方法定义括号：有参数时使用，无参数时省略（`def greet` 而非 `def greet()`）
- 字符串：优先双引号（支持插值），无插值时可用单引号
- 使用 `freeze` 不可变字符串（`STATUS = 'active'.freeze`）

## 方法设计

- 方法名 snake_case
- 单一职责，方法体控制在 10 行以内（Ruby 惯例追求简短）
- 参数不超过 3 个；复杂场景使用 options hash 或关键字参数
- 使用关键字参数提高可读性（`def create_user(name:, email:, role: 'member')`）
- 提前返回减少嵌套（guard clauses）
- 纯函数优先，副作用集中在外层
- 使用块（block）/ Proc / lambda 灵活处理回调
- 方法末尾隐式返回（不写 `return`，除非提前返回）

## 类与面向对象

- 单一职责原则
- 使用 `attr_reader` / `attr_accessor` / `attr_writer` 代替手动 getter/setter
- 构造函数 `initialize` 只做轻量初始化
- 使用 `Struct` / `Data`（Ruby 3.2+）定义简单数据类
- 模块（Module）用于 Mixin 和命名空间
- `include`（实例方法）vs `extend`（类方法）vs `prepend`（覆盖）
- 组合优于继承
- 使用 `private` / `protected` 控制方法可见性
- 使用 `FrozenError` 保护不可变对象

## 集合与迭代

- 优先使用 `each`, `map`, `select`, `reject`, `reduce` 等迭代方法
- 使用 `&:` 简写（`users.map(&:name)` 代替 `users.map { |u| u.name }`）
- 使用 `Hash` 的 `fetch` / `dig` 安全访问嵌套值
- 使用 `Array()` 包装可能的 nil/单值为数组
- 使用 `%w[]` 创建字符串数组（`%w[active pending suspended]`）
- 使用 `Enumerable` 方法链（`users.select(&:active?).map(&:name).uniq.sort`）

## 错误处理

- 使用异常处理异常情况（`raise` / `rescue`）
- 自定义异常继承 `StandardError`（非 `Exception`）
- 使用 `ensure` 确保资源释放（等价于 finally）
- 在调用边界统一处理异常
- 不允许空 rescue（至少 `rescue => e; logger.error e; end`）
- 使用 `begin...rescue...end` 包裹可能失败的操作
- 使用 `retry` 限制重试次数（避免无限循环）

## Rails 特定（如适用）

- 胖模型瘦控制器（Fat Model, Skinny Controller）
- 使用 Scope 封装查询（`scope :active, -> { where(status: 'active') }`）
- 使用 Concerns 提取共享模型逻辑
- 使用 Service Object 处理复杂业务逻辑
- 使用 `Strong Parameters` 过滤请求参数
- 使用 `dependent: :destroy` / `dependent: :nullify` 管理关联删除
- N+1 查询使用 `includes` / `eager_load` / `preload`
- 数据库查询用 `find`, `find_by`, `where`，避免 `all` 加载全部

## 测试规范

- 框架：RSpec（推荐）/ Minitest
- 描述用 `describe` / `context` / `it`
- 使用 `expect` 语法（`expect(user).to be_valid`）
- Factory 使用 FactoryBot（`create`, `build`, `build_stubbed`）
- Mock 使用 `rspec-mocks` / `instance_double`
- 覆盖率：SimpleCov，新代码 ≥ 80%
- 测试独立、可重复
- 系统测试使用 Capybara

## 性能优化

- 使用 `Benchmark` / `benchmark-ips` 测量性能
- 大集合使用 `lazy`（`ActiveRecord::Relation` 惰性加载）
- 使用 `find_each` 批量处理大量记录（`User.find_each(batch_size: 500) { |u| ... }`）
- 缓存：`Rails.cache.fetch`
- 避免在循环中查询数据库
- 使用 `pluck` 提取单列（`User.pluck(:email)` 而非 `User.all.map(&:email)`）
- 使用 `Bullet` gem 检测 N+1 查询

## 安全规范

- SQL 使用参数化（`User.where("email = ?", email)`）
- 密码使用 `has_secure_password`（BCrypt）
- XSS 防护：ERB 自动转义（`<%= %>` 而非 `<%== %>`）
- CSRF 保护：`protect_from_forgery`
- 禁止硬编码密钥，使用 Rails Credentials / 环境变量
- 使用 `Strong Parameters` 过滤输入
- 依赖审计：`bundle audit`

## 魔法变量治理

### 三级判定

| 级别 | 条件 | 做法 |
|------|------|------|
| ① inline | 只在 1~2 处使用，不跨模块 | 直接写在代码中 |
| ② 常量文件 | 跨 3+ 模块使用，或容易拼错 | `UPPER_SNAKE_CASE = "value"` 在 `constants.rb` 或模块中 |
| ③ 类型约束 | 天然属于类型定义 | `Module` + `freeze` 或 `Struct` |

**配置数值** → `ENV.fetch("KEY", default_value)` + `.env` 文件。

### 替换原则

- **纯机械替换**：只改字面量为常量引用，不改变运行时行为
- **值完全一致**：常量值必须与原硬编码完全一致

### 实现顺序

定义常量文件（底层零依赖）→ 替换消费代码 → 同步文档
