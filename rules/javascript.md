---
paths:
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.mjs"
  - "**/*.cjs"
---

# JavaScript 编码规范

> 综合 Airbnb JavaScript Style Guide / Google JavaScript Style Guide / MDN Best Practices / Clean Code JavaScript

## 命名规范

- 变量和函数：camelCase（`getUserInfo`, `isActive`）
- 类和构造函数：PascalCase（`UserService`, `EventEmitter`）
- 常量：UPPER_SNAKE_CASE（`MAX_CONNECTIONS`, `DEFAULT_TIMEOUT`）
- 文件名：kebab-case（`user-service.js`）；测试文件：`<name>.test.js`
- 布尔变量以 is/has/should/can 开头（`isVisible`, `hasChildren`）
- 私有属性使用 `#` 前缀（ES2022 私有字段，`#privateField`）
- 事件回调以 on/handle 开头（`onClick`, `handleChange`）
- 命名表达意图而非实现细节（`filterActiveUsers` 而非 `processArray`）

## 变量与作用域

- 优先使用 `const`，仅在需要重新赋值时使用 `let`，禁止使用 `var`
- 变量声明在使用处附近，避免跨度过大的依赖
- 避免在块级作用域外声明变量然后在内部分配
- 解构赋值提取需要的属性（`const { name, email } = user`）
- 使用默认值处理可能的 undefined（`const port = config.port ?? 3000`）
- 避免链式声明（`const a = 1, b = 2`）
- 不使用未声明的变量（严格模式 `'use strict'`）

## 函数

- 使用函数声明或箭头函数，避免 `new Function()`
- 参数不超过 3 个；超过时使用 options 对象解构（`function create({ name, age, email })`）
- 箭头函数作为回调和匿名函数，函数声明用于命名导出的顶层函数
- 单一职责，函数体控制在 30 行以内
- 提前返回减少嵌套（early return）
- 默认参数放在参数列表末尾
- 使用 rest 参数（`...args`）代替 `arguments` 对象
- 避免在循环中创建闭包（使用 `let` 或提取函数）
- 纯函数优先，副作用集中在边界层

## 字符串与模板

- 使用模板字面量（`` `Hello ${name}` ``）代替字符串拼接
- 字符串使用单引号 `'` 或模板字面量，保持项目内一致
- 使用 `includes()` / `startsWith()` / `endsWith()` 代替 `indexOf()`
- 多行字符串使用模板字面量
- 避免不必要的字符串转换（`String(x)` 仅在必要时使用）

## 数组与对象

- 使用展开运算符（`...`）复制数组和对象（`[...arr]`, `{...obj}`）
- 使用 `Array.from()` 或展开运算符转换类数组对象
- 优先使用数组方法（`map/filter/reduce/find/some/every`）代替 for 循环
- 使用 `Object.entries()` / `Object.keys()` / `Object.values()` 遍历对象
- 使用可选链（`?.`）和空值合并（`??`）安全访问深层属性
- 避免修改函数参数（不突变输入）
- 使用 `Object.assign()` 或展开运算符做浅拷贝，深拷贝用 `structuredClone()`
- Map 用于键值对集合（键非字符串时），Set 用于去重

## 异步编程

- 使用 `async/await` 代替回调链和 `.then()`
- 始终处理错误：`try/catch` 包裹 await 或 `.catch()` 处理 rejection
- 并行操作使用 `Promise.all()`，首个完成用 `Promise.race()`，全部结算用 `Promise.allSettled()`
- 避免顺序 await 独立操作（并行化提升性能）
- 使用 `AbortController` 取消 fetch 和其他异步操作
- 不要在循环中逐个 await（用 `Promise.all(arr.map(...))`）
- 顶层 await 仅在 ES Module 中使用

## 模块化

- 使用 ES Module（`import/export`），不使用 CommonJS（`require`）
- 导入顺序：内置模块 → npm 包 → 本地模块，分组空行分隔
- 禁止通配符导入（`import *`）
- 优先具名导出，谨慎使用默认导出
- 循环依赖视为架构问题，必须重构
- 每个文件一个职责，文件名反映内容

## 类

- 使用 `class` 语法，不使用构造函数 + 原型链
- 构造函数只做初始化，不做复杂逻辑和异步操作
- 使用 getter/setter 控制属性访问
- 私有字段用 `#` 前缀（`#data`），不用下划线约定
- `static` 方法用于工厂方法和工具函数
- 优先组合而非继承（has-a 优于 is-a）

## 错误处理

- 不允许空 catch 块
- 抛出 Error 对象（`throw new Error('message')`），不抛原始值
- 在边界层统一捕获（API handler、事件监听器）
- 自定义错误类继承 Error（`class ValidationError extends Error`）
- 使用 `error instanceof` 判断错误类型
- 错误信息包含上下文（操作名、参数值、状态）

## 测试规范

- 框架推荐：Vitest / Jest（单元）、Playwright（E2E）
- 测试文件：`<name>.test.js`，放在源文件旁
- describe 描述模块，it 描述行为（`it('should filter inactive users')`）
- AAA 模式：Arrange → Act → Assert
- 覆盖率：新代码 ≥ 80%
- Mock 外部依赖，不 mock 内部逻辑
- 测试独立、可重复、无共享可变状态

## 性能

- 大数组处理用 `for...of` 或 `for` 循环（比 `forEach` 快）
- 避免频繁 DOM 操作（批量更新、DocumentFragment）
- 使用 `requestAnimationFrame` 做视觉更新
- 防抖（debounce）高频事件（输入、滚动），节流（throttle）持续事件
- 内存管理：及时解绑事件监听器、清除定时器、释放大对象引用
- 使用 Web Worker 处理 CPU 密集任务

## 安全

- 禁止 `eval()`、`Function()`、`innerHTML`
- 输入验证和输出编码（防 XSS）
- 使用 `textContent` 代替 `innerHTML`
- 禁止硬编码密钥/token，使用环境变量
- 第三方依赖定期审计
- 使用 CSP（Content Security Policy）头
