---
paths:
  - "**/*.java"
---

# saas-lvtu 项目特定编码规范

> 本规范为 saas-lvtu 项目（AI 旅行规划系统）的补充规则，与通用 Java 规范配合使用。

## 一、整体架构与技术栈

| 维度 | 技术选型 |
|------|----------|
| 基础框架 | Spring Boot + Spring Cloud (Nacos 服务发现与配置) |
| 父 POM | `com.umtone:uw-base` (内部基础框架) |
| 核心依赖 | `uw-ai`, `uw-common`, `uw-common-app`, `uw-cache`, `uw-log-es` |
| API 文档 | SpringDoc OpenAPI (Swagger 3) |
| 算法引擎 | Google OR-Tools |
| 外部服务 | 高德地图 REST API |

---

## 二、命名规范

| 类型 | 规则 | 示例 |
|------|------|------|
| 包名 | 全小写，反向域名 | `saas.lvtu.service.amap.vo` |
| 类名 | 大驼峰 (UpperCamelCase) | `TravelPlanService`, `PlanResponseLite` |
| 方法/变量 | 小驼峰 (lowerCamelCase) | `parseUserInput`, `travelDays` |
| 常量 | 全大写下划线 | `INPUT_SYSTEM_PROMPT` |
| 布尔/状态 | 避免 `is` 前缀在变量名中 | `status` 而非 `isSuccess` |

> 注意：字段名首字母必须小写（如 `visitDuration`，禁止 `VisitDuration`）。

## 三、代码格式特征

- **空格风格**：方法调用时参数列表内保留空格
  ```java
  // 项目中的标准写法
  TravelPlanService.parseUserInput( configId, userInput );
  new JsonInterfaceHelper( HttpConfig.builder().build() );
  ```
- **缩进**：4 空格 (标准 Java 缩进)
- **花括号**：K&R 风格，左括号不换行
- **导入顺序**：`java.*` 在下，第三方包在上，内部 `uw.*` 和 `saas.*` 混排

## 四、注释规范

- **强制使用 Javadoc**：所有公开类、方法、字段都必须有**中文 Javadoc**
- **注释内容**：说明"是什么" + "业务含义"
- **参数/返回值**：参数用 `@param`，返回值用 `@return`
- **类注释**：通常包含类的职责描述

```java
/**
 * 旅行服务类，负责生成和管理旅行计划
 * 协调各个代理组件完成旅行计划的生成
 */
```

## 五、API 文档规范

所有对外暴露的 VO 和 Controller 都必须标注 Swagger 注解：

```java
@Schema(title = "旅行请求", description = "旅行请求类，包含用户的旅行需求和偏好信息")
public class PlanRequest { ... }

@Schema(title = "出发地", description = "出发地", requiredMode = Schema.RequiredMode.REQUIRED)
private String origin;
```

Controller 必须标注：

```java
@RestController
@RequestMapping("/lvtu")
@Tag(name = "Travel Planning API", description = "APIs for generating AI-powered travel plans")
public class TravelController { ... }
```

---

## 六、不同模块的规则

### 6.1 `config` —— 配置模块

| 规则项 | 说明 |
|--------|------|
| 注解组合 | `@Configuration` + `@EnableConfigurationProperties` |
| 配置类命名 | `XxxAutoConfiguration`, `XxxProperties` |
| Properties 前缀 | `saas.lvtu` |
| Bean 定义 | 通过 `@Bean` 方法注入，依赖 `Properties` 对象 |
| Profile 控制 | Swagger 仅在 `debug`/`dev` 环境生效 (`@Profile`) |

```java
@EnableConfigurationProperties({LvtuProperties.class})
@Configuration
public class LvtuAutoConfiguration implements WebMvcConfigurer { ... }
```

### 6.2 `controller` —— 控制层

| 规则项 | 说明 |
|--------|------|
| 目录分层 | 按权限/角色分包：`open/`, `admin/`, `saas/`, `mch/`, `guest/`, `rpc/` |
| 统一返回 | 必须使用 `uw.common.dto.ResponseData<T>` |
| 日志 | 每个 Controller 定义 `private static final Logger logger` |
| 请求映射 | 使用 `@GetMapping`, 参数直接平铺于方法签名 |
| Swagger | 类加 `@Tag`, 方法可省略（简单接口）|

```java
@GetMapping("/planLite")
public ResponseData<PlanResponseLite> plan(long configId, String userInput) {
    logger.info( "开始做旅行规划。" );
    // ...
}
```

### 6.3 `service` —— 业务逻辑层

| 规则项 | 说明 |
|--------|------|
| 工具类服务 | `TravelPlanService` 全静态方法设计，无状态 |
| 客户端封装 | `AmapClient` 为实例类，通过构造器注入配置 |
| 算法服务 | `ORToolsPlanner` 封装第三方算法库，接收领域对象执行计算 |
| 日志 | 使用 `slf4j` 的 `LoggerFactory` |

**业务 Service 的典型写法**：

```java
public static ResponseData<PlanRequest> parseUserInput(long configId, String userInput) {
    // 1. 调用 AI 助手生成实体
    // 2. 参数校验 (SchemaValidateHelper)
    // 3. 返回 ResponseData
}
```

### 6.4 `vo` —— 领域值对象

| 规则项 | 说明 |
|--------|------|
| 位置 | `saas.lvtu.vo` 包下，与业务直接相关 |
| 设计模式 | **Builder 模式**（可选）+ 标准 `getter/setter` |
| 字段注解 | `@Schema` 必须，`@JsonFormat` 用于时间格式化 |
| 嵌套类 | 使用 `public static class` 嵌套定义子结构（如 `DayPlan`, `TripPoiInfo`）|
| 枚举定义 | 直接在 VO 类内部定义（如 `PlanRequest.BudgetLevel`）|

```java
public class PlanRequest {
    private String origin;
    // ... getter/setter + Builder
    
    public enum BudgetLevel { ECONOMY, COMFORT, PREMIUM, LUXURY }
}
```

### 6.5 `service.amap.vo` —— 第三方 API 的 VO

| 规则项 | 说明 |
|--------|------|
| 继承关系 | Request 继承 `AmapBaseRequest`，Response 继承 `AmapBaseResponse` |
| 字段映射 | 严格对应高德 API 的入参/出参字段名 |
| 注释密度 | 每个字段都有 Javadoc + `@return`/`@param` |
| 命名规则 | `[功能]Request`, `[功能]Response`（如 `RoutePlanningRequest`）|

```java
public class RoutePlanningRequest extends AmapBaseRequest {
    private String origin;
    private String destination;
    // ... 纯 POJO + getter/setter
}
```

### 6.6 `service.plan` —— 算法规划模块

| 规则项 | 说明 |
|--------|------|
| 职责 | 封装 OR-Tools 等算法库，与业务解耦 |
| 输入 | 接收 `PlanResponse.TripPoiInfo` 等内部领域对象 |
| 输出 | 返回优化后的 POI 访问顺序 `List<PlanResponse.TripPoiInfo>` |
| 依赖注入 | 通过构造器接收 `AmapClient` 等外部服务 |

---

## 七、编码规范速查清单

1. 中文 Javadoc 是强制的，每个 public 成员都必须有
2. API 暴露必须加 `@Schema`，Controller 必须加 `@Tag`
3. 统一返回 `ResponseData<T>`，不允许直接返回裸对象
4. Controller 按权限分目录：`open`/`admin`/`saas`/`mch`/`guest`/`rpc`
5. VO 可选手写 Builder 模式，必须手写 getter/setter（不用 Lombok）
6. 调用方法时参数列表内保留空格（项目特定风格）
7. 常量全大写，枚举定义在 VO 内部
8. 配置通过 `saas.lvtu` 前缀的 Properties 类管理
9. 高德 API 的 VO 必须继承 `AmapBaseRequest`/`AmapBaseResponse`
10. 日志使用 `slf4j`，避免 `System.out.println`
