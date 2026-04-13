---
paths:
  - "**/*.hs"
  - "**/*.lhs"
---

# Haskell 编码规范

> 综合 Haskell Style Guide / GHC Coding Standards / Haskell Best Practices

## 命名规范

- 模块：PascalCase（`UserService`, `Data.HashMap`）
- 类型和类型类：PascalCase（`User`, `Eq`, `MonadIO`）
- 函数和变量：camelCase（`getUserName`, `itemCount`）
- 类型变量：小写单字母（`a`, `b`, `m`）或简短描述（`key`, `elem`）
- 常量：camelCase（`maxRetryCount`）或 PascalCase（模块级）
- 记录字段：camelCase + 类型前缀（`userName`, `userAge`）
- 操作符：符号组合（`<$>`, `<*>`, `>>=`）
- 文件名：PascalCase（`UserService.hs`），与模块名匹配

## 代码格式

- 缩进：2 或 4 空格
- 使用 `ormolu` / `fourmolu` / `brittany` 自动格式化
- 使用 `hlint` 静态分析
- where 子句缩进
- 类型签名在函数定义上方
- 导入排序：标准库 → 第三方 → 本地模块

## 核心规范

- 始终为顶层函数添加类型签名
- 使用不可变数据（默认）
- 使用代数数据类型（ADT）建模
- 使用模式匹配处理分支
- 使用 Maybe / Either 处理可失败操作
- 优先使用纯函数，IO 集中在外层
- 使用 newtype 包装语义类型（`newtype UserId = UserId Int`）
- 使用 RecordWildCards 或 NamedFieldPuns 简化记录操作
- 使用 Applicative / Monad 组合操作
- 惰性求值注意空间泄漏（使用 `BangPatterns` / `strict` 字段）

## 错误处理

- 使用 `Maybe a` 处理可能无值的操作
- 使用 `Either e a` 处理带错误信息的失败
- 使用 `ExceptT` / `MonadError` 在 monad 栈中处理错误
- 使用 `unsafePerformIO` 仅在绝对必要时
- 不使用 `error` / `undefined`（仅开发期占位）

## 测试

- 框架：Hspec / HUnit / QuickCheck
- 属性测试使用 QuickCheck
- 测试文件：`test/<Module>Spec.hs`
