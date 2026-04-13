---
paths:
  - "**/*.lua"
---

# Lua 编码规范

> 综合 Lua Programming Gems / Lua Style Guide / Lua Users Wiki

## 命名规范

- 变量和函数：snake_case（`get_user_info`, `item_count`）
- 常量：UPPER_SNAKE_CASE（`MAX_RETRY_COUNT`）
- 局部变量始终用 `local` 声明（避免全局污染）
- 布尔变量以 `is_`/`has_` 开头（`is_valid`, `has_permission`）
- 模块返回表（`local M = {}; function M.foo() end; return M`）
- 私有函数用 `local` 声明，不放入模块表

## 代码格式

- 缩进：2 或 4 空格（不使用 Tab）
- 行宽：建议 120 字符
- 使用 `luacheck` 静态分析
- 使用 `StyLua` 自动格式化

## 核心规范

- 始终使用 `local` 声明变量（避免全局泄漏）
- 使用 `local` 函数声明（`local function foo() end` 而非 `function foo() end`）
- 字符串拼接使用 `..`
- 表（table）是唯一数据结构，灵活使用
- 使用 `ipairs` 遍历数组部分，`pairs` 遍历字典部分
- 使用 `#table` 获取数组长度
- 使用元表（metatable）实现 OOP 和运算符重载
- 错误处理使用 `pcall` / `xpcall`
- 使用 `require` 加载模块

## 错误处理

- 使用 `pcall` 保护调用（`local ok, result = pcall(func, args)`）
- 使用 `xpcall` + 错误处理函数
- 不使用 `error()` 控制正常流程
- 返回 nil + 错误信息模式（`return nil, "error message"`）

## 测试

- 框架：busted / luaunit
- 测试文件：`test_<name>.lua` 或 `*_spec.lua`
