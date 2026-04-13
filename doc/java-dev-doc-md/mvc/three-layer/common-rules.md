# common 包开发规则

> 所属模式：三层 MVC
> 所属层：公共层
> 包路径：`com.company.project.common`

---

## 1. 创建规则

- 定义全局常量、枚举、工具方法时创建
- 子目录：`constant/`, `enums/`, `util/`

## 2. 文件命名规则

| 类型 | 命名 | 示例 |
|------|------|------|
| 常量类 | 功能名+Constants | `OrderConstants` |
| 枚举 | 业务名+Status/Type | `OrderStatus` |
| 工具类 | 功能名+Utils/Helper | `DateUtils` |

## 3. 代码质量规则

### 【强制】
- 常量类：`final class` + `private constructor`
- 工具类：`final class` + `private constructor` + static 方法
- 枚举：实现 `getCode()` / `getDesc()`

### 【禁止】
- 禁止业务逻辑
- 禁止依赖 Service/Mapper

## 4. 依赖规则

- 可引用：Java 标准库
- 禁止引用：`service.*`, `mapper.*`, `controller.*`

## 5. AI 生成检查项

- [ ] 常量类 final + private constructor
- [ ] 无业务逻辑
- [ ] 无框架依赖

## 6. 代码模板

```java
public final class OrderConstants {
    private OrderConstants() {}
    public static final int MAX_ITEMS = 100;
    public static final String STATUS_DRAFT = "DRAFT";
}

public enum OrderStatus {
    DRAFT("DRAFT", "草稿"),
    PLACED("PLACED", "已下单"),
    CANCELLED("CANCELLED", "已取消");

    private final String code;
    private final String desc;
    OrderStatus(String code, String desc) { this.code = code; this.desc = desc; }
    public String getCode() { return code; }
    public String getDesc() { return desc; }
}
```
