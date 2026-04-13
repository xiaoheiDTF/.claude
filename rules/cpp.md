---
paths:
  - "**/*.c"
  - "**/*.cpp"
  - "**/*.cc"
  - "**/*.cxx"
  - "**/*.h"
  - "**/*.hpp"
  - "**/*.hxx"
---

# C/C++ 编码规范

> 综合 Google C++ Style Guide / C++ Core Guidelines (Bjarne Stroustrup) / LLVM Coding Standards / MISRA C

## 命名规范

- 类、结构体、枚举、类型别名：PascalCase（`UserService`, `HttpRequest`）
- 函数：snake_case（`get_user_info`, `calculate_total`）或 PascalCase（遵循项目框架约定）
- 变量：snake_case（`user_count`, `buffer_size`）
- 类成员变量：snake_case 加后缀 `_`（`name_`, `count_`）
- 常量：kPascalCase（Google 风格，`kMaxRetryCount`）或 UPPER_SNAKE_CASE
- 宏：UPPER_SNAKE_CASE（`MAX_BUFFER_SIZE`, `DEBUG_LOG`）
- 枚举值：kPascalCase（`kColorRed`）或 PascalCase
- 命名空间：snake_case（`user_service`, `http_handler`）
- 文件名：snake_case（`user_service.cpp`, `http_handler.h`）
- 模板参数：PascalCase（`T`, `Container`, `Allocator`）
- 布尔变量以 is/has/can/should 开头（`is_valid`, `has_permission`）
- 接口类（纯虚类）可加 `Interface` 后缀（`UserServiceInterface`）

## 代码格式

- 缩进：2 或 4 空格（不使用 Tab，或统一 Tab）
- 行宽：100 或 120 字符
- 左花括号：K&R 风格（函数定义花括号换行是 C 风格惯例）
- 使用 `clang-format` 自动格式化，项目统一配置 `.clang-format`
- 使用 `clang-tidy` 静态分析
- `#include` 顺序：对应头文件 → C 系统头文件 → C++ 标准库 → 第三方库 → 项目内头文件
- 使用 `#pragma once` 或传统 include guard

## 内存管理（C++）

- 优先使用智能指针：`std::unique_ptr`（独占所有权）、`std::shared_ptr`（共享所有权）
- 禁止裸 `new`/`delete`（用 `std::make_unique` / `std::make_shared`）
- 使用 RAII 管理所有资源（文件句柄、锁、socket）
- 使用 `std::string` 代替 C 字符串（`char*`）
- 使用 STL 容器代替原始数组（`std::vector`, `std::array`）
- 避免手动内存管理，用容器和智能指针代替
- 引用 > 指针：不需要 null 和重新绑定时优先用引用
- 使用 `std::optional` 表示可能为空的值（C++17）
- 使用 `std::variant` 代替联合体（type-safe union）

## 现代 C++ 特性（C++17/20/23）

- 使用 `auto` 推断局部变量类型（类型明显时），但不滥用
- 使用范围 for 循环（`for (const auto& item : container)`）
- 使用 `constexpr` 编译期计算
- 使用结构化绑定（`auto [key, value] = pair`）
- 使用 `std::string_view` 代替 `const std::string&`（避免不必要的分配）
- 使用 `std::span` 代替指针+长度
- 使用 `if constexpr` 编译期条件
- 使用 Concepts（C++20）约束模板参数
- 使用 `std::format`（C++20）代替 `printf`/`stringstream`
- 使用 Coroutines（C++20）处理异步操作

## 函数设计

- 函数参数不超过 4 个；复杂场景使用结构体或 Builder 模式
- 输入参数用 `const&`（`void process(const std::string& data)`）
- 输出参数用指针（`void get_result(Result* out)`），标记为 `gsl::not_null` 避免空指针
- 使用 `[[nodiscard]]` 标注返回值不应忽略的函数
- 使用 `noexcept` 标注不抛异常的函数
- 使用 `constexpr` 标注编译期可计算的函数
- 单一职责，函数体控制在 40 行以内
- 提前返回减少嵌套

## 类与面向对象

- 构造函数使用成员初始化列表（`: name_(name), age_(age)`）
- 五法则：如果定义了析构/拷贝构造/拷贝赋值/移动构造/移动赋值中的任何一个，定义全部五个
- 优先使用 `= default` 和 `= delete` 控制特殊成员函数
- 单参数构造函数标记 `explicit` 防止隐式转换
- 数据成员私有，通过公共方法访问
- 优先组合而非继承
- 虚析构函数用于多态基类
- 使用 `override` 和 `final` 标注虚函数覆盖
- 避免虚继承（除非必须的菱形继承）

## 模板与泛型

- 模板参数使用概念（Concepts）约束（C++20）或 SFINAE（C++17）
- 模板定义放在头文件中（或显式实例化）
- 使用别名模板简化复杂类型（`template<typename T> using Vec = std::vector<T, MyAlloc<T>>`）
- 避免过度模板化（增加编译时间和错误信息复杂度）
- 使用变参模板（variadic templates）代替可变参数宏

## 错误处理

- 使用异常处理错误（C++），不用返回码（除非性能关键路径）
- 异常用于异常情况，不用于正常控制流
- 使用 `assert` 检查开发期前置/后置条件
- 使用 `std::expected<T, E>`（C++23）或 `tl::expected` 处理可预期错误
- 禁止空 catch 块
- 自定义异常继承 `std::runtime_error` 或 `std::logic_error`
- 在调用边界统一捕获异常
- 使用 RAII 确保异常安全（basic/strong/nothrow guarantee）

## 并发编程

- 使用 `std::thread` + `std::jthread`（C++20，自动 join）
- 使用 `std::mutex` / `std::shared_mutex`（C++17）保护共享状态
- 使用 `std::lock_guard` / `std::unique_lock` / `std::scoped_lock` RAII 管理锁
- 使用 `std::atomic` 处理原子操作
- 使用 `std::condition_variable` 做线程间通知
- 使用 `std::future` / `std::promise` 获取异步结果
- 避免死锁：固定加锁顺序或使用 `std::scoped_lock` 同时加多锁
- 使用线程池而非每次创建线程
- 无锁数据结构需要严格的内存顺序分析

## 测试规范

- 框架：Google Test（gtest）/ Catch2 / doctest
- 测试文件：`<name>_test.cpp` 或 `test_<name>.cpp`
- 使用 `EXPECT_*` / `ASSERT_*` 断言
- 测试 fixture 用于共享初始化
- 覆盖率：gcov / lcov，新代码 ≥ 80%
- Mock 框架：Google Mock / Trompeloeil
- 性能基准：Google Benchmark

## 性能优化

- 优先使用编译器优化（`-O2` / `-O3`）
- 使用移动语义（`std::move`）避免不必要的拷贝
- 使用 `reserve()` 预分配容器容量
- 避免在热路径中动态内存分配（对象池、栈分配）
- 使用 `emplace_back` 代替 `push_back`（原地构造）
- 使用 `string_view` / `span` 避免字符串/容器拷贝
- 缓存友好的数据布局（SoA vs AoS，连续内存）
- 使用 `valgrind` / AddressSanitizer 检测内存问题

## 安全规范

- 禁止使用不安全的 C 函数（`strcpy`, `sprintf`, `gets` → `strncpy`, `snprintf`, `fgets`）
- 缓冲区操作必须检查边界
- 使用 `std::array` + `at()` 代替 C 数组（边界检查）
- 智能指针避免循环引用（`weak_ptr` 打破循环）
- 使用 `const` 尽可能多（变量、参数、方法）
- 使用 `static_assert` 编译期检查
- 禁止硬编码密钥/token
- 使用 AddressSanitizer / UndefinedBehaviorSanitizer 检测运行时问题
