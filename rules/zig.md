---
paths:
  - "**/*.zig"
---

# Zig 编码规范

> 综合 Zig Style Guide / Zig Documentation / Zig Best Practices

## 命名规范

- 函数和变量：snake_case（`get_user_info`, `item_count`）
- 类型：PascalCase（`User`, `HttpRequest`）
- 常量：snake_case（`const max_retry_count = 3;`）
- 文件级常量：snake_case（`const buffer_size: usize = 1024;`）
- 文件名：snake_case（`user_service.zig`）
- 布尔变量以 `is_`/`has_` 开头（`is_valid`, `has_permission`）
- comptime 参数使用 PascalCase（`fn(comptime T: type)`）

## 代码格式

- 使用 `zig fmt` 自动格式化（内置，无争议）
- 缩进：4 空格
- 行宽：无硬限制，建议 120 字符
- 左花括号不换行
- 不使用分号的地方不写（如 `defer`, `suspend` 后）

## 核心规范

- 不使用隐藏的控制流（无隐式异常、无隐式内存分配）
- 显式内存管理：使用 Allocator，手动分配和释放
- 错误处理使用 error union（`!T` 类型）
- 使用 `try` / `catch` 处理错误
- 使用 `defer` / `errdefer` 确保资源清理
- 使用 `comptime` 进行编译期计算
- 使用 `zig test` 运行测试
- 避免使用 `undefined`（除非必要，如未初始化缓冲区）
- 使用 `@as`, `@intCast` 等内置函数进行显式类型转换
- 使用 `pub` 控制可见性

## 错误处理

- 使用 error set（`error{NotFound, PermissionDenied}`）
- 使用 `!T`（ErrorUnion）返回可能失败的函数
- 使用 `try` 传播错误（`const user = try get_user(id);`）
- 使用 `catch` 处理错误（`const user = get_user(id) catch |err| handle(err);`）
- 使用 `errdefer` 在错误路径清理资源
- 错误集可以合并（`const MyError = error{NotFound} || OtherError`）

## 内存管理

- 所有分配需要 Allocator 参数（`fn init(allocator: Allocator) !Self`）
- 使用 `defer` 确保释放（`defer allocator.free(buffer);`）
- 使用 ArenaAllocator 批量释放
- 使用 GeneralPurposeAllocator 检测内存泄漏
- 避免返回指向栈的指针

## 测试

- 使用内置测试（`test "description" { ... }`）
- 运行：`zig test <file>`
- 使用 `std.testing` 断言（`try std.testing.expect(actual == expected);`）
