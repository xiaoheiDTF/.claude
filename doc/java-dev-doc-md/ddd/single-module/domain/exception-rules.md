# domain/exception 包开发规则

> 所属模式：单模块 DDD（简化模式）
> 所属层：领域层
> 包路径：`com.company.project.domain.exception`

---

## 1-5. 核心规则

与多模块 exception-rules.md 一致：
- 继承 RuntimeException、包含错误码
- 禁止引用框架

## 6. 代码模板

```java
package com.company.project.domain.exception;

public class AggregateException extends RuntimeException {
    private final String code;
    public AggregateException(String message) { super(message); this.code = "AGGREGATE_ERROR"; }
    public AggregateException(String code, String message) { super(message); this.code = code; }
    public String getCode() { return code; }
}

public class RepositoryException extends RuntimeException {
    public RepositoryException(String message, Throwable cause) { super(message, cause); }
}
```
