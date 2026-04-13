---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript 编码规范

> 综合 Google TypeScript Style Guide / Airbnb TypeScript / Microsoft TypeScript Best Practices / Clean Code TypeScript

## 命名规范

- 变量和函数：camelCase（`getUserInfo`, `isActive`）
- 类、接口、类型别名、枚举、装饰器：PascalCase（`UserService`, `UserRole`）
- 常量：UPPER_SNAKE_CASE（`MAX_RETRY_COUNT`, `API_BASE_URL`）
- 文件名：kebab-case（`user-service.ts`, `auth-middleware.ts`）；测试文件：`<name>.test.ts`
- 布尔变量/属性以 is/has/should/can/will 开头（`isValid`, `hasPermission`）
- 接口不加 I 前缀（`User` 而非 `IUser`）；如需区分实现，用 `IUser` 接口 + `User` 类
- 私有成员不加下划线前缀，使用 `private` 关键字（`private name` 而非 `_name`）
- 枚举值使用 PascalCase（`enum Direction { Up, Down }`）
- 事件处理函数以 on/handle 开头（`onClick`, `handleSubmit`）
- 工具函数以动词开头（`formatDate`, `parseToken`, `validateEmail`）
- 命名应表达意图而非实现：`getUserAge()` 而非 `calcFromBirthday()`

## 类型系统

- 禁止使用 `any`，必须提供明确类型；无法确定时使用 `unknown` 并做类型收窄
- 优先使用 `interface` 定义对象结构（可声明合并），`type` 用于联合/交叉/映射类型
- 启用 `strict: true`（含 strictNullChecks, noImplicitAny, strictFunctionTypes）
- 使用字面量类型收窄范围（`type Status = 'active' | 'inactive'`）
- 优先使用 `as const` 断言代替显式类型声明字面量数组/对象
- 泛型参数使用有意义的名称（`TResponse`, `TEntity` 而非 `T`, `U`，简单场景除外）
- 避免类型断言（`as`），优先使用类型守卫（`typeof`, `instanceof`, `in`）
- 使用 `Readonly<T>` / `ReadonlyArray<T>` 保护不可变数据
- 使用 `Record<K, V>` 代替 `{ [key: string]: V }`
- 使用 `Partial<T>`, `Required<T>`, `Pick<T, K>`, `Omit<T, K>` 等工具类型
- 函数返回值：公共 API 必须显式标注返回类型
- 避免枚举的数字值隐式赋值，使用字符串枚举或 `as const` 对象

## 函数与方法

- 函数参数不超过 3 个；超过时使用 options 对象（`function createUser(opts: CreateUserOptions)`）
- 单一职责：一个函数只做一件事，不超过 30 行（不含空行和注释）
- 纯函数优先：避免副作用，相同输入必须产生相同输出
- 提前返回（early return）减少嵌套层级
- 使用默认参数代替条件赋值（`function fn(timeout = 5000)` 而非 `timeout = timeout || 5000`）
- 回调函数优先使用箭头函数保持 `this` 上下文
- 使用函数重载提供精确的类型提示，而非联合类型参数
- 避免在循环中创建函数（提前提取到外部）

## 异步编程

- 使用 `async/await` 代替 `.then()`/`.catch()` 链式调用
- 始终处理 Promise 的 rejection（用 try/catch 或 `.catch()`）
- 禁止悬浮 Promise（floating promises）：所有 Promise 必须被 await、return 或 .catch()
- 并行独立请求使用 `Promise.all()`；有竞态条件用 `Promise.race()`
- 避免在循环中使用 `await`（改用 `Promise.all` + `map`）
- 使用 `AbortController` 取消长时间运行的异步操作
- 资源释放使用 `using` 关键字（ES2025）或 try/finally 确保清理

## 模块与导入

- 使用 ES Module（`import/export`），不使用 CommonJS（`require/module.exports`）
- 导入顺序：Node 内置 → 外部包 → 内部模块 → 类型导入，每组之间空行分隔
- 类型导入使用 `import type { ... }` 语法（不产生运行时代码）
- 禁止通配符导入（`import * as _`）
- 使用具名导出，避免默认导出（利于重构和 IDE 支持）
- 导入路径使用相对路径时不超过两级（`../../` 为上限）
- re-export 使用 `export { x } from './module'` 简写
- 每个文件一个模块，文件名即模块名

## 类与面向对象

- 优先使用组合而非继承
- 类应该小而精：单一职责，公共方法不超过 10 个
- 属性尽量 `readonly`，构造函数中使用参数属性简写（`constructor(public name: string)`）
- 使用 `interface` 定义契约，类实现接口（`class UserService implements IUserService`）
- 工厂方法优于复杂构造函数
- 避免在构造函数中做异步操作，改用静态工厂方法 + 私有构造函数
- 模拟多态用联合类型 + 判别属性，而非类继承层次

## 错误处理

- 不允许空 catch 块；至少添加注释说明为什么忽略错误
- 抛出自定义错误类（`class AppError extends Error`），携带错误码和上下文
- 在调用边界（API handler、事件处理）统一捕获错误，不要在内部层层 try/catch
- 使用 Result 模式处理可预期的错误（`type Result<T, E> = { ok: true; value: T } | { ok: false; error: E }`）
- 错误信息应包含足够上下文以便调试（函数名、参数、状态）
- 不要用异常控制正常流程，异常只用于异常情况

## 测试规范

- 测试框架推荐：Vitest（单元）、Playwright（E2E）
- 测试文件放在源文件同目录：`user.ts` → `user.test.ts`
- describe 命名用被测模块名，it 描述期望行为（`it('should return user when id is valid')`）
- 测试结构：Arrange-Act-Assert（AAA）模式
- 覆盖率：新代码 ≥ 80%，核心业务逻辑 ≥ 95%
- Mock 外部依赖，不 mock 被测模块的内部函数
- 每个测试独立，不依赖执行顺序，不共享可变状态
- 测试边界条件：null、undefined、空数组、极大/极小值、并发场景

## 性能优化

- 避免在热路径上创建不必要的对象/数组分配
- 大列表渲染使用虚拟化（virtualization）
- 使用 Web Worker 处理 CPU 密集型计算
- 惰性求值：使用 generator（`function*`）处理大数据集
- 使用 `WeakMap`/`WeakSet` 存储对象引用，避免内存泄漏
- 图片/资源懒加载，使用 Intersection Observer
- 合理使用缓存（memoization），但注意内存使用

## 安全规范

- 禁止使用 `eval()`、`Function()` 构造器、`innerHTML`（XSS 风险）
- 所有外部输入必须验证和清理（sanitize）
- 禁止硬编码密钥、密码、token，使用环境变量
- 使用 `nonce` 或 `CSP` 防止 XSS 攻击
- API 请求携带 CSRF token
- 敏感数据传输必须 HTTPS，禁止在 URL 中传递敏感参数
- 使用 `Object.freeze()` 保护关键配置对象
- 第三方依赖定期审计（`npm audit`）
