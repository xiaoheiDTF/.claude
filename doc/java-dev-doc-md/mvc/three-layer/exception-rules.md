# exception 包开发规则

> 所属模式：三层 MVC
> 所属层：异常层
> 包路径：`com.company.project.exception`

---

## 1. 创建规则

- 项目初始化时创建基类
- 按需创建具体业务异常

## 2. 文件命名规则

场景名+Exception，如 `BusinessException`, `OrderNotFoundException`。

## 3. 代码质量规则

- 【强制】继承 RuntimeException
- 【强制】包含错误码
- 【强制】有 GlobalExceptionHandler（`@ControllerAdvice`）

## 4. 依赖规则

- 可引用：Java 标准库
- 禁止引用：框架（纯 Java）

## 5. AI 生成检查项

- [ ] 继承 RuntimeException
- [ ] 有错误码
- [ ] 有全局异常处理器

## 6. 代码模板

```java
public class BusinessException extends RuntimeException {
    private final String code;
    public BusinessException(String code, String message) { super(message); this.code = code; }
    public String getCode() { return code; }
}

@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(BusinessException.class)
    public Result<Void> handleBusiness(BusinessException e) {
        return Result.fail(e.getCode(), e.getMessage());
    }
}
```
