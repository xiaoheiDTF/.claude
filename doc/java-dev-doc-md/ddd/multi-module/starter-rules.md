# starter 模块开发规则

> 所属模式：多模块 DDD（完整模式）
> 所属模块：project-starter
> 包路径：`com.company.project`

---

## 1. 创建规则

### 什么时候创建
- 项目初始化时创建，每个微服务一个 Starter 模块

### 创建什么
- Spring Boot 启动类
- application.yml 配置文件

---

## 2. 文件命名规则

| 文件 | 命名 | 示例 |
|------|------|------|
| 启动类 | 业务名+Application | `OrderApplication` |
| 配置文件 | application.yml | — |

---

## 3. 代码质量规则

### 【强制】
- 启动类使用 `@SpringBootApplication`
- 通过 `@ComponentScan` 或 `@EnableFeignClients` 扫描其他模块的 Bean
- 不包含业务逻辑
- 配置文件按环境分离（dev/prod/test）

### 【禁止】
- 禁止在启动类中写业务逻辑
- 禁止硬编码配置（使用配置文件）

---

## 4. 依赖规则

### 可引用
- 所有其他模块（通过 Maven 依赖）
- Spring Boot Starter

### 禁止引用
- 无特殊限制（这是聚合模块）

---

## 5. AI 生成检查项

- [ ] 启动类有 `@SpringBootApplication`
- [ ] 组件扫描覆盖所有模块
- [ ] 配置文件按环境分离
- [ ] 无业务逻辑

---

## 6. 代码模板

```java
@SpringBootApplication
@ComponentScan(basePackages = "com.company.project")
@EnableFeignClients(basePackages = "com.company.project.client")
public class OrderApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderApplication.class, args);
    }
}
```
