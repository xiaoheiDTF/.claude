---
paths:
  - "**/*.dart"
---

# Dart 编码规范

> 综合 Effective Dart / Dart Style Guide / Flutter Best Practices / Dart Linter Rules

## 命名规范

- 类、枚举、扩展、类型别名、注解：PascalCase（`UserService`, `HttpRequest`）
- 库、包、目录、源文件：snake_case（`user_service.dart`）
- 函数、方法、变量、参数：camelCase（`getUserInfo`, `userName`）
- 常量：camelCase（`maxRetryCount`）；编译期常量可用 PascalCase
- 私有成员：`_` 前缀（`_internalState`, `_calculateTotal`）
- 布尔变量以 is/has/can/should 开头（`isValid`, `hasPermission`）
- 测试文件：`<name>_test.dart`（`user_service_test.dart`）
- 导入使用 package 路径（`import 'package:my_app/services/user_service.dart'`）

## 代码格式

- 使用 `dart format` 自动格式化（官方格式化器）
- 缩进：2 空格
- 行宽：80 字符（`dart format` 默认）
- 左花括号不换行
- 使用 `dart analyze` 静态分析
- `analysis_options.yaml` 配置 lint 规则

## 类型系统

- 启用空安全（Sound Null Safety）
- 使用 `?` 标注可空类型（`String?`）
- 使用 `null` 检查、`?.`、`??`、`!` 操作符处理可空值
- 公共 API 添加类型注解（`String getUserInfo(int id)`）
- 局部变量可用 `var` 当类型明显时
- 使用 `dynamic` 仅在必要时（优先 `Object?`）
- 使用泛型（`List<T>`, `Map<K, V>`）
- 使用 `sealed class`（Dart 3+）定义封闭层次
- 使用 `Record`（Dart 3+）定义轻量元组（`(String, int)`）
- 使用 `Pattern` 匹配（Dart 3+）

## 类与面向对象

- 使用 `class` 定义有行为的对象
- 使用具名构造函数（`User.fromJson(Map json)`）
- 使用工厂构造函数（`factory User.create(...)`）
- 使用 `const` 构造函数优化不可变对象
- 使用 `abstract class` 定义接口/抽象类
- 使用 `mixin` 共享行为（不限于单继承）
- 使用 `extension` 扩展已有类型
- 使用 `enum` 定义有限枚举（Dart 2.17+ 增强枚举）
- 组合优于继承
- 实现 `toString()`、`hashCode`、`==`

## 异步编程

- 使用 `async/await` + `Future<T>` 处理异步
- 使用 `Stream<T>` 处理数据流
- 使用 `async*` 生成器（`Stream<T>` 返回值）
- 使用 `sync*` 生成器（`Iterable<T>` 返回值）
- 使用 `Completer<T>` 包装回调为 Future
- 使用 `Future.wait` 并行执行
- 使用 `Isolate` 处理 CPU 密集任务（避免阻塞主线程）
- 错误处理：`try/catch` + `on SpecificException`

## Flutter 特定（如适用）

- Widget 是不可变对象
- 状态管理：Provider / Riverpod / Bloc / GetX（项目统一）
- 使用 `const` Widget 减少重建
- 提取 Widget 保持 build 方法简洁
- 使用 `ThemeData` 统一主题
- 使用 `Sliver` 处理复杂滚动
- 资源管理使用 `pubspec.yaml`

## 测试规范

- 框架：`test` 包（单元）/ `flutter_test`（Widget）
- 测试文件：`<name>_test.dart`
- 使用 `test('description', () { ... })` / `group('category', () { ... })`
- Mock 使用 `mockito` / `mocktail`
- 覆盖率：`flutter test --coverage`，新代码 ≥ 80%
- Widget 测试使用 `testWidgets`
- 集成测试使用 `integration_test`

## 性能优化

- 使用 `const` 构造函数减少对象创建
- 使用 `ListView.builder` 惰性加载长列表
- 避免在 build 方法中创建对象（提取为字段）
- 使用 `Isolate` 处理 CPU 密集计算
- 图片缓存和懒加载
- 使用 `DevTools` 分析性能

## 安全规范

- 禁止硬编码密钥/token
- 使用 `flutter_secure_storage` 存储敏感数据
- HTTPS 传输敏感数据
- 输入验证
- 依赖审计：`dart pub audit` / `flutter pub audit`

## 魔法变量治理

### 三级判定

| 级别 | 条件 | 做法 |
|------|------|------|
| ① inline | 只在 1~2 处使用，不跨模块 | 直接写在代码中 |
| ② 常量文件 | 跨 3+ 模块使用，或容易拼错 | `const upperSnakeCase = 'value';` 在 `constants.dart` 中 |
| ③ 类型约束 | 天然属于类型定义 | `enum` + extension 方法 |

**配置数值** → `--dart-define` 编译参数 或 `.env` + `flutter_dotenv`。

### 替换原则

- **纯机械替换**：只改字面量为常量引用，不改变运行时行为
- **值完全一致**：常量值必须与原硬编码完全一致

### 实现顺序

定义常量文件（底层零依赖）→ 替换消费代码 → 同步文档
