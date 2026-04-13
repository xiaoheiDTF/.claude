---
paths:
  - "**/*.ex"
  - "**/*.exs"
---

# Elixir 编码规范

> 综合 Elixir Style Guide / Elixir Official Guide / Elixir Best Practices / Credo

## 命名规范

- 模块：PascalCase（`UserService`, `MyApp.HTTP.Client`）
- 函数和变量：snake_case（`get_user_info`, `user_name`）
- 常量：UPPER_SNAKE_CASE（`@max_retry_count` 模块属性）
- 文件名：snake_case（`user_service.ex`），测试文件：`<name>_test.exs`
- 布尔函数以 `?` 结尾（`valid?`, `has_permission?`）
- 可能抛异常的函数以 `!` 结尾（`save!`, `insert!`）
- 宏：snake_case（`use`, `import`, `require`）
- 协议：PascalCase（`String.Chars`, `Enumerable`）
- 命名表达意图

## 代码格式

- 使用 `mix format` 自动格式化（无争议）
- 缩进：2 空格
- 行宽：98 字符（Elixir 默认）
- 使用 `credo` 静态分析
- `do` 关键字后换行
- `def`/`defp` 后空格（`def foo(arg1, arg2) do`）

## 核心规范

- 使用模式匹配（`def foo(%User{name: name}), do: name`）
- 使用管道 `|>` 链式操作（数据流从左到右）
- 不可变数据：所有数据结构不可变
- 使用 `Enum` / `Stream` 处理集合
- 使用 `with` 处理多步操作（替代嵌套 case）
- 使用结构体（`%User{}`）代替 map 定义已知形状的数据
- 使用模块属性定义常量（`@max_retry 3`）
- 使用 `@doc` / `@moduledoc` 添加文档
- 使用 `@spec` 添加类型规范

## 并发编程

- 使用 Actor 模型（`GenServer`, `Agent`, `Task`）
- 使用 `Task.async` / `Task.await` 并行执行
- 使用 `Flow` 处理大数据并行流
- 使用 `Supervisor` 和 `Application` 管理进程树
- 使用 `Registry` 管理进程注册
- 使用 `Phoenix.PubSub` 进程间通信
- OTP Supervisor 策略：one_for_one / one_for_all / rest_for_one

## 错误处理

- 使用 `{:ok, result}` / `{:error, reason}` 元组模式
- 使用 `with` 链式处理多个可能失败的操作
- 使用 `try/rescue` 仅在必要时（外部库异常）
- 使用 `!` 版本函数在确定成功时（`Repo.insert!`）
- 自定义异常使用 `defexception`
- 在边界层统一处理错误（Controller / LiveView）

## Phoenix 特定（如适用）

- 使用 Context 组织业务逻辑（`Accounts`, `Blog`）
- 使用 Ecto 进行数据库操作
- 使用 Changeset 验证和转换数据
- 使用 LiveView 构建交互式页面
- 使用 PubSub 实时更新

## 测试规范

- 框架：ExUnit（内置）
- 测试文件：`test/<context>/<module>_test.exs`
- 使用 `describe` 组织测试组
- 使用 `assert` / `refute` / `assert_raise`
- Mock 使用 `Mox`（并发安全）
- 覆盖率：`mix test --cover`
