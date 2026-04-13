# domain/exception 包开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属层：领域层
> 所属模块：project-domain
> 包路径：`com.company.project.domain.exception`

---

## 1. 创建规则

### 什么时候创建
- 领域层需要抛出业务异常时
- 区分不同类型的业务错误时

### 创建什么
- 领域异常基类 + 具体业务异常类

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 基类 | AggregateException / DomainException | `AggregateException` |
| 业务异常 | 场景名+Exception | `OrderNotFoundException`, `InsufficientStockException` |

---

## 3. 代码质量规则

### 【强制】
- 继承 RuntimeException（非受检异常）
- 包含错误码（String 或 Enum）
- 包含错误描述
- 保留原始异常链

### 【禁止】
- 禁止继承 Exception（受检异常）
- 禁止框架注解
- 禁止依赖 Spring 的异常体系

### 【推荐】
- 定义统一的错误码常量或枚举
- 异常消息面向开发者，不含敏感数据

---

## 4. 依赖规则

### 可引用
- Java 标准库

### 禁止引用
- `infrastructure.*`
- Spring 框架
- 任何技术框架

---

## 5. AI 生成检查项

- [ ] 继承 RuntimeException
- [ ] 包含错误码
- [ ] 有 message 和 cause 构造器
- [ ] 无框架依赖

---

## 6. 代码模板

```java
package com.company.project.domain.exception;

/**
 * 聚合根操作异常
 */
public class AggregateException extends RuntimeException {

    private final String code;

    public AggregateException(String message) {
        super(message);
        this.code = "AGGREGATE_ERROR";
    }

    public AggregateException(String code, String message) {
        super(message);
        this.code = code;
    }

    public AggregateException(String code, String message, Throwable cause) {
        super(message, cause);
        this.code = code;
    }

    public String getCode() { return code; }
}

/**
 * 仓储操作异常
 */
public class RepositoryException extends RuntimeException {

    public RepositoryException(String message, Throwable cause) {
        super(message, cause);
    }
}
```
