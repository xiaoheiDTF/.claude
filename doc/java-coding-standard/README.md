# 大厂 Java 编码规范

> 综合阿里巴巴、腾讯、Google 等权威编码规范
> 最后更新：2026-04-11

---

## 一、命名规范

| 场景 | 规则 | 正确示例 | 错误示例 |
|------|------|---------|---------|
| 包名 | 全小写，点分隔，单数形式 | `com.company.order` | `com.company.Order`, `com.company.orders` |
| 类名 | UpperCamelCase | `OrderService`, `UserDO` | `orderService`, `Order_Service` |
| 方法名 | lowerCamelCase，动词开头 | `createOrder`, `getUserById` | `CreateOrder`, `create_order` |
| 变量名 | lowerCamelCase | `orderList`, `userCount` | `OrderList`, `order_list` |
| 常量 | SCREAMING_SNAKE_CASE | `MAX_RETRY_COUNT` | `maxRetryCount` |
| 布尔变量 | is/has/can/should 前缀 | `isActive`, `hasPermission` | `active`, `permission` |
| 抽象类 | Abstract/Base 开头 | `AbstractOrder` | `OrderAbstract` |
| 异常类 | Exception 结尾 | `BusinessException` | `BusinessError` |
| 接口 | 无特殊前缀/后缀 | `OrderService` | `IOrderService` |
| 测试类 | 被测类名 + Test | `OrderServiceTest` | `TestOrderService` |
| 枚举类 | Enum 后缀，成员全大写 | `ProcessStatusEnum.SUCCESS` | `ProcessStatus.success` |
| 数组 | 类型与中括号紧挨 | `int[] arrayDemo` | `int arrayDemo[]` |

### 方法命名动词前缀

| 前缀 | 含义 | 示例 |
|------|------|------|
| get | 获取单个对象 | `getUserById` |
| list | 获取多个对象 | `listOrders` |
| count | 获取统计值 | `countActiveUsers` |
| save/insert | 新增 | `saveOrder` |
| delete/remove | 删除 | `deleteOrder` |
| update | 修改 | `updateOrderStatus` |
| create | 创建 | `createOrder` |
| is/has/can | 布尔判断 | `isValid`, `hasPermission` |

### 领域模型后缀

| 后缀 | 含义 | 示例 |
|------|------|------|
| DO | 数据对象 | `UserDO` |
| DTO | 数据传输对象 | `OrderDTO` |
| VO | 展示对象 | `UserVO` |
| BO | 业务对象 | `OrderBO` |
| AO | 应用对象 | `OrderAO` |

> 来源：[阿里巴巴 Java 开发手册（嵩山版）](https://developer.aliyun.com/article/1024437), [腾讯 Java 编码规范](https://cloud.tencent.com/developer/article/2215512)

---

## 二、代码格式

- 【强制】采用 4 个空格缩进，禁止使用 tab
- 【强制】左大括号前不换行，后换行；右大括号前换行
- 【强制】单行字符不超过 120 个
- 【强制】运算符左右各一个空格：`if (flag == 0)`
- 【强制】关键词与括号之间加空格：`if (a == b)`，括号内不加空格
- 【强制】注释双斜线与内容间仅一个空格：`// 注释内容`
- 【强制】方法参数逗号后加空格：`method("a", "b", "c")`
- 【强制】不允许一行多条语句
- 【强制】IDE 文件编码 UTF-8，换行符 Unix 格式（`\n`）
- 【推荐】不同逻辑间插入一个空行提升可读性，禁止多个空行

```java
public static void main(String[] args) {
    String say = "hello";
    int flag = 0;
    if (flag == 0) {
        System.out.println(say);
    }
    if (flag == 1) {
        System.out.println("world");
    } else {
        System.out.println("ok");
    }
}
```

---

## 三、OOP 规约

### 3.1 绝对禁止

- 【禁止】`catch` 块为空 — 至少记录日志
- 【禁止】用 `==` 比较包装类对象 — 必须用 `equals()`
- 【禁止】在 `for/foreach` 循环中直接 `remove` 集合元素
- 【禁止】用 `Executors.newXxx()` 创建线程池 — 使用 `ThreadPoolExecutor`
- 【禁止】魔法值 — 必须定义为常量或枚举
- 【禁止】方法参数超过 5 个 — 封装为对象
- 【禁止】返回 `null` 表示空集合 — 返回 `Collections.emptyList()`
- 【禁止】在业务代码中使用 `System.out.println`
- 【禁止】使用已废弃的类（`Vector`, `Hashtable`, `Stack`）

### 3.2 必须遵守

- 【强制】重写 `equals()` 必须同时重写 `hashCode()`
- 【强制】`switch` 语句必须有 `default`
- 【强制】所有 public 方法必须有 Javadoc（至少 `@param` + `@return`）
- 【强制】方法圈复杂度 ≤ 10
- 【强制】方法长度 ≤ 80 行
- 【强制】使用 `@Override` 注解标记重写方法
- 【强制】使用 try-with-resources 管理资源
- 【强制】所有 POJO 类属性使用包装类型
- 【强制】POJO 类必须写 `toString()` 方法
- 【强制】构造方法禁止包含业务逻辑，初始化放 `init()` 方法
- 【强制】类内方法顺序：公有 → 保护 → 私有 → getter/setter

```java
// 正确 — try-with-resources
try (InputStream is = new FileInputStream("data.txt")) {
    // 读取数据
}

// 错误 — 手动关闭
InputStream is = null;
try {
    is = new FileInputStream("data.txt");
} finally {
    if (is != null) is.close();
}
```

### 3.3 包装类 vs 基本类型

- 【强制】POJO 类属性必须使用包装类型
- 【强制】RPC 方法返回值和参数必须使用包装类型
- 【推荐】局部变量使用基本数据类型

```java
// 正确 — 包装类型可以表示 null（远程调用失败）
private Integer stockCount;

// 危险 — 基本类型默认值 0，无法区分"0"和"获取失败"
private int stockCount;
```

---

## 四、集合处理

- 【强制】`subList` 返回的是原列表视图，不可强转为 `ArrayList`
- 【强制】`Arrays.asList()` 返回的集合不可修改（add/remove 抛异常）
- 【强制】不要在 foreach 中 remove/add 元素，使用 Iterator
- 【强制】集合初始化时指定容量：`new HashMap<>(initialCapacity)`

```java
// 正确 — Iterator 方式删除
Iterator<String> iterator = list.iterator();
while (iterator.hasNext()) {
    String item = iterator.next();
    if (condition) {
        iterator.remove();
    }
}

// 错误 — foreach 中删除
for (String item : list) {
    if ("1".equals(item)) {
        list.remove(item);
    }
}
```

- 【推荐】使用 `entrySet` 遍历 Map KV，而非 `keySet`
- 【推荐】`HashMap` 初始容量 = (元素数 / 0.75) + 1

---

## 五、并发处理

### 5.1 线程池

- 【强制】线程必须通过线程池提供，禁止自行 `new Thread()`
- 【强制】线程池使用 `ThreadPoolExecutor` 创建，禁止 `Executors`

```java
// 正确
ThreadPoolExecutor executor = new ThreadPoolExecutor(
    corePoolSize, maximumPoolSize,
    keepAliveTime, TimeUnit.SECONDS,
    new LinkedBlockingQueue<>(queueCapacity),
    new ThreadFactoryBuilder().setNameFormat("order-pool-%d").build(),
    new ThreadPoolExecutor.CallerRunsPolicy()
);

// 错误 — 可能导致 OOM
ExecutorService pool = Executors.newFixedThreadPool(10);
```

### 5.2 日期处理

- 【强制】`SimpleDateFormat` 线程不安全，禁止定义为 static
- 【推荐】JDK8+ 使用 `DateTimeFormatter`（线程安全，不可变）

### 5.3 锁策略

- 【强制】加锁代码块工作量尽量小，锁内禁止调用 RPC
- 【强制】多资源加锁保持一致顺序，防止死锁
- 【推荐】冲突概率 < 20% 用乐观锁（version），否则用悲观锁
- 【强制】乐观锁重试次数 ≥ 3 次

### 5.4 其他

- 【强制】使用 `ScheduledExecutorService` 替代 `Timer`
- 【推荐】JDK8+ 使用 `LongAdder` 替代 `AtomicLong`
- 【参考】`ThreadLocal` 对象建议用 `static` 修饰

---

## 六、控制语句

- 【强制】`switch` 每个 case 要有 `break/return`，必须有 `default`
- 【强制】`if/else/for/while/do` 必须使用大括号
- 【强制】`if-else` 不超过 3 层，超过使用卫语句/策略模式/状态模式
- 【推荐】避免取反逻辑：`if (x < 628)` 优于 `if (!(x >= 628))`

```java
// 卫语句示例
public void today() {
    if (isBusy()) {
        System.out.println("change time.");
        return;
    }
    if (isFree()) {
        System.out.println("go to travel.");
        return;
    }
    System.out.println("stay at home.");
}
```

---

## 七、异常与日志

### 7.1 异常处理

- 【强制】不要用异常做流程控制
- 【强制】`catch` 分清异常类型，禁止大段 `try-catch`
- 【强制】捕获异常必须处理，禁止空 `catch` 块
- 【强制】`finally` 块必须关闭资源（或使用 try-with-resources）
- 【禁止】`finally` 块中使用 `return`
- 【推荐】使用自定义异常类（`BusinessException`, `ServiceException`）
- 【推荐】JDK8 使用 `Optional` 防止 NPE

```java
// 正确 — Optional 防 NPE
Optional.ofNullable(user).map(User::getAddress).map(Address::getCity).orElse("未知");

// 危险 — 级联调用易 NPE
user.getAddress().getCity();
```

### 7.2 日志规约

- 【强制】使用 SLF4J 门面，不直接使用 Log4j/Logback API
- 【强制】debug/info 级别日志使用占位符：`logger.debug("id: {}", id)`
- 【强制】异常日志包含案发现场 + 堆栈：`logger.error("params:" + params, e)`
- 【强制】日志文件至少保留 15 天
- 【推荐】生产环境禁止 debug 日志，有选择输出 info 日志

---

## 八、注释规约

- 【强制】类/接口必须有 Javadoc（`@author` + `@since` + 功能描述）
- 【强制】所有 public 方法必须有 Javadoc（`@param` + `@return` + `@throws`）
- 【强制】所有抽象方法必须注释，说明做什么、实现要求
- 【强制】方法内部单行注释用 `//`，多行用 `/* */`
- 【强制】枚举类型字段必须有注释
- 【推荐】与其用半吊子英文注释，不如用中文把问题说清楚
- 【推荐】代码修改时同步更新注释
- 【参考】谨慎注释掉代码，无用代码直接删除

```java
/**
 * 根据订单号查询订单详情
 *
 * @param orderNo 订单编号，不可为空
 * @return 订单详情，不存在时返回 null
 * @throws BusinessException 当订单编号格式不正确时抛出
 */
public OrderDTO getByOrderNo(String orderNo) { ... }
```

---

## 九、安全规约

- 【强制】隶属用户的页面/功能必须进行权限校验
- 【强制】敏感数据展示必须脱敏：`158****9119`
- 【强制】SQL 参数使用参数绑定，禁止字符串拼接 SQL
- 【强制】用户请求参数必须做有效性验证（防 page size 过大、恶意 order by、SQL 注入等）
- 【强制】禁止向 HTML 输出未经安全过滤的用户数据
- 【强制】表单/AJAX 提交必须执行 CSRF 过滤
- 【强制】短信/邮件/支付等资源必须实现防重放（数量限制 + 频率控制 + 验证码）
- 【推荐】用户生成内容必须实现防刷 + 违禁词过滤

> 来源：[阿里巴巴 Java 开发手册](https://developer.aliyun.com/article/1024437), [腾讯代码安全指南](https://www.w3cschool.cn/secguide/)

---

## 十、工程结构

### 版本号规范

- 【强制】版本号：主版本号.次版本号.修订号（如 `1.0.0`）
- 【强制】起始版本号为 `1.0.0`，不允许 `0.0.1`
- 【强制】线上应用不依赖 SNAPSHOT 版本

### Maven 依赖

- 【强制】`<dependencyManagement>` 声明版本，`<dependencies>` 引入依赖
- 【强制】子项目禁止相同 GAV 不同 Version
- 【推荐】GAV 遵循：`com.{公司}.功能模块.子功能`，最多 4 级

### 服务器

- 【推荐】高并发服务器调小 `time_wait` 超时：`net.ipv4.tcp_fin_timeout = 30`
- 【推荐】调大最大文件句柄数
- 【推荐】JVM 设置 `-XX:+HeapDumpOnOutOfMemoryError`
- 【推荐】生产环境 `Xms` 和 `Xmx` 设置相同大小

---

## 参考来源

| 来源 | 质量等级 | 链接 |
|------|---------|------|
| 阿里巴巴 Java 开发手册（嵩山版） | A | https://developer.aliyun.com/article/1024437 |
| 阿里 Java 开发手册（黄山版） | A | https://juejin.cn/post/7067448100796760078 |
| 腾讯 Java 编码规范 | A | https://cloud.tencent.com/developer/article/2215512 |
| 腾讯代码安全指南 | A | https://www.w3cschool.cn/secguide/ |
| Google Java Style Guide | A | https://google.github.io/styleguide/javaguide.html |
| 腾讯 Java 编程规范及最佳实践 | B | https://cloud.tencent.com/developer/article/2438274 |
