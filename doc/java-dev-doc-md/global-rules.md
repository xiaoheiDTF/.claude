# Java 开发全局规则

> AI 生成 Java 代码时必须遵守的铁律，适用于所有架构模式（DDD / MVC）
> 最后更新：2026-04-11

---

## 一、命名铁律

| 场景 | 规则 | 正确示例 | 错误示例 |
|------|------|---------|---------|
| 包名 | 全小写，点分隔 | `com.company.order` | `com.company.Order` |
| 类名 | 大驼峰 UpperCamelCase | `OrderService` | `orderService`, `Order_Service` |
| 方法名 | 小驼峰 lowerCamelCase | `createOrder` | `CreateOrder`, `create_order` |
| 变量名 | 小驼峰 lowerCamelCase | `orderList` | `OrderList`, `order_list` |
| 常量 | 全大写下划线 | `MAX_RETRY_COUNT` | `maxRetryCount` |
| 布尔变量 | is/has/can/should 前缀 | `isActive`, `hasPermission` | `active`, `permission` |
| 抽象类 | Abstract/Base 开头 | `AbstractOrder` | `OrderAbstract` |
| 异常类 | Exception 结尾 | `BusinessException` | `BusinessError` |
| 接口 | 无特殊前缀/后缀 | `OrderService` | `IOrderService` |
| 测试类 | 被测类名+Test | `OrderServiceTest` | `TestOrderService` |

---

## 二、编码铁律（AI 必须遵守）

### 2.1 绝对禁止

- 【禁止】`catch` 块为空 — 至少记录日志
- 【禁止】用 `==` 比较包装类对象（`Integer`, `Long` 等）— 必须用 `equals()`
- 【禁止】在 `for/foreach` 循环中直接 `remove` 集合元素 — 使用 `Iterator`
- 【禁止】用 `Executors.newXxx()` 创建线程池 — 使用 `ThreadPoolExecutor`
- 【禁止】魔法值 — 必须定义为常量或枚举
- 【禁止】方法参数超过 5 个 — 封装为对象
- 【禁止】返回 `null` 表示空集合 — 返回 `Collections.emptyList()`
- 【禁止】在业务代码中使用 `System.out.println` — 使用日志框架
- 【禁止】`catch (Exception e)` 吞掉异常不做任何处理
- 【禁止】使用已废弃的类（`Vector`, `Hashtable`, `Stack`）
- 【禁止】在 POJO 类中使用基本类型 — 使用包装类（`Integer` 非 `int`）

### 2.2 必须遵守

- 【强制】重写 `equals()` 必须同时重写 `hashCode()`
- 【强制】`switch` 语句必须有 `default`
- 【强制】所有 public 方法必须有 Javadoc（至少 `@param` + `@return`）
- 【强制】方法圈复杂度 ≤ 10
- 【强制】方法长度 ≤ 80 行
- 【强制】使用 `@Override` 注解标记重写方法
- 【强制】使用 try-with-resources 管理资源（流、连接）
- 【强制】JSON 序列化字段使用驼峰命名
- 【强制】日期时间使用 `java.time` 包（`LocalDateTime` 等），禁止 `java.util.Date`
- 【强制】日志使用 SLF4J + Logback，不直接使用 Log4j / JUL
- 【强制】常量类用 `final class` + `private constructor`

### 2.3 推荐做法

- 【推荐】使用 `Optional` 代替 null 返回值
- 【推荐】使用 Stream API 代替 for 循环（当逻辑简单时）
- 【推荐】使用 `@Nullable` / `@NonNull` 注解标注方法签名
- 【推荐】使用 Builder 模式创建复杂对象
- 【推荐】集合初始化时指定容量（`new ArrayList<>(expectedSize)`）
- 【推荐】字符串拼接使用 `StringBuilder`（大量时）或 `String.format()`（少量时）

---

## 三、异常处理铁律

```java
// 全局异常处理器（每个项目必须有）
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public Result<Void> handleBusiness(BusinessException e) {
        log.warn("业务异常: code={}, msg={}", e.getCode(), e.getMessage());
        return Result.fail(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(Exception.class)
    public Result<Void> handleException(Exception e) {
        log.error("系统异常", e);
        return Result.fail("SYSTEM_ERROR", "系统繁忙，请稍后重试");
    }
}
```

- 【强制】Controller 层不使用 try-catch，由全局异常处理器统一处理
- 【强制】Service 层抛出 `BusinessException`（或自定义异常）
- 【强制】异常分类：业务异常（用户可理解）vs 系统异常（需要告警）
- 【强制】异常信息不含敏感数据（密码、Token、SQL）
- 【推荐】使用统一错误码体系（如 `ORDER_NOT_FOUND`）

---

## 四、日志铁律

```java
// 正确用法
log.debug("Processing order: {}", orderId);
log.warn("Order not found: id={}", orderId);
log.error("Failed to create order for user: {}", userId, exception);

// 禁止用法
log.debug("Processing order: " + orderId);  // 禁止字符串拼接
log.error("Error: " + e.getMessage());       // 禁止丢失堆栈
System.out.println("debug info");             // 禁止 sout
```

- 【强制】使用 `{}` 占位符，不使用字符串拼接
- 【强制】ERROR 级别必须传入异常对象（保留堆栈）
- 【强制】日志中不打印敏感信息（密码、身份证、Token）
- 【推荐】方法入口打 DEBUG 日志，关键业务节点打 INFO 日志

---

## 五、API 设计铁律

- 【强制】统一响应格式

```java
public class Result<T> {
    private String code;
    private String message;
    private T data;

    public static <T> Result<T> success(T data) { ... }
    public static <T> Result<T> fail(String code, String message) { ... }
}
```

- 【强制】RESTful URL 设计
  - 资源用名词复数：`/orders`, `/users`
  - 动作用 HTTP Method：GET 查询、POST 新增、PUT 修改、DELETE 删除
  - 禁止 URL 中出现动词：`/createOrder` → `POST /orders`

- 【强制】参数校验使用 Bean Validation

```java
public class CreateOrderRequest {
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    @NotEmpty(message = "商品列表不能为空")
    private List<OrderItemDTO> items;
}
```

---

## 六、通用依赖规则

### 6.1 分层依赖铁律（适用于所有模式）

```
上层 → 下层（可以调用）
下层 → 上层（绝对禁止）
```

- 【强制】Controller 不直接操作数据库
- 【强制】Service 不依赖 HttpServletRequest/Response
- 【强制】DAO/Mapper 不包含业务逻辑
- 【强制】所有层通过接口解耦

### 6.2 跨层对象转换铁律

| 层 | 接收 | 返回 |
|----|------|------|
| Controller | Request/Query | VO |
| Service | Request/Query/DTO | DTO |
| DAO/Mapper | DO/PO | DO/PO |

- 【强制】DO/PO 不越过 Service 层向上传递
- 【推荐】使用 MapStruct 做对象转换

---

## 七、AI 生成自查清单

每次生成 Java 代码后，AI 必须逐项检查：

- [ ] 类名、方法名、变量名是否符合命名铁律
- [ ] 是否有空的 catch 块
- [ ] 是否有魔法值（硬编码数字/字符串）
- [ ] 方法长度是否超过 80 行
- [ ] 方法参数是否超过 5 个
- [ ] 是否使用了 `System.out.println`
- [ ] 日期时间是否使用了 `java.time`
- [ ] 资源（流、连接）是否用 try-with-resources
- [ ] 集合返回是否为空集合而非 null
- [ ] 异常处理是否通过全局处理器
- [ ] public 方法是否有 Javadoc
- [ ] 分层依赖是否正确（无反向依赖）
- [ ] DTO/VO/DO 转换是否正确
